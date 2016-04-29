use Mojolicious::Lite;
use Mojo::URL;

# Search MetaCPAN for "mojo" and "minion"
get '/' => sub {
  my $c = shift;

  # Prepare response in two steps
  $c->delay(

    # Concurrent requests
    sub {
      my $delay = shift;
      my $url   = Mojo::URL->new('api.metacpan.org/v0/module/_search');
      $url->query({sort => 'date:desc'});
      $c->ua->get($url->clone->query({q => 'mojo'})   => $delay->begin);
      $c->ua->get($url->clone->query({q => 'minion'}) => $delay->begin);
    },

    # Delayed rendering
    sub {
      my ($delay, $mojo, $minion) = @_;
      $c->render(json => {
        mojo   => $mojo->res->json('/hits/hits/0/_source/release'),
        minion => $minion->res->json('/hits/hits/0/_source/release')
      });
    }
  );
};

app->start;
