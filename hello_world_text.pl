use Mojolicious::Lite; #*\label{_ex1_1_use}*)

get '/' => {text => 'Mojolicious is awesome!'};

app->start;
