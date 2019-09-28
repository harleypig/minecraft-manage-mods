package ManageMod::CLI::Config;

## no critic;

use base 'App::CLI::Command';

use constant options => ( 'remove!' => 'remove' );

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

    $self->config->delete( 'mc_version' );

  } elsif ( @ARGV ) {
    my $mcv = shift @ARGV;
    $self->config->set( 'mc_version', $mcv );

    warn "extra parameters ignored\n"
      if @ARGV;

  } elsif ( $self->remove ) {

  } else {
    $self->{saveconfig} = 0;
    $self->{dumpconfig} = 0;

    printf "%s\n", $self->SUPER::mcversion;
  }
} ## end sub mcversion

1;
