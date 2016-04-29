use Mojolicious::Lite;

get '/' => sub { #*\label{_ex2_1_index}*)
    my $self = shift;

    $self->render(text => "Hello world");
};

app->start;
