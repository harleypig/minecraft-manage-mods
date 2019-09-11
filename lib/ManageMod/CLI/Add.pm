package ManageMod::CLI::Add;

## no critic;

use base 'App::CLI::Command';

#use constant options => (
#  'h|help' => 'help',
#  'verbose' => 'verbose',
#  'm|mod=s' => 'name',
#);

use constant subcommands => qw( Mod Shader Resource );

sub run {}
#sub run {
#  my ( $self, @args ) = @_;
#
#  print 'verbose' if $self->{verbose};
#}

1;
