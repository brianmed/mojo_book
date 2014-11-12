use Mojolicious::Lite;

get '/foo' => sub {  # (*@\label{_ex2_1_get}@*)
    my $self = shift;
    $self->render(text => 'Hello World!');
};

post '/foo' => sub { # (*@\label{_ex2_1_post}@*)
    my $self = shift;
    $self->render(text => 'Another World!');
};

app->start;
