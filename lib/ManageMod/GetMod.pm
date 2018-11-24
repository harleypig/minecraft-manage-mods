## Please see file perltidy.ERR
package ManageMod::GetMod;

use strict;
use warnings;

use parent "Exporter::Tiny";

our @EXPORT = qw(get_mod);

use Log::Any '$log';
use Time::Piece;

use ManageMod::GetData;

my $API_BASE_URL  = 'https://api.cfwidget.com/mc-mods/minecraft';
my $FILE_BASE_URL = 'https://minecraft.curseforge.com/projects/%MODNAME%/files';

sub get_mod {
  my ( $modname, $mc_version, $channel ) = @_;

  die $log->fatalf( '%s expects a modname as the first parameter', ( caller( 0 ) )[3] )
    unless ref $modname eq '' && $modname ne '';

  die $log->fatalf( '%s expects a mc_version as the second parameter', ( caller( 0 ) )[3] )
    unless ref $mc_version eq '' && $mc_version ne '';

  die $log->fatalf( '%s expects a comma separated string of channels for the third parameter', ( caller( 0 ) )[3] )
    unless ref $channel eq '' && $channel ne '';

  my $data = get_json( "$API_BASE_URL/$modname", { namespace => 'cf_mc_projects' } );

  warn $log->warnf( 'MC Version %s does not exist in data for %s', $mc_version, $modname )
    unless exists $data->{versions}{$mc_version};

  $channel =~ s/,/|/g;

  # Ignore channels (types) we aren't interested in, add an 'epoch' entry for
  # the 'uploaded_at' field and, finally, sort the array so the latest mod is
  # the first element.

  my @v = sort { $b->{epoch} <=> $a->{epoch} }
    map { $_->{epoch} = Time::Piece->strptime( $_->{uploaded_at}, '%Y-%m-%dT%H:%M:%SZ' )->epoch; $_ }
    grep { $_->{type} =~ /^($channel)$/ } @{ $data->{versions}{$mc_version} };

  my $modid = $v[0]->{id};

  my $file_info_url = $FILE_BASE_URL;
  $file_info_url =~ s/%MODNAME%/$modname/;
  $file_info_url .= "/$modid";

  my $html = get_html( $file_info_url );

  $DB::single = 1;

  my $md5sum = $html->findClass( 'md5' )->text;
  my @label  = $html->findClass( 'info-label' )->array;
  my $filename = ''

  for my $l ( @label ) {
    if ( $l->text eq 'Filename' ) {
      $filename = $l->next->text;
      last;
    }
  }

  die $log->fatalf( 'Could not find filename on files page for %s', $modname )
    if $filename eq '';

  my $download_url = "$file_info_url/download";

} ## end sub get_mod

1;
