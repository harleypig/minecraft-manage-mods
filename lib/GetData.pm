package GetData;

use v5.10;

use strict;
use warnings;

use base "Exporter::Tiny";

our @EXPORT = qw(get_data);

use CHI;
use Data::Dumper;
use File::Basename;
use Hash::Merge::Simple 'merge';
use Log::Any '$log';

$Data::Dumper::Indent = 0;
$Data::Dumper::Sortkeys++;

our $DEFAULT_BASENAME  = $ENV{BASENAME} // 'manage-mods';
our $DEFAULT_CACHE_DIR = "$ENV{HOME}/.cache/$DEFAULT_BASENAME";

our $DEFAULT_CACHE_OPTS = {
  depth      => 2,
  driver     => 'File',
  expires_in => '24 hours',
};

=head1 NAME

CacheFile - a simple file cacheing routine

=head1 SYNOPSIS

  use CacheFile;

XXX PUT A SYNOPSIS HERE!!! XXX

=head1 FUNCTION

...

=cut

sub _cache {
  my ( $cache_opts ) = @_;

  $cache_opts //= {};

  die "_cache expects a hash-ref as an argument"
    unless ref $cache_opts eq 'HASH';

  $cache_opts->{label}     //= $DEFAULT_BASENAME;
  $cache_opts->{namespace} //= $DEFAULT_BASENAME;
  $cache_opts->{root_dir}  //= delete $cache_opts->{cache_dir} // $DEFAULT_CACHE_DIR;

  my $copts = merge $DEFAULT_CACHE_OPTS, $cache_opts;

  $log->warn( "Creating CHI object with ", Dumper $copts );

  return CHI->new( %$copts );

} ## end sub _cache

sub get_data {
  my ( $url, $cache_opts ) = @_;

  my $cache      = _cache( $cache_opts );
  my $cache_data = $cache->get( $url );

  unless ( defined $cache_data ) {
    require LWP::UserAgent;
    require HTTP::Request;

    my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 1 } );
    my $header = HTTP::Request->new( GET => $url );
    my $request = HTTP::Request->new( 'GET', $url, $header );
    my $response = $ua->request( $request );

    # XXX: need to handle errors here

    require JSON;
    my $json = JSON->new;

    $log->warn( "Converting response content to json object" );
    $cache_data = $json->decode( $response->content );

    $cache->set( $url, $cache_data );
  } ## end unless ( defined $cache_data)

  return $cache_data;
} ## end sub get_data

1;
