package ManageMod::CLI;

## no critic

use strictures 2;
use base qw(App::CLI App::CLI::Command);

use List::MoreUtils 'any';

use ManageMod::Config;

our $VERSION = '0.01';

use constant alias => (
  '--version' => '+App::CLI::Command::Version',
  '-v'        => '+App::CLI::Command::Version',
  'version'   => '+App::CLI::Command::Version',

  '--help' => '+App::CLI::Command::Help',
  '-h'     => '+App::CLI::Command::Help',
  'help'   => '+App::CLI::Command::Help',
);

use constant global_options => (
  'c|config=s' => 'configfile',
  's|save!'    => 'saveconfig',
  'd|dump!'    => 'dumpconfig',
);

##############################################################################
# Add my own functions to App::CLI::Command object
package App::CLI::Command;

use strictures 2;

use File::Basename 'basename';
use Hash::Merge 'merge';

our $defaults = {
  saveconfig => 1,
  dumpconfig => 0,
};

{
  no warnings 'redefine';

  ## Add configuration when instantiating an object
  sub new {
    my ( $class, @global_args ) = @_;

    my $self = bless merge( $defaults, {@global_args} ), $class;

    # Set defaults based on how we are running
    $self->{configfile} //= $self->prog_name . '.cfg';

    my $cfg_args = { 'configfile' => $self->configfile };

    $self->{'config'} = ManageMod::Config->new( $cfg_args );

    return $self;
  }

  sub run {
    my ( $self ) = @_;
    my $subcmd = shift @ARGV;

    $self->help if !defined $subcmd || $subcmd eq '';

    if ( $self->can( 'subcommands_todo') ) {
      $self->not_implemented( $subcmd )
        if grep { /^$subcmd$/i } $self->subcommands_todo;
    }

    $self->unknown_cmd( $subcmd  ) unless $self->can( $subcmd );

    $self->$subcmd( @ARGV );

    $DB::single++;

    $self->config->save if $self->saveconfig;
    $self->config->dump if $self->dumpconfig;
  }

  #sub run {
  #  my ( $self ) = @_;
  #
  #my $subcmd = shift @ARGV;
  #
  #$self->help if !defined $subcmd || $subcmd eq '';
  #
  #$self->unknown_subcmd( $subcmd ) if none { /^$subcmd$/ } @subcommands;
  #$self->not_implemented( $subcmd ) unless $self->can( $subcmd );
  #$self->$cmd( shift @ARGV );
  #}

}

# Convenience methods
sub config     { $_[0]->{config} }
sub configfile { $_[0]->{configfile} }
sub saveconfig { $_[0]->{saveconfig} }
sub dumpconfig { $_[0]->{dumpconfig} }

# What command are we running as?
sub command { lc basename( $_[0]->filename, '.pm' ) }

sub unknown_cmd {
  my ( $self, $attempt ) = @_;
  die sprintf "Unknown command for %s: %s\n", $self->command, $attempt;
}

sub not_implemented {
  my ( $self, $cmd ) = @_;
  die sprintf "%s %s %s is not implemented\n", $self->prog_name, $self->command, $cmd;
}

# require App::CLI::Command::Help?
sub help {
  my ( $self ) = @_;
  die "Help yourself!\n";
}

1;
