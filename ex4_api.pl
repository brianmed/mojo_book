use Mojolicious::Lite;
use Mojo::SQLite;
 
helper sql => sub { state $sql = Mojo::SQLite->new("sqlite:_ex4_api.sqlite") };

app->sql->migrations->from_data("main", "migrations")->migrate;

get '/' => 'index';

under (sub {
    my $c = shift;

    unless ($c->req->json) {
      $c->render(json => {
        status => "error", data => { message => "No JSON found" }
      });

      return undef;
    }

    my $username = $c->req->json->{username};
    my $api_key = $c->req->json->{api_key};

    unless ($username) {
      $c->render(json => {
        status => "error", data => { message => "No username found" }
      });

      return undef;
    }

    unless ($api_key) {
      $c->render(json => {
        status => "error", data => { message => "No API key found" }
      });

      return undef;
    }

    unless ("fnord" eq $username) {
      $c->render(json => {
        status => "error", data => { message => "Credentials mis-match" }
      });

      return undef;
    }

    unless ("68b329da9893e34099c7d8ad5cb9c940" eq $api_key) {
      $c->render(json => {
        status => "error", data => { message => "Credentials mis-match" }
      });

      return undef;
    }

    return 1;
});

helper insert => sub {
  my $c = shift;

  my $email = $c->req->json->{email};
  my $key = $c->req->json->{key};
  my $value = $c->req->json->{value};

  $c->sql->db->query(
    "INSERT INTO keys (email, key, value) VALUES (?, ?, ?)",
     $email, $key, $value
  )->last_insert_id;

  return $c;
};

helper select => sub {
  my $c = shift;

  my $email = $c->req->json->{email};
  my $key = $c->req->json->{key};

  return $c->sql->db->query(
    "SELECT * from keys WHERE email = ? and key = ?",
    $email, $key
  )->hash;
};

helper update => sub {
  my $c = shift;

  my $value = $c->req->json->{value};
  my $email = $c->req->json->{email};
  my $key = $c->req->json->{key};

  $c->sql->db->query(
    "UPDATE keys SET value = ? WHERE email = ? AND key = ?",
    $value, $email, $key
  )->hash;

  return $c;
};

helper delete => sub {
  my $c = shift;

  my $email = $c->req->json->{email};
  my $key = $c->req->json->{key};

  my $hash = $c->select;

  $c->sql->db->query(
    "DELETE FROM keys WHERE email = ? AND key = ?",
    $email, $key
  )->hash;

  return { %{$hash}, id => 0 };
};

any '/v1/insert' => sub {
    my $c = shift;

    return($c->render(json => {
      status => "success",
      datum => $c->insert->select
    }));
};

any '/v1/select' => sub {
    my $c = shift;

    return($c->render(json => {
      status => "success",
      datum => $c->select
    }));
};

any '/v1/update' => sub {
    my $c = shift;

    return($c->render(json => {
      status => "success",
      datum => $c->update->select
    }));
};

any '/v1/delete' => sub {
    my $c = shift;

    return($c->render(json => {
      status => "success",
      datum => $c->delete
    }));
};

app->start;

__DATA__

@@ index.html.ep

Try:<br>

    GET|POST /v1/insert<br>
    GET|POST /v1/select<br>
    GET|POST /v1/update<br>
    GET|POST /v1/delete

@@ migrations

-- 1 up
create table keys (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email text,
  key text,
  value text,
  inserted datetime DEFAULT CURRENT_TIMESTAMP
);

-- 1 down
drop table keys;
