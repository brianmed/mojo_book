use Mojolicious::Lite;

get '/carpe' => sub { #*\label{_ex2_1_carpe}*)
    my $self = shift;

    $self->render("carpe");
};

get '/' => sub { #*\label{_ex2_1_index}*)
    my $self = shift;

    $self->render("index");
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
    Hello world<br>
    <a href="<%= url_for("/carpe") %>">Carpe Diem</a>
</body>
</html>

@@ carpe.html.ep

<!DOCTYPE html>
<html>
<head>
    <title>Carpe Diem</title>
</head>
<body>
    Carpe Diem<br>
    <a href="<%= url_for("/") %>">Return</a>
</body>
</html>
