use Mojolicious::Lite;

get '/:name' => {name => 'Default'} => sub {
    my $self = shift;

    my $name = $self->param("name");

    $self->render(text => "Hello world: $name");
};

app->start;
