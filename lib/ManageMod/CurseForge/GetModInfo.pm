package ManageMod::CurseForge::GetModInfo;

use strict;
use warnings;

use parent "Exporter::Tiny";

our @EXPORT = qw(get_mod_info);

use Log::Any '$log';
use Time::Piece;

use ManageMod::GetData;
use ManageMod::Cache;

my $API_BASE_URL     = 'https://api.cfwidget.com/mc-mods/minecraft';
my $PROJECT_BASE_URL = 'https://minecraft.curseforge.com/projects';
my $FILE_BASE_URL    = 'https://minecraft.curseforge.com/projects/%MODNAME%/files';
my $DL_BASE_URL      = 'https://www.curseforge.com/minecraft/mc-mods/jei/download/%MODID%/file';
my $IN_QUEUE_SLEEP   = 30;
my $RELATIONS_SLEEP  = 10;

##############################################################################
# Check moddata

my @required = qw(

  projectid

);

my @optional = qw(

categories created downloads issues last_released license license_url members
source

);

sub check_moddata {
  my ( $moddata ) = @_;

  if ( ref $moddata ne 'HASH' ) {
    warn $log->info('moddata is not a hash');
    return 0;
  }

  for my $o ( @optional ) {
    warn $log->infof('missing optional %s in moddata')
      unless exists $moddata->{$o};
  }

  my $required = 1;

  for my $r ( @required ) {
    if ( ! exists $moddata->{$r} ) {
      warn $log->info('missing required %s in moddata');
      $required = 0;
    }
  }

  return $required;
}

##############################################################################
# Get information from base page.

sub base_info {
  my ( $modname, $moddata ) = @_;

  $moddata //= {};

  if ( ref $moddata ne 'HASH' ) {
    warn $log->fatal('moddata must be a hash');
    return 0;
  }

  my $modurl = "$PROJECT_BASE_URL/$modname";
  my ( $html, $rc, $message ) = get_html( $modurl );
  return 1 unless $rc == 200 || $rc == 0;

  #----------------------------------------------------------------------
  # XXX: Handle errors

  #----------------------------------------------------------------------
  # Project License

  my $license = $html->findAttr('data-title', 'Project License')->array;

  warn $log->info('Unexpected Project License count in base page, assuming first entry')
    if @$license > 1;

  if ( @$license < 1 ) {
    warn $log->info('No Project License found in base page, did they change things?');

  } else {
    my $l = $license->[0];

    ( $moddata->{license} = $l->text ) =~ s/^\s*(.*?)\s*$/$1/;
    $moddata->{license_url} = $l->getAttribute('href');

    $moddata->{license_url} = "$modurl/license"
      if $moddata->{license_url} eq "/projects/$modname/license";
  }

  #----------------------------------------------------------------------
  # Categories

  my $categories = $html->findClass('project-categories')->array;

  warn $log->info('Unexpected Categories count in base page, assuming first entry')
    if @$categories > 1;

  if ( @$categories < 1 ) {
    warn $log->info('No Categories found in base page, did they change things?');

  } else {
    my $li = $categories->[0]->findTag('li')->array;

    if ( @$li < 1 ) {
      warn $log->info('No categorie found in list, did they change things?');

    } else {
      $moddata->{categories} //= ();

      push @{$moddata->{categories}}, $_->findTag('a')->array->[0]->getAttribute('title')
        for @$li;
    }
  }

  #----------------------------------------------------------------------
  # Members

  my $members = $html->findClass('project-members')->array;

  warn $log->info('Unexpected Project Members count in base page, did they change things?')
    if @$members > 1;

  if ( @$members < 1 ) {
    warn $log->info('No Members found in base page, did they change things?');

  } else {
    my $li = $members->[0]->findTag('li')->array;

    if ( @$li < 1 ) {
      warn $log->info('No members found in list, did they change things?');

    } else {
      $moddata->{members} //= ();

      for my $m ( @$li ) {
        ( my $member =  $m->findTag('a')->array->[0]->getAttribute('href') ) =~ s#/members/##;
        push @{$moddata->{members}}, $member;
      }
    }
  }

  #----------------------------------------------------------------------
  # Issues and Source

  my $links = $html->findTag('a')->array;

  for my $a ( @$links ) {
    $moddata->{issues} = $a->getAttribute('href')
      if $a->text =~ /Issues/i;

    $moddata->{source} = $a->getAttribute('href')
      if $a->text =~ /Source/i;
  }

  #----------------------------------------------------------------------
  # Project ID, Downloads, etc.

  my $info  = $html->findClass('info-label')->array;

  warn $log->info('No info label entries found in base page, did they change things?')
    if @$info < 1;

  for my $l ( @$info ) {
    $moddata->{projectid} = $l->next->text
      if $l->text =~ /Project\s+ID/i;

    ( $moddata->{downloads} = $l->next->text ) =~ s/\D//g
      if $l->text =~ /Total\s+Downloads/i;

    $moddata->{created} = $l->next->firstChild->getAttribute('data-epoch')
      if $l->text =~ /Created/i;

    $moddata->{last_released} = $l->next->firstChild->getAttribute('data-epoch')
      if $l->text =~ /Last\s+Released\s+File/i;
  }

  my $type = $html->findClass('RootGameCategory')->array;

  warn $log->info('Unexpected type count in base page, assuming first entry')
    if @$type > 1;

  if ( @$type < 1 ) {
    warn $log->info('No type found, did they change things?');

  } else {
    ( $moddata->{type} = $type->[0]->text ) =~ s/^\s*(.*?)\s*$/$1/;
  }

  my $desc = $html->findClass('project-description')->array;

  warn $log->info('Unexpected description count in base page, assuming first entry')
    if @$desc > 1;

  if ( @$desc < 1 ) {
    warn $log->info('No description found, did they change things?');

  } else {
    $moddata->{description} = $desc->[0]->text;
  }
}

##############################################################################
# Get information from files page.

##############################################################################
# Get information from relations pages.

sub _get_relations {
  my ( $relation_url ) = @_;

  #----------------------------------------------------------------------
  # CurseForge doesn't return an error when requesting a page that doesn't
  # exist, so we have to find out how many pages there are.

  my ( $html, $rc, $message ) = get_html("${relation_url}1");
  return 1 unless $rc == 200 || $rc == 0;

  my $pagelinks = $html->findClass('b-pagination-item')->array;
  my $maxpages  = 1;

  for my $p ( @$pagelinks ) {
    my $links = $p->findTag('a')->array;

    for my $a ( @$links ) {
      my $p = $a->getAttribute('href');
      next unless $p =~ /^.*page=(\d+)$/;
      my $pn = $1;
      $maxpages = $pn if $pn > $maxpages;
    }
  }

  my @relations = ();

  for my $p ( 1 .. $maxpages ) {
    my $lis = $html->findClass('project-list-item')->array;

    next if @$lis < 1;

    for my $li ( @$lis ) {
      my $pli = {};

      # Project and Name
      # This is fragile, but there's not really a better way at the moment.
      my $p = $li->findTag('a')->array->[1];
      ( $pli->{project} = $p->getAttribute('href') ) =~ s#^.*/##;
      ( $pli->{name} = $p->text ) =~ s/^\s*(.*?)\s*$/$1/;

      push @relations, { %$pli };
    }

    if ( $p > 1 ) {
      if ( $rc != 0 ) {
        $log->infof('Waiting %s second before getting page %s', $RELATIONS_SLEEP, $p);
        sleep $RELATIONS_SLEEP;
      }

      ( $html, $rc, $message ) = get_html("${relation_url}$p");
      return 1 unless $rc == 200 || $rc == 0;
    }
  }

  return \@relations;
}

##############################################################################
# Get information from dependencies page.

sub get_dependencies {
  my ( $modname, $moddata ) = @_;

  $moddata //= {};

  if ( ref $moddata ne 'HASH' ) {
    warn $log->fatal('moddata is not a hash ref');
    return 0;
  }

  my $dependency_url = "$PROJECT_BASE_URL/$modname/relations/dependencies?page=";

  $moddata->{dependencies} = _get_relations($dependency_url);

  return 0;
}

##############################################################################
# Get information from dependencies page.

sub get_dependents {
  my ( $modname, $moddata ) = @_;

  $moddata //= {};

  if ( ref $moddata ne 'HASH' ) {
    warn $log->fatal('moddata is not a hash ref');
    return 0;
  }

  my $dependent_url = "$PROJECT_BASE_URL/$modname/relations/dependents?page=";

  $moddata->{dependents} = _get_relations($dependent_url);

  return 0;
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

  # XXX: Cache this!
  my $moddata = { 'updated' => time };

  base_info( $modname, $moddata );
  get_dependents( $modname, $moddata );
  get_dependencies( $modname, $moddata );
  my $gooddata = check_moddata( $moddata );
  $DB::single = 1;
  print '?';

  my $cache_opts = {};

  $cache_opts->{label}      = __PACKAGE__;
  $cache_opts->{namespace}  = 'modinfo';

  my $cache_key = "$modname - $mcversion - $channels";

  my $cache = cache( $cache_opts );
  my $modinfo  = $cache->get( $cache_key );

  return $modinfo if defined $modinfo;

  $log->debug('modinfo cache expired or not there, freshening data');

  my $data = get_json( "$API_BASE_URL/$modname" );

  if ( exists $data->{error} ) {
    $log->info($data);

    if ( $data->{error} eq 'in_queue' ) {
      warn $log->infof('Data request is pending, waiting for %s seconds before trying again.', $IN_QUEUE_SLEEP);
      sleep $IN_QUEUE_SLEEP;
      $data = get_json( "$API_BASE_URL/$modname" );

      if ( exists $data->{error} ) {
        warn $log->info('Data request is still pending, giving up.');
        return 1;
      }

    } elsif ( $data->{error} =~ /not_found|invalid_path/ ) {
      warn $log->infof('%s: %s', $data->{title}, $data->{message});
      return 1;

    } else {
      warn $log->fatal('Unknown error, see log for details.');
      return 1;
    }
  }

  die $log->fatalf( 'MC Version %s does not exist in data for %s', $mcversion, $modname )
    unless exists $data->{versions}{$mcversion};

  $channels = 'alpha|beta|release' if $channels =~ /any/i;
  $channels = lc $channels;
  $channels =~ s/,/|/g;

  # Ignore channels (types) we aren't interested in, add an 'epoch' entry for
  # the 'uploaded_at' field and, finally, sort the array so the latest mod is
  # the first element.

  my @v = sort { $b->{epoch} <=> $a->{epoch} }
    map { $_->{epoch} = Time::Piece->strptime( $_->{uploaded_at}, '%Y-%m-%dT%H:%M:%SZ' )->epoch; $_ }
    grep { $_->{type} =~ /^($channels)$/ } @{ $data->{versions}{$mcversion} };

  $modinfo = {
    channels  => $channels,
    epoch     => $v[0]->{epoch},
    jarname   => $v[0]->{name},
    mcversion => $mcversion,
    modid     => $v[0]->{id},
    modname   => $modname,
    project   => "$PROJECT_BASE_URL/$modname",
    type      => $v[0]->{type},
  };

  my $file_info_url = $FILE_BASE_URL;
  $file_info_url =~ s/%MODNAME%/$modname/;
  $file_info_url .= "/$modinfo->{modid}";

  my ( $html, $rc, $message ) = get_html( $file_info_url );
  return 1 unless $rc == 200 || $rc == 0;

  my $md5sum = $html->findClass( 'md5' )->text;

  die $log->fatalf( 'Could not find md5sum on files page for %s', $modname )
    if $md5sum eq '';

  my $label    = $html->findClass( 'info-label' )->array;
  my $filename = '';

  for my $l ( @$label ) {
    if ( $l->text eq 'Filename' ) {
      $filename = $l->next->text;
      last;
    }
  }

  die $log->fatalf( 'Could not find filename on files page for %s', $modname )
    if $filename eq '';

  my $download_url = "$file_info_url/download";

  $modinfo->{md5sum} = $md5sum;
  $modinfo->{download} = $download_url;

  $cache->set( $cache_key, $modinfo );

  return $modinfo;
} ## end sub get_mod

1;
