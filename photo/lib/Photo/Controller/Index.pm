package Photo::Controller::Index;

use Mojo::Base qw(Mojolicious::Controller);
use SiteCode::Albums;

# http://mattlockyer.com/2013/04/08/twitter-bootstrap-carousel-full-markup-example/

sub slash { # (*@\label{_appendix_route_slash}@*)
    my $c = shift;

    my $site_config = $c->site_config; # (*@\label{_slash_setup}@*)
    my $all = SiteCode::Albums->new(path => $$site_config{album_dir})->all;

    if (0 == @{ $all }) { # Create an album if none found (*@\label{_slash_no_albums}@*)
        my $url = $c->url_for('/album/create');
        return($c->redirect_to($url));
    }

    if ($c->session("album")) { # Show the album if we have a session (*@\label{_slash_have_session}@*)
        my $url = $c->url_for('/album/show');
        return($c->redirect_to($url));
    }

    my $url = $c->url_for('/album/switch'); # Select an album if nothing selected (*@\label{_slash_no_session}@*)
    return($c->redirect_to($url));
}

1;
