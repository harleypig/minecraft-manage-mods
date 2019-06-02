package ManageMod::CurseForge::GetModInfo;

use strict;
use warnings;

use parent 'Exporter::Tiny';

## no critic Modules::ProhibitAutomaticExportation
our @EXPORT = qw(get_mod_info);

use Log::Any '$log';
use Time::Piece;

use Hash::Merge::Simple 'merge';
use ManageMod::GetData;
use ManageMod::Cache;

# Try these urls for mods, in order:
#   https://api.cfwidget.com/minecraft/mc-mods/<project> (JSON)
#   https://api.cfwidget.com/mc-mods/minecraft/<project> (JSON)
#   https://minecraft.curseforge.com/projets/<project> (Scrape)
#   https://www.curseforge.com/minecraft/mc-mods/<project> (Scrape?)

# ???: Does the same hold true for modpacks and texturepacks? (mod-packs? texture-packs?)

my $API_BASE_URL = 'https://api.cfwidget.com';
my $GAME_CF_URL  = 'https://minecraft.curseforge.com';
my $MAIN_CF_URL  = 'https://www.curseforge.com';

my $MOD_API1_URL = "$API_BASE_URL/minecraft/mc-mods";
my $MOD_API2_URL = "$API_BASE_URL/mc-mods/minecraft";

my $SCRAPE_URL1 = "$GAME_CF_URL/projects";
my $SCRAPE_URL2 = "$MAIN_CF_URL/projects";

my $PROJECT_BASE_URL = $SCRAPE_URL1;

my $IN_QUEUE_SLEEP    = 30;
my $IN_QUEUE_ATTEMPTS = 3;
my $RELATIONS_SLEEP   = 10;

###############################################################################
## Check moddata
#
#my @required = qw(
#
#  projectid
#
#);
#
#my @optional = qw(
#
#categories created downloads issues last_released license license_url members
#source
#
#);
#
#sub _check_moddata {
#  my ( $moddata ) = @_;
#
#  if ( ref $moddata ne 'HASH' ) {
#    warn $log->info('moddata is not a hash');
#    return 0;
#  }
#
#  for my $o ( @optional ) {
#    warn $log->infof('missing optional %s in moddata')
#      unless exists $moddata->{$o};
#  }
#
#  my $required = 1;
#
#  for my $r ( @required ) {
#    if ( ! exists $moddata->{$r} ) {
#      warn $log->info('missing required %s in moddata');
#      $required = 0;
#    }
#  }
#
#  return $required;
#}

##############################################################################
# Get information about mod.

# Utility sub

sub _array_check {
  my ( $arr, $check ) = @_;

  die 'must pass array ref to _array_check'
    unless ref $arr eq 'ARRAY';

  if ( @$arr > 1 ) {
    warn $log->infof( 'Unexpected %s count in base page, assuming first entry', $check );
    return 0;
  }

  if ( @$arr < 1 ) {
    warn $log->infof( 'No %s found, did they change things?', $check );
    return 0;
  }

  return 1;
} ## end sub _array_check

# Try MOD_API1_URL, then MOD_API2_URL, then try to find and scrape the project page.
# Ultimately, we want to normalize the basic information from this sub.

#-----------------------------------------------------------------------------
sub _get_api {
  my ( $url ) = @_;

  my $data;
  my $found = 0;

  for my $attempt ( 1 .. $IN_QUEUE_ATTEMPTS ) {
    $log->debug( "Attempt #$attempt ..." );

    $data = get_json( $url );
    $log->debug( $data );

    if ( exists $data->{error} ) {
      if ( $data->{error} eq 'in_queue' ) {
        warn $log->infof( 'Data request is pending, waiting for %s seconds before trying again.', $IN_QUEUE_SLEEP );
        sleep $IN_QUEUE_SLEEP;
        next;

      } elsif ( $data->{error} =~ /not_found|invalid_path/ ) {
        warn $log->infof( '%s: %s', $data->{title}, $data->{message} );
        last;

      } else {
        warn $log->fatal( 'Unknown error, see log for details.' );
        last;
      }
    }

    $found++;
    last;
  } ## end for my $attempt ( 1 .. ...)

  return $found ? $data : 0;
} ## end sub _get_api

#-----------------------------------------------------------------------------
# Fill in the blanks

sub _get_html {
  my ( $modname ) = @_;
  my $url = "$PROJECT_BASE_URL/$modname";

  my ( $html, $rc, $message ) = get_html( $url );

  if ( $rc != 200 ) {
    $log->fatalf( 'Status code was not 200: %s %s', $rc, $message );
    return 0;
  }

  my $data = { game => 'minecraft' };

  # download - Don't care about what the page has as the latest download link.
  # We'll figure out what to download later.

  # files - We'll have to revisit this later if it becomes necessary.

  # urls - All urls are going into links key.

  # donate - haven't seen this yet.

  # versions - If this is really needed, we can generate it from the files
  # pages.

  #----------------------------------------------------------------------
  # About This Project
  # Project ID, Downloads, Created, Last Released
  my $info = $html->findClass( 'info-label' )->array;

  warn $log->info( 'No info label entries found in base page, did they change things?' )
    if @$info < 1;

  for my $l ( @$info ) {
    $data->{id} = $l->next->text
      if $l->text =~ /Project\s+ID/i;

    ( $data->{downloads} = $l->next->text ) =~ s/\D//g
      if $l->text =~ /Total\s+Downloads/i;

    $data->{created} = $l->next->firstChild->getAttribute( 'data-epoch' )
      if $l->text =~ /Created/i;
  }

  #----------------------------------------------------------------------
  # Title
  my $title = $html->findAttr( 'property', 'og:title' )->array;

  $data->{title} = $title->[0]->attr( 'content' )
    if _array_check( $title, 'title' );

  #----------------------------------------------------------------------
  # Description
  my $desc = $html->findClass( 'project-description' )->array;

  ( $data->{description} = $desc->[0]->text ) =~ s/^\s+(.*?)\s+$/$1/
    if _array_check( $desc, 'description' );

  #----------------------------------------------------------------------
  # Type (Mods, Resource Pack, Texture Pack)
  my $type = $html->findClass( 'RootGameCategory' )->array;

  ( $data->{type} = $type->[0]->text ) =~ s/^\s*(.*?)\s*$/\L$1/
    if _array_check( $type, 'type' );

  #----------------------------------------------------------------------
  # Issues and Source
  my $links = $html->findTag( 'a' )->array;

  for my $a ( @$links ) {
    $data->{links}{issues} = $a->getAttribute( 'href' )
      if $a->text =~ /Issues/i;

    $data->{links}{source} = $a->getAttribute( 'href' )
      if $a->text =~ /Source/i;
  }

  #----------------------------------------------------------------------
  # Project URL
  my $project_url = $html->findAttr( 'property', 'og:url' )->array;

  $data->{links}{project} = $project_url->[0]->attr( 'content' )
    if _array_check( $project_url, 'project url' );

  #----------------------------------------------------------------------
  # CurseForge URL
  my $cf_url = $html->findClass( 'view-on-curse' )->array;

  $data->{links}{curseforge} = $cf_url->[0]->findTag( 'a' )->array->[0]->attr( 'href' )
    if _array_check( $cf_url, 'view-on-curse' );

  #----------------------------------------------------------------------
  # Thumbnail

  my $thumb = $html->findClass( 'e-avatar64' )->array;

  $data->{links}{thumbnail} = $thumb->[0]->attr( 'href' )
    if _array_check( $thumb, 'thumbnail' );

  #----------------------------------------------------------------------
  # Project License

  my $license = $html->findAttr( 'data-title', 'Project License' )->array;

  if ( _array_check( $license, 'license' ) ) {
    my $l = $license->[0];

    my $license_text;
    ( $license_text = $l->text ) =~ s/^\s*(.*?)\s*$/$1/;

    my $license_url = $l->attr( 'href' );

    if ( $license_url =~ m#^/# ) {
      $license_url = "$GAME_CF_URL$license_url";

    } elsif ( $license_url !~ /^https?/ ) {
      $license_url = "${data}{links}{project}/$license_url";
    }

    $data->{license}{$license_text} = $license_url;
  }

  #----------------------------------------------------------------------
  # Categories

  my $categories = $html->findClass( 'project-categories' )->array;

  if ( _array_check( $categories, 'categories' ) ) {
    my $li = $categories->[0]->findTag( 'li' )->array;

    if ( @$li < 1 ) {
      warn $log->info( 'No categories found in list, did they change things?' );

    } else {
      $data->{categories} //= ();
      push @{ $data->{categories} }, $_->findTag( 'a' )->array->[0]->attr( 'title' ) for @$li;
    }
  }

  #----------------------------------------------------------------------
  # Members

  my $members = $html->findClass( 'project-members' )->array;

  if ( _array_check( $members, 'members' ) ) {
    my $li = $members->[0]->findTag( 'li' )->array;

    if ( @$li < 1 ) {
      warn $log->info( 'No members found in list, did they change things?' );

    } else {
      $data->{members} //= ();

      for my $m ( @$li ) {
        ( my $member = $m->findTag( 'a' )->array->[0]->getAttribute( 'href' ) ) =~ s#/members/##;
        push @{ $data->{members} }, $member;
      }
    }
  }

  return $data;
} ## end sub _get_html

#-----------------------------------------------------------------------------
sub _base_info {
  my ( $modname ) = @_;

  # Try MOD_API1_URL first.
  my $json = _get_api( "$MOD_API1_URL/$modname" )
    or return 0;

  # XXX: Handle api2 here ...

  # Get missing data.
  my $missing = _get_html( $modname )
    or return 0;

  my $data = merge $json, $missing;

  my @cleanup = qw(
    created_at
    download
    thumbnail
    urls
    versions
  );

  delete $data->{$_} for @cleanup;

  # Fix the timestamps and add urls in files and versions.
  for my $f ( @{ $data->{files} } ) {
    $f->{epoch}        = Time::Piece->strptime( delete $f->{uploaded_at}, '%Y-%m-%dT%H:%M:%SZ' )->[9];
    $f->{files_url}    = "$PROJECT_BASE_URL/$modname/files/$f->{id}";
    $f->{download_url} = "$f->{files_url}/download";

    for my $v ( @{ $f->{versions} } ) {
      my $ver = $data->{versions}{$v} //= [];
      push @$ver, $f;
    }
  }

  return $data;
} ## end sub _base_info

##############################################################################
# Get information from files page.

sub _file_info {
  my ( $modname, $url ) = @_;

  my ( $html, $rc, $message ) = get_html( $url );

  if ( $rc != 200 ) {
    $log->fatalf( 'Status code was not 200: %s %s', $rc, $message );
    return 0;
  }

  my $md5sum = $html->findClass( 'md5' )->text;

  if ( $md5sum eq '' ) {
    $log->fatalf( 'Could not find md5sum on files page for %s', $modname );
    return 0;
  }

  my $label    = $html->findClass( 'info-label' )->array;
  my $filename = '';

  for my $l ( @$label ) {
    if ( $l->text eq 'Filename' ) {
      $filename = $l->next->text;
      last;
    }
  }

  if ( $filename eq '' ) {
    $log->fatalf( 'Could not find filename on files page for %s', $modname );
    return 0;
  }

  my $data = {};

  $data->{md5sum}   = $md5sum;
  $data->{filename} = $filename;

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

  my $pagelinks = $html->findClass( 'b-pagination-item' )->array;
  my $maxpages  = 1;

  for my $p ( @$pagelinks ) {
    my $links = $p->findTag( 'a' )->array;

    for my $a ( @$links ) {
      my $p = $a->getAttribute( 'href' );
      next unless $p =~ /^.*page=(\d+)$/;
      my $pn = $1;
      $maxpages = $pn if $pn > $maxpages;
    }
  }

  my @relations = ();

  for my $p ( 1 .. $maxpages ) {
    my $lis = $html->findClass( 'project-list-item' )->array;

    next if @$lis < 1;

    for my $li ( @$lis ) {
      my $pli = {};

      # Project and Name
      # This is fragile, but there's not really a better way at the moment.
      my $p = $li->findTag( 'a' )->array->[1];
      ( $pli->{project} = $p->getAttribute( 'href' ) ) =~ s#^.*/##;
      ( $pli->{name}    = $p->text ) =~ s/^\s*(.*?)\s*$/$1/;

      push @relations, {%$pli};
    }

    if ( $p > 1 ) {
      if ( $rc != 0 ) {
        $log->infof( 'Waiting %s second before getting page %s', $RELATIONS_SLEEP, $p );
        sleep $RELATIONS_SLEEP;
      }

      ( $html, $rc, $message ) = get_html( "${relation_url}$p" );
      return 1 unless $rc == 200 || $rc == 0;
    }
  } ## end for my $p ( 1 .. $maxpages)

  return \@relations;
} ## end sub _get_relations

##############################################################################
# Get information from dependencies page.

sub _get_dependencies {
  my ( $modname ) = @_;
  my $dependency_url = "$PROJECT_BASE_URL/$modname/relations/dependencies?page=";
  return _get_relations( $dependency_url );
}

##############################################################################
# Get information from dependencies page.

sub _get_dependents {
  my ( $modname ) = @_;
  my $dependent_url = "$PROJECT_BASE_URL/$modname/relations/dependents?page=";
  return _get_relations( $dependent_url );
}

##############################################################################

sub get_mod_info {
  my ( $modname, $mcversion, $channels ) = @_;

  die $log->fatalf( '%s expects a modname as the first parameter', ( caller( 0 ) )[3] )
    unless ref $modname eq '' && $modname ne '';

  die $log->fatalf( '%s expects a mcversion as the second parameter', ( caller( 0 ) )[3] )
    unless ref $mcversion eq '' && $mcversion ne '';

  die $log->fatalf( '%s expects a comma separated string of channels for the third parameter', ( caller( 0 ) )[3] )
    unless ref $channels eq '' && $channels ne '';

  $channels = 'alpha|beta|release' if $channels =~ /any/i;
  $channels = lc $channels;
  $channels =~ s/,/|/g;

  my $cache_opts = {};

  $cache_opts->{label}     = __PACKAGE__;
  $cache_opts->{namespace} = 'data';

  my $cache_key = "$modname - $mcversion - $channels";

  my $cache = cache( $cache_opts );
  my $data  = $cache->get( $cache_key );

  return $data if defined $data;

  $log->debug( 'data cache expired or not there, freshening data' );

  $data = {
    'shortname' => $modname,
    'mcversion' => $mcversion,
    'channels'  => $channels,
    'updated'   => time,
  };

  $data = merge $data, _base_info( $modname );

  die $log->fatalf( 'MC Version %s does not exist in data for %s', $mcversion, $modname )
    unless exists $data->{versions}{$mcversion};

  # Too many requests, will get blocked.
  #$data = merge $data, _get_dependents( $modname );

  $data->{dependencies} = _get_dependencies( $modname );

  # Ignore channels (types) we aren't interested in, and sort the array so the
  # latest mod is the first element.

  my @v = sort { $b->{epoch} <=> $a->{epoch} }
    grep { $_->{type} =~ /^($channels)$/ } @{ $data->{versions}{$mcversion} };

  $data->{download} = $v[0];

  my $meta = _file_info( $modname, $v[0]->{files_url} );
  $v[0]->{md5}      = $meta->{md5};
  $v[0]->{filename} = $meta->{filename};

  $cache->set( $cache_key, $data );

  return $data;
} ## end sub get_mod_info

1;
