package GetMod;

use strict;
use warnings;

use base "Exporter::Tiny";

our @EXPORT = qw(get_mod);

use ManageMod::GetData;
use Log::Any '$log';

# Need MC version, mod name, channel

my $API_BASE_URL = 'https://api.cfwidget.com/mc-mods/minecraft';

sub get_mod {
  my ( $modname, $mc_version ) = @_;

  my $data = get_data("$API_BASE_URL/$modname");



}


#my $version_info = $data->{versions}->{$version};
