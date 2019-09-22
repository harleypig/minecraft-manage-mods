package ManageMod::CLI::Config;

## no critic;

use base 'App::CLI::Command';

use constant options => (

);

sub default_subcmd {
  my ( $self ) = @_;
  $self->{dumpconfig} = 1;
  return 1;
}

sub mcversion {
  my ( $self ) = @_;
  $DB::single++;
  print '?';
}

1;
