package SiteCode::Account;

use Mojo::Base -base;

use Mojo::Util;

use SiteCode::DBX;
use Crypt::Eksblowfish::Bcrypt;

use File::Temp;

has dbx  => sub { SiteCode::DBX->new };

has [qw(id username password email route)] => undef;

sub _lookup_id_with_username {
    my $self = shift;

    return($self->dbx->col("SELECT id FROM account WHERE username = ?", undef, $self->username));
}

sub _lookup {
    my $self = shift;
    my $lookup = shift;

    return($self->dbx->col("SELECT $lookup FROM account WHERE id = ?", undef, $self->id));
}

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    eval {
        $self->id($self->_lookup_id_with_username());

        if ($self->password) {
            unless($self->chkpw($self->password)) {
                die("Credentials mis-match.\n");
            }
        }

        foreach my $key (qw(password email)) {
            $self->$key($self->_lookup($key));
        }
    };
    if ($@) {
        $self->route->app->log->debug("RTCRoom::Account::new: $@") if $self->route;
        die($@);
    }

    return($self);
}

sub insert
{
    my $class = shift;
    my $ops = shift;

    my $dbx = SiteCode::DBX->new();
    my $password_hash = $class->hash_password($ops->{password});

    if ($ops->{id}) {
        $dbx->do(
            "INSERT INTO account (id, username, password, email) VALUES (?, ?, ?, ?)", undef, 
            $ops->{id}, $ops->{username}, $password_hash, $ops->{email}
        );
    }
    else {
        $dbx->do(
            "INSERT INTO account (username, password, email) VALUES (?, ?, ?)", undef, 
            $ops->{username}, $password_hash, $ops->{email}
        );
    }
    $dbx->dbh->commit;

    my $id = $dbx->col("SELECT id FROM account WHERE username = ?", undef, $ops->{username});

    return($id);
}

sub chkpw
{
    my $self = shift;
    my $pw = shift;

    my $saved_pw = $self->dbx()->col("SELECT password FROM account WHERE id = ?", undef, $self->id());

    return($self->check_password($pw, $saved_pw));
}

sub exists {
    my $class = shift;

    my %opt = @_;

    if ($opt{username}) {
        return(SiteCode::DBX->new->col("SELECT id FROM account WHERE username = ?", undef, $opt{username}));
    }

    return(0);
}

sub key
{
    my $self = shift;
    my $key = shift;

    my $dbx = SiteCode::DBX->new();

    if (scalar(@_)) {
        if (defined $_[0]) {
            my $value = shift;
            my $defined = $self->key($key);

            if (defined $defined) {
                my $id = $dbx->col("SELECT id FROM account_key WHERE account_id = ? AND account_key = ?", undef, $self->id(), $key);
                $dbx->do("UPDATE account_value SET account_value = ? WHERE account_key_id = ?", undef, $value, $id);

                $dbx->dbh->commit;
            }
            else {
                $dbx->do("INSERT INTO account_key (account_id, account_key) VALUES (?, ?)", undef, $self->id(), $key);
                my $id = $dbx->col("SELECT id FROM account_key WHERE account_id = ? AND account_key = ?", undef, $self->id(), $key);
                $dbx->do("INSERT INTO account_value (account_key_id, account_value) VALUES (?, ?)", undef, $id, $value);

                $dbx->dbh->commit;
            }
        }
        else {
            my $defined = $self->key($key);

            if ($defined) {
                my $id = $dbx->col("SELECT id FROM account_key WHERE account_id = ? AND account_key = ?", undef, $self->id(), $key);
                $dbx->do("DELETE FROM account_key where id = ?", undef, $id);

                $dbx->dbh->commit;
            }
        }
    }

    my $row = $dbx->row(qq(
        SELECT 
            account_key, account_value 
        FROM 
            account_key, account_value 
        WHERE account_key = ?
            AND account_id = ?
            AND account_key.account_id = account_id
            AND account_key.id = account_value.account_key_id
    ), undef, $key, $self->id());

    my $ret = $row->{account_value};
    return($ret);
}

# http://www.eiboeck.de/blog/2012-09-11-hash-your-passwords

sub check_password { 
    my $self = shift;

    return(0) if !defined $_[0];
    return(0) if !defined $_[1];

    my $hash = $self->hash_password($_[0], $_[1]);

    return($hash eq $_[1]);
}

sub hash_password {
    my $self = shift;

	my ($plain_text, $settings_str) = @_;

    unless ($settings_str) {
        my $cost = 10;
        my $nul  = 'a';
         
        $cost = sprintf("%02i", 0+$cost);

        my $settings_base = join('','$2',$nul,'$',$cost, '$');

        my $salt = join('', map { chr(int(rand(256))) } 1 .. 16);
        $salt = Crypt::Eksblowfish::Bcrypt::en_base64( $salt );
        $settings_str = $settings_base.$salt;
    }

	return Crypt::Eksblowfish::Bcrypt::bcrypt($plain_text, $settings_str);
}

1;
