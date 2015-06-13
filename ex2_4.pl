use Mojolicious::Lite;

get '/:name' => sub { # (*@\label{_ex2_4_placeholder}@*)
    my $c = shift;

    my $name = $c->param("name");

    $c->app->log->debug("get");
    my $url = $self->url_for('/Example')->to_abs;

    $c->stash(name => $name); # (*@\label{_ex2_4_stash}@*)
    $c->stash(url => $url);

    $c->render("slash");
};
app->start;

__DATA__

@@ slash.html.ep

% if (stash('name')) {  <!-- (*@\label{_ex2_4_stash_usage}@*) -->
    You are <%= stash('name') %>
% } else {
    Please pass in a name to the url like so '<\%= stash('url') %>'.
% }
