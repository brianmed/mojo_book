#!/opt/perl

use Mojolicious::Lite;

# Present form
get '/' => "slash"; #*\label{_ex2_6_index}*)

post '/' => sub {
    my $self = shift;

    # Process
    if ("Bender" eq $self->param("name")) { #*\label{_ex2_6_process}*)
        $self->redirect_to("/bender");

        return;
    }

    # Error
    $self->flash(error => "Not bender"); #*\label{_ex2_6_flash}*)
    $self->redirect_to("/"); #*\label{_ex2_6_error}*)
};

get '/bender'; #*\label{_ex2_6_success}*)

app->start;

__DATA__

@@ slash.html.ep

% if (flash("error")) {  #*\label{_ex2_6_flash_usage}*)
    <%= flash("error") %><br>
% }

<form method=post action="/"> #*\label{_ex2_6_action}*)
Name: <input type=text name=name>
</form>

@@ bender.html.ep

Awesome!
