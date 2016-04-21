package Blog;
use Mojo::Base 'Mojolicious';

use Blog::Model::Posts;
use Mojo::SQLite;

sub startup {
  my $self = shift;

  # Configuration
  $self->plugin('Config' => {file => $self->home->rel_file('../blog.config')});
  $self->secrets($self->config('secrets'));

  # Model
  $self->helper(sql => sub { state $sql = Mojo::SQLite->new('sqlite:_blog.sqlite') });
  $self->helper(
    posts => sub { state $posts = Blog::Model::Posts->new(sql => shift->sql) });

  # Migrate to latest version if necessary
  my $path = $self->home->rel_file('migrations/blog.sql');
  $self->sql->migrations->name('blog')->from_file($path)->migrate;

  # Controller
  my $r = $self->routes;
  $r->get('/' => sub { shift->redirect_to('posts') });
  $r->get('/posts')->to('posts#index');
  $r->get('/posts/create')->to('posts#create')->name('create_post');
  $r->post('/posts')->to('posts#store')->name('store_post');
  $r->get('/posts/:id')->to('posts#show')->name('show_post');
  $r->get('/posts/:id/edit')->to('posts#edit')->name('edit_post');
  $r->put('/posts/:id')->to('posts#update')->name('update_post');
  $r->delete('/posts/:id')->to('posts#remove')->name('remove_post');
}

1;
