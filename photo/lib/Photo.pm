package Photo;

use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  $self->log->level("debug");

  my $site_config = $self->plugin("Config" => {file => '/opt/photo'});
  $self->helper(site_dir => \&site_dir);
  $self->helper(site_config => \&site_config);
  $self->site_dir($$site_config{site_dir});
  $self->site_config($site_config);

  $self->plugin(AccessLog => {uname_helper => 'set_username', log => "$$site_config{site_dir}/log/access.log", format => '%h %l %u %t "%r" %>s %b %D "%{Referer}i" "%{User-Agent}i"'});

  $self->secrets([$$site_config{site_secret}]);
  
  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to(controller => 'Index', action => 'slash'); # (*@\label{_appendix_route}@*)
}

1;
