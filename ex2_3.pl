get '/carpe' => sub {
    my $self = shift;
    my $now = scalar(localtime(time()));
    $self->app->log->debug($self->app->dumper({ now => $now }));
    $self->render("carpe", now => $now);
};
