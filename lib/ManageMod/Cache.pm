package ManageMod::Cache;

## no critic

use strictures 2;

#############################################################################
=head1 NAME

ManageMod::Cache - Returns a CHI cache object

=head1 SYNOPSIS

  use ManageMod::Cache;

  my $cache = cache();

  my $copts = { label => 'mylabel', namespace => 'mynamespace' };

  my $cache2 = cache( $copts );

=head1 FUNCTIONS

=head2 cache

Calling C<cache> with no parameters will return a base C<CHI> cache object
with the following options:

  { depth      => 2,
    driver     => 'File',
    expires_in => '1 week',
    label      => 'manage-mods',
    namespace  => 'manage-mods',
    root_dir   => '~/.cache/manage-mods',
  }

You can create a hash with all the same options the C<CHI->new> method is
expecting, with the following addition:

C<cache_dir> is synonymous with C<root_dir>

=cut
#############################################################################

use parent "Exporter::Tiny";

our @EXPORT = qw(cache);

use CHI;
use Hash::Merge::Simple 'merge';
use Log::Any '$log';

our $DEFAULT_BASENAME  = $ENV{MANAGE_MOD_BASENAME} // 'manage-mod';
our $DEFAULT_CACHE_DIR = "$ENV{MANAGE_MOD_CACHE_DIR}" // "$ENV{HOME}/.cache/$DEFAULT_BASENAME";

our $DEFAULT_CACHE_OPTS = {
  depth      => 2,
  driver     => 'File',
  expires_in => '1 week',
};

sub cache {
  my ( $cache_opts ) = @_;

  $cache_opts //= {};

  die $log->fatalf( '%s expects a hash-ref as an argument', (caller(0))[3] )
    unless ref $cache_opts eq 'HASH';

  $cache_opts->{label}     //= $DEFAULT_BASENAME;
  $cache_opts->{namespace} //= $DEFAULT_BASENAME;
  $cache_opts->{root_dir}  //= delete $cache_opts->{cache_dir} // $DEFAULT_CACHE_DIR;

  my $copts = merge $DEFAULT_CACHE_OPTS, $cache_opts;

  $log->warn( 'Creating CHI object' );
  $log->debug( 'copts: ', $copts );

  return CHI->new( %$copts );

} ## end sub cache

1;
