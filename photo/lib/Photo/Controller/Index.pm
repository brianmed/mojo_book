package Photo::Controller::Index;

use Mojo::Base qw(Mojolicious::Controller);
use File::Spec;
use SiteCode::Account;

sub slash { # (*@\label{_appendix_slash}@*)
    my $c = shift;

    if ($c->session->{username}) {
        my $url = $c->url_for('/photos');
        return($c->redirect_to($url));
    }

    my $site_conf = $c->site_config;

    # Has the admin user been setup
    if (SiteCode::Account->exists($site_conf, "admin")) {
        my $url = $c->url_for('/login');
        return($c->redirect_to($url));
    }

    my $url = $c->url_for('/setup');
    return($c->redirect_to($url));
}

sub login {
    my $c = shift;

    my $site_conf = $c->site_config;

    if ("GET" eq $c->req->method) {
        return;
    }

    my $validation = $c->validation;

    # Check if parameters have been submitted
    unless ($validation->has_data) {
        $c->stash(error => "No data found");
        return($c->render);
    }

    $validation->required('username');
    $validation->required('password');

    if ($validation->has_error) {
        return($c->render);
    }

    my $username = $validation->param("username");
    my $password = $validation->param("password");

    my $account;
    eval {
        $account = SiteCode::Account->new(username => $username, password => $password, site_conf => $site_conf);
    };
    if ($@) {
        $c->stash(error => $@);
        return;
    }

    $c->session(username => $account->username);
    $c->session(expiration => 604800);
    
    my $url = $c->url_for('/photos');
    return($c->redirect_to($url));
}

sub setup {
    my $c = shift;

    my $site_conf = $c->site_config;

    if (SiteCode::Account->exists($site_conf, "admin")) {
        my $url = $c->url_for('/');
        return($c->redirect_to($url));
    }

    if ("GET" eq $c->req->method) {
        return;
    }

    my $validation = $c->validation;

    # Check if parameters have been submitted
    unless ($validation->has_data) {
        $c->stash(error => "No data found");
        return($c->render);
    }

    $validation->required('orig_password')->size(1, 8)->like(qr/^[A-Za-z0-9]+$/);
    $validation->required('verify_password')->equal_to('orig_password');

    if ($validation->has_error) {
        return($c->render);
    }

    my $password = $validation->param("orig_password");

    SiteCode::Account->insert($site_conf, username => "admin", password => $password);

    $c->session(username => "admin");
    $c->session(expiration => 604800);
    
    my $url = $c->url_for('/');
    return($c->redirect_to($url));
}

sub logout {
    my $c = shift;

    $c->session(expires => 1);
    
    my $url = $c->url_for('/');
    return($c->redirect_to($url));
}

1;
