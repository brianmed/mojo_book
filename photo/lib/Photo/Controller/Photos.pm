package Photo::Controller::Photos;

use Mojo::Base qw(Mojolicious::Controller);

sub index {
    my $c = shift;

    unless ($c->session->{username}) {
        my $url = $c->url_for('/');
        return($c->redirect_to($url));
    }

    $c->render;
}

1;
