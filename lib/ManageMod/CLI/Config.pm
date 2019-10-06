package ManageMod::CLI::Config;

## no critic;

use base 'App::CLI::Command';

use constant options => ( 'remove!' => 'remove' );

#use constant subcommands_todo => [qw( include mods )];

use List::MoreUtils qw( all any uniq );

our @valid_channels = qw( alpha beta release );

sub default_subcmd {
  my ( $self ) = @_;
  $self->{dumpconfig} = 1;
  return 1;
}

sub remove {
  my ( $self ) = @_;
  return defined $self->{remove} ? 1 : 0;
}

sub _remove_el {
  my ( $self, $el ) = @_;

  die "no extra parameters can be used with --remove, nothing removed"
    if @ARGV;

  $self->config->delete( $el );
  $self->{saveconfig} = 1;
  return 1;
}

sub _print_array {
  my ( $self, $array, $delim ) = @_;
  my $out = @$array ? join $delim, @$array : 'no value set';
  printf "%s\n", $out;
}

sub _validate_channels {
  my ( $self, $array ) = @_;

  my $valid = all {
    my $e = $_;
    any { /^$e$/ } @valid_channels;
  }
  @$array;

  @$array = uniq sort @$array;

  return $valid;
}

sub _validate_mods {
  my ( $self, $array ) = @_;
  @$array = uniq sort @$array;
}

sub _simple_handler {
  my ( $self, $el ) = @_;

  return $self->_remove_el( $el )
    if $self->remove;

  return printf "%s\n", $self->config->$el || 'no value set'
    unless @ARGV;

  my $value = shift @ARGV;
  $self->config->set( $el, $value );
  $self->{saveconfig} = 1;

  warn "extra parameters ignored\n"
    if @ARGV;

  return 0;
} ## end sub _simple_handler

sub _array_handler {
  my ( $self, $el ) = @_;

  unless ( @ARGV ) {
    my $array = $self->config->$el;

    die "$el is expected to be an array but is not"
      unless ref $array eq 'ARRAY';

    return $self->_remove_el( $el )
      if $self->remove;

    my $delim = $el == 'include' ? "\n" : ',';

    if ( my $can = $self->can( "_validate_$el" ) ) {
      $self->$can( $array ) || return 0;
    }

    $self->_print_array( $array, $delim );
    return 1;
  }

  my $array = $self->config->get_actual( $el ) || [];

  die "$el is expected to be an array but is not"
    unless ref $array eq 'ARRAY';

  if ( $self->remove ) {
    my @new = @$array;

    for my $arg ( @ARGV ) {
      @new = grep !/$arg/, @new;
    }

    $self->config->set( $el, \@new );
    $self->{saveconfig} = 1;

    return 1;

  } else {
    push @$array, @ARGV;

    if ( my $can = $self->can( "_validate_$el" ) ) {
      $self->$can( $array ) || return 0;
    }

    $self->config->set( $el, $array );
    $self->{saveconfig} = 1;

    return 1;
  }
} ## end sub _array_handler

sub channel   { $_[0]->_array_handler( 'channels' ) }
sub channels  { $_[0]->_array_handler( 'channels' ) }
sub dir       { $_[0]->_simple_handler( 'directory' ) }
sub directory { $_[0]->_simple_handler( 'directory' ) }
sub include   { $_[0]->_array_handler( 'include' ) }
sub includes  { $_[0]->_print_array( $_[0]->config->include, "\n" ) }
sub mcversion { $_[0]->_simple_handler( 'mcversion' ) }
sub mod       { $_[0]->_array_handler( 'mods' ) }
sub mods      { $_[0]->_array_handler( 'mods' ) }

1;
