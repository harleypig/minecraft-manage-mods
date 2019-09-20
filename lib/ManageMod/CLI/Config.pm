package ManageMod::CLI::Config;

## no critic;

use base 'App::CLI::Command';

sub save {
  my ( $self ) = @_;
  $self->config->save;
}

1;
