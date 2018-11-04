package ManageMod::GetData;

use v5.10;

use strict;
use warnings;

use base "Exporter::Tiny";

our @EXPORT = qw(get_data);

use File::Basename;
use Log::Any '$log';

use ManageMod::Cache;

=head1 NAME

ManageMod::GetData - ...

=head1 SYNOPSIS

  use ManageMod::GetData;

XXX PUT A SYNOPSIS HERE!!! XXX

=head1 FUNCTION

...

=cut

sub get_data {
  my ( $url, $cache_opts ) = @_;

  $cache_opts->{label} //= __PACKAGE__;

  my $cache = cache( $cache_opts );
  my $data  = $cache->get( $url );

  unless ( defined $data ) {
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
    $data = $json->decode( $response->content );

    $cache->set( $url, $data );
  } ## end unless ( defined $data )

  return $data;
} ## end sub get_data

1;
