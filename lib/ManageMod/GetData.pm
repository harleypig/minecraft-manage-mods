package ManageMod::GetData;

use v5.10;

use strict;
use warnings;

#############################################################################

=head1 NAME

ManageMod::GetData - Gets data from E<36>url and caches it.

=head1 SYNOPSIS

  use ManageMod::GetData;

  my $data = get_data( $url );

  my $copts = { label => 'mylabel', namespace => 'mynamespace' };

  my $data2 = get_data( $url, $copts );

=head1 FUNCTIONS

=cut

#############################################################################
use parent "Exporter::Tiny";

our @EXPORT = qw(get_json get_html get_jar get_redirect);

use Clone 'clone';
use Log::Any '$log';

use ManageMod::Cache;

#############################################################################

=head2 _get_url

XXX

=cut

sub _get_url {
  my ( $url, $cache_opts ) = @_;

  die $log->fatalf( '%s expects a uri to be used with UserAgent', ( caller( 0 ) )[3] )
    unless ref $url eq '' && $url ne '';

  $cache_opts //= {};

  die $log->fatalf( '%s expects a hash-ref as the second parameter', ( caller( 0 ) )[3] )
    unless ref $cache_opts eq 'HASH';

  $cache_opts->{label}     //= __PACKAGE__;
  $cache_opts->{namespace} //= 'raw-urls';

  my $cache = cache( $cache_opts );
  my $data  = $cache->get( $url );

  my $rc=0;
  my $rc_message='found in cache';

  unless ( defined $data ) {
    $log->debug('url cache expired or not there, freshening data');

    require LWP::UserAgent;

    my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 1 } );
    $ua->agent($ENV{MANAGE_MOD_AGENT});

    my $header   = HTTP::Request->new( GET => $url );
    my $request  = HTTP::Request->new( 'GET', $url, $header );
    my $response = $ua->request( $request );

    $rc         = $response->code;
    $rc_message = $response->message;
    $data       = $response->content;

    return $data, $rc, $rc_message
      if $rc != 200;

    $cache->set( $url, $data );
  }

  return $data, $rc, $rc_message;
} ## end sub _get_url

#############################################################################

=head2 get_json

=over

=item Required: E<36>url

=item Optional: E<36>hashref of options to be passed to C<ManageMod::Cache>

=back

Gets json data from C<E<36>url> and returns the objectified data.

=cut

sub get_json {
  my ( $url, $cache_opts ) = @_;

  $cache_opts //= {};

  die $log->fatalf( '%s expects a hash-ref as the second parameter', ( caller( 0 ) )[3] )
    unless ref $cache_opts eq 'HASH';

  my $json_copts = clone( $cache_opts );
  $json_copts->{label}     //= __PACKAGE__;
  $json_copts->{namespace} //= 'json-data';

  my $cache = cache( $json_copts );
  my $data  = $cache->get( $url );

  unless ( defined $data ) {
    $log->debug('json cache expired or not there, freshening data');

    my ( $rc, $message );
    ( $data, $rc, $message ) = _get_url( $url, $cache_opts );

    require JSON;
    my $json = JSON->new;

    $log->warn('Converting response content to json object' );
    $data = $json->decode( $data );

    if ( exists $data->{error} ) {
      $data->{response_code} = $rc;
      $data->{repsonse_code_message} = $message;
      return $data;
    }

    $cache->set( $url, $data );
  }

  $DB::single = 1;

  return $data;
} ## end sub get_json

#----------------------------------------------------------------------------

=head2 get_html

=over

=item Required: E<36>url

=item Optional: E<36>hashref of options to be passed to C<ManageMod::Cache>

=back

Get's the html from E<36>url and returns it as a dom object.

=cut

sub get_html {
  my ( $url, $cache_opts ) = @_;

  my $html_copts = clone( $cache_opts );
  $html_copts->{label}     //= __PACKAGE__;
  $html_copts->{namespace} //= 'html-data';

  my $cache = cache( $html_copts );
  my $d = $cache->get( $url );
  my $rc = 0;
  my $message = 'found in cache';

  unless ( defined $d ) {
    $log->debug('html cache expired or not there, freshening data');
    ( $d, $rc, $message ) = _get_url( $url, $cache_opts );

    if ( $rc != 200 ) {
      warn $log->info('Non 200 return code from url');
      return $d, $rc, $message;
    }

    $cache->set( $url, $d );
  }

  require HTML5::DOM;
  my $parser = HTML5::DOM->new;

  $log->warn( "Converting response content to dom object" );
  return $parser->parse( $d ), $rc, $message;
}

#----------------------------------------------------------------------------

=head2 get_jar

=over

=item Required: E<36>url E<36>file

=back

Get's a jar file from C<url> and saves it in C<file>.

=cut

sub get_jar {
  my ( $url, $file, $md5sum ) = @_;

  $log->debug('downloading jarfile');

  require LWP::Simple;
  LWP::Simple->import;
  my $rc = getstore( $url, $file );

  if ( is_error($rc) ) {
    warn $log->fatalf('Got error %s when trying to download %s', $rc, $url);
    return 0;
  }

  require Digest::MD5;

  if ( open my $fh, '<', $file ) {
    binmode ($fh);

    my $digest = Digest::MD5->new->addfile($fh)->hexdigest;

    if ( $digest ne $md5sum ) {
      warn $log->fatalf('md5sum for %s does not match expected md5sum', $file);
      return 0;
    }

    return 1;
  }

  warn $log->fatalf('Cannot open "%s": %s', $file, "$!");
  return 0;
}

#----------------------------------------------------------------------------

=head2 get_redirect

=over

=item Required: E<36>url E<36>file

=back

Get's the final url from a redirected url.

=cut

sub get_redirect {
  my ( $url ) = @_;

  require LWP::UserAgent;

  my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 1 } );
  $ua->agent($ENV{MANAGE_MOD_AGENT});

  my $header   = HTTP::Request->new( GET => $url );
  my $request  = HTTP::Request->new( 'GET', $url, $header );
  my $response = $ua->request( $request );

  if ( $response->code != 200 ) {
    warn $log->infof('Non 200 response code from $url (%s: %s)', $response->code, $response->message);
    return 0;
  }

  return $response->request->uri;
}

1;
