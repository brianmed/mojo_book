package Photo::Controller::Index;

use Mojo::Base 'Mojolicious::Controller';

sub slash { # (*@\label{_appendix_slash}@*)
    my $c = shift;

    $c->reply->static('index.htm'); # (*@\label{_appendix_static}@*)
}

1;
