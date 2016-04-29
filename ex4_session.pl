use Mojolicious::Lite;

# Landing page
get '/' => sub {
  my $c = shift;

  return $c->redirect_to("/time") if $c->session("username");
  return $c->redirect_to("/login");
};

# Show login
get '/login' => 'login';

# Process login
post '/login' => sub {
  my $c = shift;

  # Authentication
  unless ("Bender" eq $c->param("username")) {
    return $c->redirect_to("/login");
  }
  if ("rocks" ne $c->param("password")) {
    return $c->redirect_to("/login");
  }

  ### The session persists across requests via cookies
  $c->session(username => $c->param("username"));

  # Expiration date in seconds from now (persists between requests)
  #
  # This is how long they are logged in
  $c->session(expiration => 604800);

  return $c->redirect_to("/time");
};

# Exit member area
get '/logout' => sub {
  my $c = shift;

  # Delete whole session by setting an expiration date in the past  
  $c->session(expires => 1);

  $c->redirect_to("/login");
};

# Session authentication
under (sub {
  my $c = shift;

  # Already logged in?
  if ($c->session("username")) {
    return 1;
  }

  $c->redirect_to("/login");

  return undef;
});
 
# Super secret member area
get '/time' => sub {
  my $c = shift;

  $c->stash("whence", scalar(localtime));

  return $c->render(template => "time");
};
 
# Access to private file(s)
get '/passwd' => sub {
  my $c = shift;

  $c->res->headers->content_type('text/plain');
  $c->reply->asset(Mojo::Asset::File->new(path => '/etc/passwd'));
};

app->start;
 
__DATA__
 
@@ layouts/main.html.ep

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">

    <title><%= title %></title>
  </head>

  <body>
    %= content
  </body>
</html>

@@ login.html.ep

% layout 'main', title => 'Login';

<form role="form" method="post" action="<%= url_for('/login') %>">
  <input type="text" placeholder="Username" name=username>
  <input type="password" placeholder="Password" name=password>
  <button type="submit">Submit</button>
</form>

@@ time.html.ep

% layout 'main', title => 'Time';

<%= stash('whence') %>
<br>
<%= link_to Passwd => "passwd" %> <br>
<%= link_to Logout => "logout" %>
