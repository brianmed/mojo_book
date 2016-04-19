package SiteCode::Albums;

use Mojo::Base -base;

use SiteCode::Album;

has 'path';

sub all {
    my $this = shift;

    my @albums = ();

    opendir(my $dh, $this->path) or die("can't opendir " . $this->path . ": $!");
    while (my $file = readdir($dh)) {
        next if $file =~ m/^\./;

        push(@albums, SiteCode::Album->new(path => $this->path . "/$file", name => $file));
    }
    closedir $dh;

    return(\@albums);
}

sub album {
    my $this = shift;
    my $name = shift;

    my $album = SiteCode::Album->new(path => $this->path . "/$name", name => $name);
    return $album;
}

1;
