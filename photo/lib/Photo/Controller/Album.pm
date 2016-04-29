package Photo::Controller::Album;

use Mojo::Base qw(Mojolicious::Controller);

use SiteCode::Albums;

sub show {
    my $c = shift;

    my $dir = $c->app->home->rel_dir("albums");

    my $albums = SiteCode::Albums->new(path => $dir);

    my $album = SiteCode::Album->new(path => "$dir/" . $c->session->{album}, name => $c->session->{album});
    $c->app->log->debug("album: " . $album->name);

    $c->stash(album => $album);
    $c->stash(slots => $album->slots);
    $c->stash(albums => $albums->all);

    return($c->render);
}

sub save {
    my $c = shift;

    my $dir = $c->app->home->rel_dir("albums");
    my $album_name = $c->param("album_name");

    unless ($album_name) {
        $c->flash("error" => "No album name given");

        my $url = $c->url_for('/album/create');
        return($c->redirect_to($url));
    }

    my $album = SiteCode::Album->new(path => "$dir/$album_name", name => $album_name);

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

    my $dir = $c->app->home->rel_dir("albums");
    my $all = SiteCode::Albums->new(path => $dir)->all;

    $c->stash(albums => $all);

    return($c->render);
}

sub upload {
    my $c = shift;

    my $url = $c->url_for('/album/show');

    # Check file size
    if ($c->req->is_limit_exceeded) {
        $c->flash("error" => "File size too big");

        return($c->redirect_to($url));
    }

    my $photo = $c->param('photo');
    my $descr = $c->param('descr');
    my $label = $c->param('label');

    unless ($label) {
        $c->flash("error" => "Label not found");

        return($c->redirect_to($url));
    }
    unless ($descr) {
        $c->flash("error" => "Description not found");

        return($c->redirect_to($url));
    }
    unless (ref $photo) {
        $c->flash("error" => "File not found");

        return($c->redirect_to($url));
    }
    unless ($photo->size) {
        $c->flash("error" => "File not found");

        return($c->redirect_to($url));
    }

    eval {
        my $dir = $c->app->home->rel_dir("albums");
        my $album_name = $c->session->{album};
        my $album = SiteCode::Album->new(path => "$dir/$album_name", name => $album_name);

        $album->add(photo => $photo, label => $label, descr => $descr);
    };
    if ($@) {
        $c->flash("error" => $@);
    }

    return($c->redirect_to($url));
}

sub photo {
    my $c = shift;

    my $dir = $c->app->home->rel_dir("albums");
    my $album = SiteCode::Album->new(path => "$dir/" . $c->session->{album}, name => $c->session->{album}); #*@\label{_photo_session}*)

    my $slot = $c->param("slot");

    my $filename = $album->photo($slot); #*\label{_photo_filename}*)

    $c->reply->asset(Mojo::Asset::File->new(path => $filename)); #*\label{_photo_reply}*)
}

1;
