package ManageMod::Config;

## no critic

use strictures 2;
use namespace::clean;

#use YAML::Syck qw( LoadFile DumpFile );
use YAML::XS qw( LoadFile DumpFile );
use Hash::Merge;
use List::MoreUtils 'uniq';

$YAML::XS::Boolean = 'JSON::PP';
$YAML::XS::Indent  = 2;

our $defaults = {
  _self => {},

  _configs => {
    channels   => [qw( release )],
    directory  => '/path/to/mods/dir',
    mc_version => -1,
    mods       => [],
  },
};

sub new {
  my ( $class, $args ) = @_;

  die 'new for ManageMod::Config requires hash ref'
    if defined $args && ref $args ne 'HASH';

  my $self = bless Hash::Merge::merge( $defaults->{_self}, $args || {} ), $class;

  $self->load_config;

  return $self;
}

sub configfile {
  my ( $self ) = @_;
  warn "no configfile set\n" unless exists $self->{configfile};
  $self->{configfile};
}

sub _load_config {
  my ( $self, $filename ) = @_;

  die 'bad configs key'
    if exists $self->{_configs} && ref $self->{_configs} ne 'ARRAY';

  $self->{_configs} //= [];

  if ( !-r $filename ) {
    warn "$filename does not exist or is not readable\n";
    return 0;
  }

  my $newcfg = LoadFile( $filename );
  push @{ $self->{_configs} }, $newcfg;

  if ( exists $newcfg->{include} ) {
    die "include must be an array in $filename\n"
      unless ref $newcfg->{include} eq 'ARRAY';

    $self->_load_config( $_ ) for @{ $newcfg->{include} };
  }

  return 1;
} ## end sub _load_config

sub _merge_configs {
  my ( $self ) = @_;

  die 'no configs key found'
    unless exists $self->{_configs};

  die 'bad configs key'
    if exists $self->{_configs} && ref $self->{_configs} ne 'ARRAY';

  my $config = $defaults->{_configs};

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

  # De-duplicate mods list
  $config->{mods} = [ uniq @{ $config->{mods} } ];

  $self->{config} = $config;

  return 1;
} ## end sub _merge_configs

sub load_config {
  my ( $self ) = @_;

  $self->_load_config( $self->configfile );
  $self->_merge_configs;

  return 1;
}

sub save { $_[0]->save_config }

sub save_config {
  my ( $self ) = @_;

  # If _configs[0] is empty, then we are creating a default config.
  my $cfg = $self->{_configs}[0] || $self->{config};

  DumpFile( $self->configfile, $cfg );

  warn sprintf "%s saved\n", $self->configfile;
  return 1;
}

1;
