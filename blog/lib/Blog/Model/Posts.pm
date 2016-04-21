package Blog::Model::Posts;
use Mojo::Base -base;

has 'sql';

sub add {
  my ($self, $post) = @_;
  my $sql = 'insert into posts (title, body) values (?, ?)';
  return $self->sql->db->query($sql, $post->{title}, $post->{body})->last_insert_id;
}

sub all { shift->sql->db->query('select * from posts')->hashes->to_array }

sub find {
  my ($self, $id) = @_;
  return $self->sql->db->query('select * from posts where id = ?', $id)->hash;
}

sub remove { shift->sql->db->query('delete from posts where id = ?', shift) }

sub save {
  my ($self, $id, $post) = @_;
  my $sql = 'update posts set title = ?, body = ? where id = ?';
  $self->sql->db->query($sql, $post->{title}, $post->{body}, $id);
}

1;
