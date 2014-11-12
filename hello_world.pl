#!/opt/perl

use Mojolicious::Lite; # (*@\label{_ex1_1_use}@*)

get '/' => sub {
    my $self = shift;

    $self->render("index"); # (*@\label{_ex1_1_render}@*)
};

app->start;

__DATA__

@@ index.html.ep

<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
</head>
<body>
    Hello world<br> # (*@\label{_ex1_1_add_line_here}@*)
};
</body>
</html>
