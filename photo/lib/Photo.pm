package Photo;

use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;

    $self->log->level("debug");

    my $site_config = $self->plugin("Config" => {file => $self->home->rel_file('../photo.config')});

    $self->secrets([$$site_config{site_secret}]);

    eval {
        $self->plugin(AccessLog => {
            log => $self->home->rel_file("log/access.log"), 
            format => '%h %l %u %t "%r" %>s %b %D "%{Referer}i" "%{User-Agent}i"'
        });
    };

    my $r = $self->routes;

    my $have_album = $r->under (sub {
        my $self = shift;

        if (!$self->session("album")) {
            my $url = $self->url_for('/');
            $self->redirect_to($url);
            return undef;
        }

        return 1;
    });
    
    $r->get('/')->to(controller => 'Index', action => 'slash');

    $r->get('/album/create')->to(
        controller => 'Album', 
        action => 'create'
    );
    $r->get('/album/switch/:name')->to(
        controller => 'Album', 
        action => 'switch', 
        name => undef
    );
    $r->post('/album/save')->to(
        controller => 'Album', 
        action => 'save'
    );

    $have_album->get('/album/show')->to(
        controller => 'Album', 
        action => 'show'
    );
    $have_album->get('/album/photo/:slot')->to(
        controller => 'Album', 
        action => 'photo'
    );
    $have_album->post('/album/upload')->to(
        controller => 'Album', 
        action => 'upload'
    );
}

1;
