use Mojolicious::Lite;
use Mojo::SQLite;

use Mojo::Util qw(steady_time md5_sum);
 
helper sql => sub { state $sql = Mojo::SQLite->new("sqlite:_chat.sqlite") };

# Setup and reset database
app->sql->migrations->from_data("main", "migrations")->migrate;
app->sql->db->query("DELETE FROM connected");
 
get "/" => "chat";
 
websocket "/channel" => sub {
  my $c = shift;
 
  # Setup connection
  $c->inactivity_timeout(3600);

  # Identify connection
  $c->stash("unique", md5_sum(steady_time));

  # Send FYI notifications
  my $id = Mojo::IOLoop->recurring(10 => sub {
    my $loop = shift;

    my $human = "people";
    my $word = "are";
    
    my $connected = $c->sql->db->query(qq(
      SELECT COUNT(person) as count
      FROM connected
      WHERE person != ?),

      $c->stash("unique")
    )->hash->{count};

    if ($connected) {
      $human = "person" if 1 == $connected;
      $word = "is" if 1 == $connected;
    }

    $c->send(sprintf("The time is now: %s, $connected other $human $word connected",
      scalar(localtime)));
  });
 
  # Forward messages from the browser to SQLite
  $c->on(message => sub { shift->sql->pubsub->notify(mojochat => shift) });
 
  # Forward messages from SQLite to the browser
  my $cb = $c->sql->pubsub->listen(mojochat => sub { $c->send(pop) });

  # Gracefully cleanup 
  $c->on(finish => sub { 
    my $c = shift;

    $c->sql->pubsub->unlisten(mojochat => $cb);
    
    $c->sql->db->query("DELETE FROM connected WHERE person = ?", $c->stash("unique"));

    Mojo::IOLoop->remove($id);
  });

  # Record our presence
  $c->sql->db->query("INSERT INTO connected VALUES (?, CURRENT_TIMESTAMP)", $c->stash("unique"));
};
 
app->start;
__DATA__
 
@@ chat.html.ep
<form onsubmit="sendChat(this.children[0]); return false"><input></form>
<div id="log"></div>
<script>
  var ws  = new WebSocket('<%= url_for('channel')->to_abs %>');
  ws.onmessage = function (e) {
    document.getElementById('log').innerHTML += '<p>' + e.data + '</p>';
  };
  function sendChat(input) { ws.send(input.value); input.value = '' }
</script>

@@ migrations

-- 1 up
create table connected (person text, inserted datetime);

-- 1 down
drop table connected;
