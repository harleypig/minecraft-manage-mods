package ManageMod::GetModInfo;

use strict;
use warnings;

use parent "Exporter::Tiny";

our @EXPORT = qw(get_mod_info);

use Digest::MD5;
use Log::Any '$log';
use Time::Piece;

use ManageMod::GetData;
use ManageMod::Cache;

my $API_BASE_URL  = 'https://api.cfwidget.com/mc-mods/minecraft';
my $PROJECT_BASE_URL = 'https://minecraft.curseforge.com/projects';
my $FILE_BASE_URL = 'https://minecraft.curseforge.com/projects/%MODNAME%/files';
my $DL_BASE_URL   = 'https://www.curseforge.com/minecraft/mc-mods/jei/download/%MODID%/file';

sub _check_md5sum {
  my $filename = shift || "/etc/passwd";
  open (my $fh, '<', $filename) or die "Can't open '$filename': $!";
  binmode ($fh);

  print Digest::MD5->new->addfile($fh)->hexdigest, $filename;
}

sub get_mod_info {
  my ( $modname, $mc_version, $channels ) = @_;

  die $log->fatalf( '%s expects a modname as the first parameter', ( caller( 0 ) )[3] )
    unless ref $modname eq '' && $modname ne '';

  die $log->fatalf( '%s expects a mc_version as the second parameter', ( caller( 0 ) )[3] )
    unless ref $mc_version eq '' && $mc_version ne '';

  die $log->fatalf( '%s expects a comma separated string of channels for the third parameter', ( caller( 0 ) )[3] )
    unless ref $channels eq '' && $channels ne '';

  my $cache_opts = {};

  $cache_opts->{label}      = __PACKAGE__;
  $cache_opts->{namespace}  = 'modinfo';

  my $cache_key = "$modname - $mc_version - $channels";

  my $cache = cache( $cache_opts );
  my $modinfo  = $cache->get( $cache_key );

  return $modinfo if defined $modinfo;

  my $data = get_json( "$API_BASE_URL/$modname" );

  unless ( exists $data->{versions}{$mc_version} ) {
    warn $log->warnf( 'MC Version %s does not exist in data for %s', $mc_version, $modname );
    return 1;
  }

  $channels = 'alpha|beta|release' if $channels =~ /any/i;
  $channels = lc $channels;
  $channels =~ s/,/|/g;

  # Ignore channels (types) we aren't interested in, add an 'epoch' entry for
  # the 'uploaded_at' field and, finally, sort the array so the latest mod is
  # the first element.

  my @v = sort { $b->{epoch} <=> $a->{epoch} }
    map { $_->{epoch} = Time::Piece->strptime( $_->{uploaded_at}, '%Y-%m-%dT%H:%M:%SZ' )->epoch; $_ }
    grep { $_->{type} =~ /^($channels)$/ } @{ $data->{versions}{$mc_version} };

  $modinfo = {
    channels  => $channels,
    epoch     => $v[0]->{epoch},
    jarname   => $v[0]->{name},
    mcversion => $mc_version,
    modid     => $v[0]->{id},
    modname   => $modname,
    project   => "$PROJECT_BASE_URL/$modname",
    type      => $v[0]->{type},
  };

  my $file_info_url = $FILE_BASE_URL;
  $file_info_url =~ s/%MODNAME%/$modname/;
  $file_info_url .= "/$modinfo->{modid}";

  my $html = get_html( $file_info_url );

  my $md5sum   = $html->findClass( 'md5' )->text;

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

  $DB::single = 1;

  print '?';


} ## end sub get_mod

1;
