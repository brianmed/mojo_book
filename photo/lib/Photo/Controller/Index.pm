package Photo::Controller::Index;

use Mojo::Base qw(Mojolicious::Controller);
use File::Spec;
use SiteCode::Account;

# http://mattlockyer.com/2013/04/08/twitter-bootstrap-carousel-full-markup-example/

sub slash { # (*@\label{_appendix_route_slash}@*)
    my $c = shift;

    return($c->render); # (*@\label{_appendix_render_slash}@*)
}

1;
