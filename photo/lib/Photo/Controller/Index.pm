package Photo::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';

sub slash {
    my $c = shift;

    $c->reply->static('index.htm');
}

1;
