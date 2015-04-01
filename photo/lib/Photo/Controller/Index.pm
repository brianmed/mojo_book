package Photo::Controller::Index;

use Mojo::Base qw(Mojolicious::Controller);
use File::Spec;
use SiteCode::Account;

sub slash {
    my $c = shift;

    if ($c->session->{username}) {
        my $url = $c->url_for('/photo.htm');
        return($c->redirect_to($url));
    }

    my $site_conf = $c->site_config;

    # Has the admin user been setup
    if (SiteCode::Account->exists($site_conf, "admin")) {
        $c->reply->static('login.htm');
        return;
    }

    $c->reply->static('setup.htm');
}

sub init {
}

1;
