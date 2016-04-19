package SiteCode::Album;

use Mojo::Base -base;

use Mojo::JSON qw(encode_json decode_json);
use Mojo::Util qw(spurt slurp);
use File::Basename qw(basename);

has 'path';
has 'name';

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

sub add {
    my $this = shift;
    my %ops = @_;

    my $photo = $ops{photo};
    my $label = $ops{label};
    my $descr = $ops{descr};

    my $idx = 0;        

    opendir(my $dh, $this->path) or die("can't opendir " . $this->path . ": $!");
    while (my $file = readdir($dh)) {
        next if $file =~ m/^\./;

        ++$idx;
    }
    closedir $dh;

    my $slot = $this->path . "/$idx";        

    my $extension = "";

    if ($photo->filename =~ m#\.(.*?)$#) {
        $extension = $1;
    }
    else {
        die("No extension found\n");
    }

    if ("json" eq $extension) {
        die("Extension should not be .json\n");
    }

    $photo->move_to("$slot.$extension");

    my $json = encode_json({ idx => $idx, extension => $extension, label => $label, descr => $descr, filename => basename($photo->filename) });
    spurt($json, "$slot.json");

    return $this;
}

sub slots {
    my $this = shift;

    my @slots = ();

    opendir(my $dh, $this->path) or die("can't opendir " . $this->path . ": $!");
    while (my $file = readdir($dh)) {
        next if $file =~ m/^\./;

        if ($file =~ m/\.json$/) {
            push(@slots, decode_json(slurp($this->path . "/$file")));
        }
    }
    closedir $dh;

    @slots = sort({ $a->{idx} <=> $b->{idx} } @slots);

    return(\@slots);
}

sub photo {
    my $this = shift;
    my $slot = shift;

    my $file = $this->path . "/$slot";

    my $hash = decode_json(slurp("$file.json"));

   return("$file.$hash->{extension}");
}

1;
