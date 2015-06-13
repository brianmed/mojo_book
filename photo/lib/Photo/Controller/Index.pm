package Photo::Controller::Index;

use Mojo::Base qw(Mojolicious::Controller);
use SiteCode::Albums;

# http://mattlockyer.com/2013/04/08/twitter-bootstrap-carousel-full-markup-example/

sub slash { # (*@\label{_appendix_route_slash}@*)
    my $c = shift;

    my $site_config = $c->site_config;
    my $all = SiteCode::Albums->new(path => $$site_config{album_dir})->all;

    if (0 == @{ $all }) {
        my $url = $c->url_for('/album/create');
        return($c->redirect_to($url));
    }

    if ($c->session("album")) {
        my $url = $c->url_for('/album/show');
        return($c->redirect_to($url));
    }

    my $url = $c->url_for('/album/switch');
    return($c->redirect_to($url));
}

1;
