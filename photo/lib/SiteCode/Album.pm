package SiteCode::Album;

use Mojo::Base -strict;

use Moose;

has 'path' => (is => 'ro', isa => 'Str');
has 'name' => (is => 'ro', isa => 'Str');

sub create {
    my $this = shift;

    mkdir($this->path);

    return 1;
}

sub exists {
    my $this = shift;

    if (-d $this->path) {
        return 1;
    }

    return 0;
}

sub remove {
}

1;
