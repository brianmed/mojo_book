package SiteCode::DBX;

use Mojo::Base -base;

use DBI;
use Carp;
use DBIx::Connector

has dbdsn => "dbi:Pg:dbname=rtcroom";
has dbh  => sub { state $dbh = pop };
has dbix  => sub { state $dbix = pop };

has [qw(id username password email route)] => undef;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    $self->dbix($self->_build_dbix);
    $self->dbh($self->_build_dbh);

    return($self);
}

sub _build_dbh {
    my $self = shift;

    my $dbix = $self->dbix();

    return($dbix->dbh());
}

sub _build_dbix {
    my $self = shift;

    my $conn = DBIx::Connector->new($self->dbdsn, "", "", {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 0,
    });

    return($conn);
}

sub do {
    my $self = shift;
    my $sql = shift;
    my $attrs = shift;
    my @vars = @_;

    if (ref($self)) {
        eval {
            return($self->dbh()->do($sql, $attrs, @vars));
        };
        if ($@) {
            croak("$@");
        }
    }
    else {
        my $dbh = $self->_build_dbh();
        return($dbh->do($sql, $attrs, @vars));
    }
}

sub success {
    my $self = shift;
    my $sql = shift;
    my $attrs = shift;
    my @vars = @_;

    my $ret = $self->dbh()->do($sql, $attrs, @vars);
    if ($ret && 0 != $ret) {  # 0E0
        return(1);
    }

    return(0);
}

sub last_insert_id
{
    my $self = shift;

    my $catalog = shift;
    my $schema = shift;
    my $table = shift;
    my $field = shift;
    my $attrs = shift;

    if ($attrs) {
        return($self->dbh()->last_insert_id(undef,undef,undef,undef,$attrs));
    }
    else {
        return($self->dbh()->last_insert_id($catalog, $schema, $table, $field, undef));
    }
}

sub col {
    my $self = shift;
    my $sql = shift;
    my $attrs = shift;
    my @vars = @_;

    my $ret = undef;
    eval {
        my $col = $self->dbh()->selectcol_arrayref($sql, $attrs, @vars);
        if ($col && defined $$col[0]) {
            $ret = $$col[0];
        }
    };
    if ($@) {
        croak("$@");
    }

    return($ret);
}

sub row {
    my $self = shift;
    my $sql = shift;
    my $attrs = shift;
    my @vars = @_;

    my $ret = $self->dbh()->selectall_arrayref($sql, { Slice => {} }, @vars);
    if ($ret && $$ret[0]) {
        return($$ret[0]);
    }

    return(undef);
}

sub question
{
    my $self = shift;
    my $nbr = shift;

    return(join(", ", map({"?"} (1 .. $nbr))));
}

sub array {
    my $self = shift;
    my $sql = shift;
    my $attrs = shift;
    my @vars = @_;

    my $ret = $self->dbh()->selectall_arrayref($sql, { Slice => {} }, @vars);
    if ($ret) {
        return($ret);
    }

    return(undef);
}

1;
