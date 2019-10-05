package ManageMod::CLI::Config;

## no critic;

use base 'App::CLI::Command';

use constant options => ( 'remove!' => 'remove' );
use constant subcommands_todo => [qw( include mods directory )];

sub default_subcmd {
  my ( $self ) = @_;
  $self->{dumpconfig} = 1;
  return 1;
}

sub remove {
  my ( $self ) = @_;
  return defined $self->{remove} ? 1 : 0;
}

sub mcversion {
  my ( $self ) = @_;

  if ( $self->remove ) {
    die "no extra parameters can be used with --remove, nothing removed\n"
      if @ARGV;

    $self->config->delete( 'mcversion' );
    return 1;

  } elsif ( @ARGV ) {
    my $mcv = shift @ARGV;
    $self->config->set( 'mcversion', $mcv );

    warn "extra parameters ignored\n"
      if @ARGV;

    return 0;

  } else {
    printf "%s\n", $self->config->mcversion;
  }
} ## end sub mcversion

sub channels {
  # remove one or more channels
  # add one or more channels
}

1;
