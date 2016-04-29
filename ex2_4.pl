use Mojolicious::Lite;

get '/:name' => {name => ''} => sub { #*\label{_ex2_4_placeholder}*)
    my $c = shift;

    my $name = $c->param("name");

    $c->stash(name => $name); #*\label{_ex2_4_stash}*)

    $c->render("slash");
};

app->start;

__DATA__

@@ slash.html.ep

% if (stash('name')) {  #*\label{_ex2_4_stash_usage}*)
    You are <%= stash('name') %>
% } else {
    Please pass in a name to the url like so '<%= url_for('/Ben')->to_abs %>'.
% }
