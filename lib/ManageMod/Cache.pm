package ManageMod::Cache;

use strict;
use warnings;

use base "Exporter::Tiny";

our @EXPORT = qw(cache);

use CHI;
use Hash::Merge::Simple 'merge';
use Log::Any '$log';

our $DEFAULT_BASENAME  = $ENV{BASENAME} // 'manage-mods';
our $DEFAULT_CACHE_DIR = "$ENV{HOME}/.cache/$DEFAULT_BASENAME";

our $DEFAULT_CACHE_OPTS = {
  depth      => 2,
  driver     => 'File',
  expires_in => '24 hours',
};

sub cache {
  my ( $cache_opts ) = @_;

  $cache_opts //= {};

  die "_cache expects a hash-ref as an argument"
    unless ref $cache_opts eq 'HASH';

  $cache_opts->{label}     //= $DEFAULT_BASENAME;
  $cache_opts->{namespace} //= $DEFAULT_BASENAME;
  $cache_opts->{root_dir}  //= delete $cache_opts->{cache_dir} // $DEFAULT_CACHE_DIR;

  my $copts = merge $DEFAULT_CACHE_OPTS, $cache_opts;

  $log->warn( "Creating CHI object" );
  $log->debug( "$_: $copts->{$_}" ) for keys %$copts;

  return CHI->new( %$copts );

} ## end sub _cache

1;
