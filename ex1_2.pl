use Mojolicious::Lite;

get '/' => sub {
    my $self = shift;

    $self->render("index"); #*\label{_ex1_2_render}*)
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
    Hello world<br> <%# Edit here #*\label{_ex1_2_add_line_here}*) %>
</body>
</html>
