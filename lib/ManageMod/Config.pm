package ManageMod::Config;

## no critic

use strictures 2;
use namespace::clean;

#use YAML::Syck qw( LoadFile DumpFile );
use YAML::XS qw( LoadFile DumpFile Dump );
use Hash::Merge;
use List::MoreUtils qw( any uniq );
use Log::Any '$log';

$YAML::XS::Boolean = 'JSON::PP';
$YAML::XS::Indent  = 2;

our @supported_mcversions = qw(
  1.12 1.12.2
);

our $new_default = {
  _config_modified      => undef,
  _supported_mcversions => \@supported_mcversions,

  _default_config => {
    channels  => [],
    directory => undef,
    include   => [],
    mcversion => undef,
    mods      => [],
  } };

##############################################################################
sub new {
  my ( $class, $args ) = @_;

  die 'new for ManageMod::Config requires hash ref'
    if defined $args && ref $args ne 'HASH';

  $args //= {};

  my $self = bless Hash::Merge::merge( $new_default, $args ), $class;

  $self->_load_config( $self->configfile );
  $self->_merge_configs;

  return $self;
}

sub configfile     { $_[0]->{configfile} }
sub default_config { $_[0]->{_default_config} || {} }
sub dump           { print Dump $_[0]->{config} }
sub mcversions     { $_[0]->{_supported_mcversions} }
sub modified       { defined $_[0]->{_config_modified} ? 1 : undef }
sub msg            { $_[0]->{_msg} }

# XXX: ???
sub include { $_[0]->{_configs}[0]{include} || [] }

##############################################################################
# Methods

#  mods      => [],
#  channels  => [],
#  include   => [],

sub save {
  my ( $self ) = @_;
  DumpFile( $self->configfile, $self->{_configs}[0] );
  warn sprintf "%s saved\n", $self->configfile;
  $self->{_config_modified} = 0;
  return 1;
}

# XXX: Autoload?
sub mcversion { shift->_string_handler( 'mcversion', @_ ) }
sub directory { shift->_string_handler( 'directory', @_ ) }
sub channels  { shift->_array_handler('channels', @_) }

sub _validate_mcversion {
  my $t = $_[1]; return any { /^$t$/ } @{ $_[0]->mcversions };
}

##############################################################################
# Convenience methods

our $AUTOLOAD;

AUTOLOAD {
  ( my $method = $AUTOLOAD ) =~ s/^.*:://;

  my ( $self ) = @_;

  die "$method is not a valid config method"
    unless exists $self->{config}{$method};

  return $self->{config}{$method};
}

DESTROY { }

##############################################################################
# Config Utilities

sub _load_config {
  my ( $self, $filename, $configfile ) = @_;

  die "No config file passed.\n"
    unless defined $filename && $filename ne '';

  if ( !-r $filename ) {
    no warnings 'uninitialized';
    $configfile = " (referenced in $configfile)" if $configfile;
    warn "$filename$configfile does not exist or is not readable\n";
    return undef;
  }

  die 'bad configs key'
    if exists $self->{_configs} && ref $self->{_configs} ne 'ARRAY';

  $self->{_configs} //= [];

  my $newcfg = LoadFile( $filename );
  push @{ $self->{_configs} }, $newcfg;

  if ( exists $newcfg->{include} ) {
    die "include must be an array in $filename\n"
      unless ref $newcfg->{include} eq 'ARRAY';

    for my $if ( @{ $newcfg->{include} } ) {
      if ( !defined $if || $if eq '' ) {
        warn "empty includes don't make sense (in $filename)\n";
        continue;
      }

      $self->_load_config( $_, $filename );
    }
  }

  return 1;
} ## end sub _load_config

#-----------------------------------------------------------------------------
sub _merge_configs {
  my ( $self ) = @_;

  die 'bad configs key'
    if exists $self->{_configs} && ref $self->{_configs} ne 'ARRAY';

  $self->{_configs} //= [];

  my $config = { %{ $self->default_config } };

  my $m = Hash::Merge->new( 'RIGHT_PRECEDENT' );

  for my $c ( reverse @{ $self->{_configs} } ) {

    # In all cases, except channels, we want arrays to be merged. This is the
    # default behavior of 'merge'. We de-duplicate those arrays below. So, get
    # rid of existing channels if that entry exists in the new config.
    delete $config->{channels} if exists $c->{channels};

    $config = $m->merge( $config, $c );
  }

  # We don't need to keep track of the include files here.
  delete $config->{include};

  # De-duplicate and sort mods list
  $config->{mods} = [ uniq sort @{ $config->{mods} } ];

  $self->{config} = $config;

  return 1;
} ## end sub _merge_configs

##############################################################################
# Element Utilities

sub _el_get { return $_[0]->{config}{ $_[1] } || 'no value set' }

sub _el_del {
  my ( $self, $name ) = @_;
  delete $self->{_configs}[0]{$name};
  $self->_merge_configs;
  $self->{_config_modified} = 1;
  $self->{_msg}             = "$name was deleted";
  return 1;
}

sub _el_set {
  my ( $self, $name, $value ) = @_;
  $self->{_configs}[0]{$name} = $value;
  $self->_merge_configs;
  $self->{_config_modified} = 1;
  $self->{_msg}             = "$name was set to $value";
  return 1;
}

#-----------------------------------------------------------------------------
sub _string_handler {
  my ( $self, $name, $value, $del ) = @_;

  $del //= 0;

  return $self->_el_del( $name )
    if $del;

  return $self->_el_get( $name )
    unless defined $value;

  my $valid = 1;

  if ( my $can = $self->can( "_validate_$name" ) ) {
    $valid = $self->$can( $value );
  }

  if ( $valid ) {
    $self->_el_set( $name, $value );
  } else {
    $self->{_msg} = "'$value' did not pass validation check.";
  }

  return $valid;
} ## end sub _string_handler

#-----------------------------------------------------------------------------
sub _array_handler {
  my ( $self, $name, $value, $del ) = @_;

  $DB::single++;

  die "expecting array ref in second parameter to _array_handler"
    if defined $value && ref $value ne 'ARRAY';

  $value //= [];
  $del   //= 0;

  return $self->_el_del( $name )
    if $del && !$value;

  return $self->_el_get( $name )
    unless @$value;

  my $els = defined $self->{_configs}[0]{$name} ? @{ $self->{_configs}[0]{$name} } : [];

  die "expecting $name to be an array ref in _array_handler"
    unless ref $els eq 'ARRAY';

  if ( $del ) {
    for my $v ( @$value ) {
      @$els = grep ! /^$v$/, @$els;
    }
  } else {
    push  @$els, @$value;
  }

  my $valid = 1;

  if ( my $can = $self->can( "_validate_$name" ) ) {
    $valid = $self->$can( $value );
  }

  if ( $valid ) {
    $self->_el_set( $name, $value );
  } else {
    my $list = join ',', @$value;
    $self->{_msg} = "'$list' did not pass validation check.";
  }

  return $valid;
}

##############################################################################
# Array Element Utilities

1;
