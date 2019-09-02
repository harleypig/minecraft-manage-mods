package ManageMod::CurseForge;

## no critic

use strict;
use warnings;

use parent 'Exporter::Tiny';

## no critic Modules::ProhibitAutomaticExportation
our @EXPORT = qw(get_mod_data);

use Log::Any '$log';
use Time::Piece;
use Hash::Merge::Simple 'merge';

use ManageMod::GetData;
use ManageMod::Cache;
use Scalar::Util 'looks_like_number';

my $LOCAL_FILE_CACHE = "$ENV{MANAGE_MOD_CACHE_DIR}/files";

mkdir $LOCAL_FILE_CACHE
  unless -d $LOCAL_FILE_CACHE;

my $API_BASE_URL = 'https://api.cfwidget.com';
my $MAIN_CF_URL  = 'https://www.curseforge.com';
my $DL_BASE_URL  = 'https://media.forgecdn.net/files';

my $MOD_API1_URL = "$API_BASE_URL/minecraft/mc-mods";
my $MOD_API2_URL = "$API_BASE_URL/mc-mods/minecraft";

my $SCRAPE_URL = "$MAIN_CF_URL/minecraft";

my $MOD_BASE_URL = "$SCRAPE_URL/mc-mods";

my $IN_QUEUE_SLEEP    = 30;
my $IN_QUEUE_ATTEMPTS = 5;
my $RELATIONS_SLEEP   = 10;

##############################################################################
# Get information about mod.

# Utility sub

sub _array_check {
  my ( $arr, $check ) = @_;

  die 'must pass array ref to _array_check'
    unless ref $arr eq 'ARRAY';

  if ( @$arr > 1 ) {
    warn $log->infof( 'Unexpected %s count in base page, assuming first entry', $check );
    return undef;
  }

  if ( @$arr < 1 ) {
    warn $log->infof( 'No %s found, did they change things?', $check );
    return undef;
  }

  return 1;
} ## end sub _array_check

#-----------------------------------------------------------------------------
sub _get_api {
  my ( $mod ) = @_;

  my $api1_fail = 0;
  my $found     = 0;
  my $url       = "$MOD_API1_URL/$mod";
  my $data;

  for my $attempt ( 1 .. $IN_QUEUE_ATTEMPTS ) {
    $log->debug( "Attempt #$attempt ..." );

    $data = get_json( $url );

    return undef unless defined $data;

    $log->debug( $data );

    if ( exists $data->{error} ) {
      if ( $data->{error} eq 'in_queue' ) {
        warn $log->infof( 'Data request is pending, waiting for %s seconds before trying again.', $IN_QUEUE_SLEEP );
        sleep $IN_QUEUE_SLEEP;
        next;

      } elsif ( $data->{error} =~ /not_found|invalid_path/ ) {
        if ( !$api1_fail ) {
          $url = "$MOD_API2_URL/$mod";
          $api1_fail++;
          warn $log->infof( 'Trying %s', $url );
          sleep $IN_QUEUE_SLEEP;
          next;
        } else {
          warn $log->infof( '%s: %s', $data->{title}, $data->{message} );
          warn $log->infof( 'No results for %s found via api', $mod );
          last;
        }

      } else {
        warn $log->fatal( 'Unknown error, see log for details.' );
        last;
      }
    } ## end if ( exists $data->{error...})

    $found++;
    last;
  } ## end for my $attempt ( 1 .. ...)

  return $found ? $data : undef;
} ## end sub _get_api

#-----------------------------------------------------------------------------
# Fill in the blanks

sub _get_html {
  my ( $modname ) = @_;
  my $url = "$MOD_BASE_URL/$modname";

  my ( $html, $rc, $message ) = get_html( $url );

  if ( $rc != 200 ) {
    $log->fatalf( 'Status code was not 200: %s %s', $rc, $message );
    return undef;
  }

  my $data = { game => 'minecraft' };

  #----------------------------------------------------------------------
  # Span tags

  my $spans = $html->findTag( 'span' )->array;

  for ( my $i = 0 ; $i <= @$spans ; $i++ ) {
    if ( $spans->[$i]->innerText =~ /Project ID/ ) {
      my $id = $spans->[ $i + 1 ]->innerText;

      if ( looks_like_number( $id ) ) {
        $data->{id} = $id;
        last;
      }
    }
  }

  warn $log->infof( 'Could not find Project ID' )
    unless exists $data->{id};

  #----------------------------------------------------------------------
  # Property tags

  my $properties = $html->findAttr( 'property' )->array;

  for my $property ( @$properties ) {
    my $p = $property->attr( 'property' );
    my $c = $property->attr( 'content' );

    if    ( $p eq 'og:title' )        { $data->{title}       = $c }
    elsif ( $p eq 'og:descriptionh' ) { $data->{description} = $c }
    elsif ( $p eq 'og:url' )          { $data->{url}         = $c }
  }

  return $data;
} ## end sub _get_html

#-----------------------------------------------------------------------------
sub _base_info {
  my ( $modname ) = @_;

  my $json = _get_api( $modname );
  my $html = _get_html( $modname );

  return undef
    unless defined $json
    or defined $html;

  my $data = {};

  $data = merge( $data, $json )
    if defined $json;

  $data = merge( $data, $html )
    if defined $html;

  # Fix the timestamps and add urls in files and versions.
  for my $f ( @{ $data->{files} } ) {
    $f->{epoch} = Time::Piece->strptime( delete $f->{uploaded_at}, '%Y-%m-%dT%H:%M:%SZ' )->[9];

    # Sometimes the versions hash won't be duplicated in the the files hash,
    # so we have to do it there too.

    for my $version ( keys %{ $data->{versions} } ) {
      for my $f1 ( @{ $data->{versions}{$version} } ) {
        $f1->{epoch} = Time::Piece->strptime( delete $f1->{uploaded_at}, '%Y-%m-%dT%H:%M:%SZ' )->[9]
          if exists $f1->{uploaded_at};
      }
    }

    $f->{files_url} = "$MOD_BASE_URL/$modname/files/$f->{id}";

    for my $v ( @{ $f->{versions} } ) {
      my $ver = $data->{versions}{$v} //= [];
      push @$ver, $f;
    }
  } ## end for my $f ( @{ $data->{...}})

  return $data;
} ## end sub _base_info

##############################################################################
# Get information from files page.

sub _file_info {
  my ( $modname, $url ) = @_;

  my ( $html, $rc, $message ) = get_html( $url );

  if ( $rc != 200 ) {
    $log->fatalf( 'Status code was not 200: %s %s', $rc, $message );
    return undef;
  }

  my $data  = {};
  my $spans = $html->findTag( 'span' )->array;

  for ( my $i = 0 ; $i < @$spans ; $i++ ) {
    if ( $spans->[$i]->innerText =~ /MD5/ ) {
      $data->{md5sum} = $spans->[ $i + 1 ]->innerText;
    } elsif ( $spans->[$i]->innerText =~ /Filename/ ) {
      $data->{filename} = $spans->[ $i + 1 ]->innerText;
    }
  }

  return $data;
} ## end sub _file_info

##############################################################################
# Get information from relations pages.

sub _get_relations {
  my ( $relation_url ) = @_;

  #----------------------------------------------------------------------
  # CurseForge doesn't return an error when requesting a page that doesn't
  # exist, so we have to find out how many pages there are.

  my ( $html, $rc, $message ) = get_html( "${relation_url}1" );
  return 1 unless $rc == 200 || $rc == 0;

  my $pagelinks = $html->findClass( 'pagination-item' )->array;

  if ( @$pagelinks > 0 ) {
    warn $log->warn( "Haven't written code to handle multiple pages yet" );
    return undef;
  }

  my @relations = ();

  my $lis = $html->findClass( 'project-listing-row' )->array;

  return \@relations if @$lis < 1;

  for my $li ( @$lis ) {

    # This is fragile, but I don't see a better way at the moment.
    my $refs = $li->findTag( 'a' )->array;

    if ( @$refs < 1 ) {
      warn $log->warn( "Can't find dependency information for row $." );
      next;
    }

    ( my $ref = $refs->[0]->attr( 'href' ) ) =~ s#/minecraft/mc-mods/##;
    push @relations, $ref;
  }

  return \@relations;
} ## end sub _get_relations

##############################################################################
# Get information from dependencies page.

sub _get_dependencies {
  my ( $modname ) = @_;
  my $dependency_url = "$MOD_BASE_URL/$modname/relations/dependencies?page=";
  return _get_relations( $dependency_url );
}

##############################################################################
# Get information from dependencies page.

sub _get_dependents {
  my ( $modname ) = @_;
  my $dependent_url = "$MOD_BASE_URL/$modname/relations/dependents?page=";
  return _get_relations( $dependent_url );
}

##############################################################################

sub get_mod_data {
  my ( $modname, $mcversion, $channels ) = @_;

  die $log->fatalf( '%s expects a modname as the first parameter', ( caller( 0 ) )[3] )
    unless ref $modname eq '' && $modname ne '';

  die $log->fatalf( '%s expects a mcversion as the second parameter', ( caller( 0 ) )[3] )
    unless ref $mcversion eq '' && $mcversion ne '';

  die $log->fatalf( '%s expects a comma separated string of channels for the third parameter', ( caller( 0 ) )[3] )
    unless ref $channels eq '' && $channels ne '';

  $channels = 'alpha|beta|release' if $channels =~ /any/i;
  $channels = lc $channels;

  #$channels =~ s/,/|/g;
  $channels = join '|', sort split /[,|]/, $channels;

  my $cache_opts = {};

  $cache_opts->{label}     = __PACKAGE__;
  $cache_opts->{namespace} = 'data';

  my $cache_key = "$modname - $mcversion - $channels";

  my $cache = cache( $cache_opts );
  my $data  = $cache->get( $cache_key );

  if ( !defined $data ) {

    $log->debug( 'data cache expired or not there, freshening data' );

    $data = {
      'shortname' => $modname,
      'mcversion' => $mcversion,
      'channels'  => $channels,
      'updated'   => time,
    };

    my $base_info = _base_info( $modname );

    if ( !length $base_info ) {
      warn $log->fatalf( 'Unable to find any information about %s', $modname );
      return undef;
    }

    $data = merge $data, $base_info;

    if ( !exists $data->{versions}{$mcversion} ) {
      warn $log->fatalf( 'MC Version %s does not exist in data for %s', $mcversion, $modname );
      return undef;
    }

    # Too many requests, will get blocked.
    #$data = merge $data, _get_dependents( $modname );

    $data->{dependencies} = _get_dependencies( $modname );

    # Ignore channels (types) we aren't interested in, and sort the array so the
    # latest mod is the first element.

    my @v = sort { $b->{epoch} <=> $a->{epoch} }
      grep { $_->{type} =~ /^($channels)$/ } @{ $data->{versions}{$mcversion} };

    $data->{download} = $v[0];

    my $meta = _file_info( $modname, $v[0]->{files_url} );
    $v[0]->{md5sum}   = $meta->{md5sum};
    $v[0]->{filename} = $meta->{filename};

    $v[0]->{id} =~ /(\d{4})(\d+)/;
    my ( $p1, $p2 ) = ( $1, $2 );
    $p2 =~ s/^0+//;
    $v[0]->{download_url} = "$DL_BASE_URL/$p1/$p2/$v[0]->{filename}";
    $v[0]->{local_url}    = "$LOCAL_FILE_CACHE/$data->{download}{filename}";

    $cache->set( $cache_key, $data );
  } ## end if ( !defined $data )

  my $download_url = $data->{download}{download_url};
  my $local_url    = $data->{download}{local_url};
  my $md5sum       = $data->{download}{md5sum};

  get_file( $download_url, $local_url, $md5sum )
    or die "Couldn't get $data->{download}{filename}";

  return $data;
} ## end sub get_mod_data

1;
