package Photo::Controller::Index;

use Mojo::Base qw(Mojolicious::Controller);
use SiteCode::Albums;

# http://mattlockyer.com/2013/04/08/twitter-bootstrap-carousel-full-markup-example/

sub slash {
    my $c = shift;

    my $all = SiteCode::Albums->new(path => $c->app->home->rel_dir("albums"))->all;

    if (0 == @{ $all }) { # Create an album if none found
        my $url = $c->url_for('/album/create');
        return($c->redirect_to($url));
    }

    if ($c->session("album")) { # Show the album if we have a session
        my $url = $c->url_for('/album/show');
        return($c->redirect_to($url));
    }

    my $url = $c->url_for('/album/switch'); # Select an album if nothing selected
    return($c->redirect_to($url));
}

1;
