use Mojolicious::Lite;
use Mojo::Util 'secure_compare';

under (sub {
  my $c = shift;
  
  # Check for username "Bender" and password "rocks"
  if (secure_compare($c->req->url->to_abs->userinfo // "", 'Bender:rocks')) {
    return 1;
  }

  # Require authentication
  $c->res->headers->www_authenticate('Basic');
  $c->render(text => 'Authentication required!', status => 401);
  
  return undef;
});

get '/' => sub {
  my $c = shift;

  return $c->render(text => 'Hello Bender!');
};

get '/time' => sub {
  my $c = shift;

  return $c->render(text => scalar(localtime));
};

app->start;
