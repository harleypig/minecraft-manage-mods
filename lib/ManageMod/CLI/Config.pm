package ManageMod::CLI::Config;

## no critic;

use base 'App::CLI::Command';

#use constant subcommands => qw( Create );

sub save {
  my ( $self ) = @_;
  $self->config->save;
}

1;
