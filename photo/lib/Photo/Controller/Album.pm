package Photo::Controller::Album;

use Mojo::Base qw(Mojolicious::Controller);

use SiteCode::Albums;

sub show {
    my $c = shift;

    my $site_config = $c->site_config;
    my $albums = SiteCode::Albums->new(path => $$site_config{album_dir});

    $c->app->log->debug("album: " . $c->session->{album});

    $c->stash(album => $c->session->{album});
    $c->stash(albums => $albums->all);

    return($c->render);
}

sub create {
    my $c = shift;

    return($c->render);
}

sub save {
    my $c = shift;

    my $site_config = $c->site_config;

    my $dir = $$site_config{album_dir};
    my $album_name = $c->param("album_name");

    unless ($album_name) {
        $c->flash("error" => "No album name given");

        my $url = $c->url_for('/album/create');
        return($c->redirect_to($url));
    }

    my $album = SiteCode::Album->new(path => "$dir/$album_name");

    if ($album->exists) {
        $c->flash("error" => "Album exists");

        my $url = $c->url_for('/album/create');
        return($c->redirect_to($url));
    }

    unless ($album->create) {
        $c->flash("error" => "Error creating: $album_name");

        my $url = $c->url_for('/album/create');
        return($c->redirect_to($url));
    }

    warn("album_name: $album_name");
    $c->session(album => $album_name);

    my $url = $c->url_for('/');
    return($c->redirect_to($url));
}

sub switch {
    my $c = shift;

    if (defined $c->param("name")) {
        my $album_name = $c->param("name");

        $c->session(album => $album_name);

        my $url = $c->url_for('/');
        return($c->redirect_to($url));
    }

    my $site_config = $c->site_config;
    my $all = SiteCode::Albums->new(path => $$site_config{album_dir})->all;

    $c->stash(albums => $all);

    return($c->render);
}

1;
