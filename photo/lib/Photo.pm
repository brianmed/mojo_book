package Photo;

use Mojo::Base 'Mojolicious';

sub site_dir
{
    state $site_dir = pop;
}

sub site_config
{
    state $site_config = pop;
}


sub startup {
    my $self = shift;

    $self->log->level("debug"); # (*@\label{_appendix_startup_debug}@*)

    my $site_config = $self->plugin("Config" => {file => '/opt/mojo_book/photo.config'}); # (*@\label{_appendix_startup_config}@*)

    $self->secrets([$$site_config{site_secret}]); # (*@\label{_appendix_startup_secrets}@*)

    # (*@\label{_appendix_startup_helpers}@*)
    $self->helper(site_dir => \&site_dir);
    $self->helper(site_config => \&site_config);
    $self->site_dir($$site_config{site_dir});
    $self->site_config($site_config);

    # (*@\label{_appendix_startup_accesslog}@*)
    $self->plugin(AccessLog => {log => "$$site_config{site_dir}/log/access.log", format => '%h %l %u %t "%r" %>s %b %D "%{Referer}i" "%{User-Agent}i"'});

    # (*@\label{_appendix_startup_hypnotoad}@*)
    my $listen = [];
    push(@{ $listen }, "http://$$site_config{hypnotoad_ip}:$$site_config{hypnotoad_port}") if $$site_config{hypnotoad_port};
    push(@{ $listen }, "https://$$site_config{hypnotoad_ip}:$$site_config{hypnotoad_tls}") if $$site_config{hypnotoad_tls};

    $self->config(hypnotoad => {listen => $listen, workers => $$site_config{hypnotoad_workers}, user => $$site_config{user}, group => $$site_config{group}, inactivity_timeout => 15, heartbeat_timeout => 15, heartbeat_interval => 15, accepts => 100});
    
    # Router
    # (*@\label{_appendix_startup_router}@*)
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
    
    # (*@\label{_appendix_startup_routes}@*)
    $r->get('/')->to(controller => 'Index', action => 'slash'); # (*@\label{_appendix_startup_slash_route}@*)

    $r->get('/album/create')->to(controller => 'Album', action => 'create');
    $r->get('/album/switch/:name')->to(controller => 'Album', action => 'switch', name => undef);

    $have_album->get('/album/show')->to(controller => 'Album', action => 'show');
    $have_album->get('/album/photo/:slot')->to(controller => 'Album', action => 'photo');
    $have_album->post('/album/upload')->to(controller => 'Album', action => 'upload');
    $have_album->post('/album/save')->to(controller => 'Album', action => 'save');
}

1;
