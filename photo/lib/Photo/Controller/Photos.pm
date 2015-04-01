package Photo::Controller::Photos;

use Mojo::Base qw(Mojolicious::Controller);

sub index {
    my $c = shift;

    $c->render;
}

1;
