#!/opt/perl
use Mojolicious::Lite;

get '/' => sub {
    my $self = shift;

    $self->app->log->debug("get");

    $self->render("slash");
};
post '/' => sub {
    my $self = shift;

    $self->app->log->debug("post");

    my $name  = $self->param("name");

    $self->session->{name} = $name;

    $self->render("slash");
};
app->start;

__DATA__

@@ slash.html.ep

% if (session "name") {
<%= session "name" %>, you are logged in.
% } else {
<form method=post>
Login: <input type=text name=name>
</form>
% }
