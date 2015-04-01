package SiteCode::Account;

use Mojo::Base -base;

use Mojo::JSON qw(decode_json encode_json);
use Mojo::Util qw(spurt slurp);
use Crypt::Eksblowfish::Bcrypt;
use File::Temp;
use File::Spec;

has [qw(username route site_conf)] => undef;

sub new {
    my $class = shift;
    my %ops = @_;

    my $self = $class->SUPER::new(@_);

    my $file = File::Spec->catfile($self->site_conf->{user_dir}, $self->username);
    my $bytes = slurp($file);
    my $hash = decode_json($bytes);

    eval {
        if ($ops{password}) {
            unless($self->check_password($ops{password}, $$hash{password})) {
                die("Credentials mis-match.\n");
            }
        }
    };
    if ($@) {
        $self->route->app->log->debug("SiteCode::Account::new: $@") if $self->route;
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
