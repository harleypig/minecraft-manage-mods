package ManageMod::CLI::Set::Mcversion;

## no critic;

use base 'App::CLI::Command';

sub mcversion {
  my ( $self, $ver ) = @_;
  $DB::single=1;
  $self->config->set_mc_version($ver);
  print '?';
}

1;
