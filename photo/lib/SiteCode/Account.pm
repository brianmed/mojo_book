package SiteCode::Account;

use Mojo::Base -base;

use Mojo::JSON qw(encode_json);
use Mojo::Util qw(spurt);
use Crypt::Eksblowfish::Bcrypt;
use File::Temp;

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
    my $site_conf = shift;
    my %ops = @_;

    my $password_hash = $class->hash_password($ops{password});

    my $file = File::Spec->catfile($$site_conf{user_dir}, $ops{username});
    my $bytes = encode_json({username => "admin", password => $password_hash});
    spurt($bytes, $file);
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
    my $site_conf = shift;
    my $username = shift;

    if ($username) {
        if (-f File::Spec->catfile($$site_conf{user_dir}, $username)) {
            return(1);
        }
    }

    return(0);
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
