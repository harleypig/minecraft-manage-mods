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
use Hash::Merge::Extra 'R_ADDITIVE';

our $defaults = {};

{
  no warnings 'redefine';

  sub new {
    my ( $class, @global_args ) = @_;

    my $m = Hash::Merge->new();
    $m->add_behavior_spec( Hash::Merge::Extra::R_ADDITIVE, "R_ADDITIVE" );
    my %self = %{ $m->merge( $defaults, {@global_args} ) };
    my $self = bless \%self, $class;

    $self->{configfile} //= $self->prog_name . '.cfg';

    my $cfg_args = {
      configfile => delete $self->{configfile},
    };

    $self->{'config'} = ManageMod::Config->new( $cfg_args );

    return $self;
  } ## end sub new

  sub run {
    my ( $self ) = @_;
    my $subcmd = shift @ARGV;

    if ( !defined $subcmd || $subcmd eq '' ) {
      $self->can( 'default_subcmd' ) ? $self->default_subcmd : $self->help;

    } else {

      my $can = $self->can( $subcmd );

      my $todo = 0;
      $todo = grep { /^$subcmd$/i } @{ $self->subcommands_todo }
        if $self->can( 'subcommands_todo' );

      die "$subcmd is marked as todo but has a method defined\n"
        if $todo && $can;

      if ( $todo ) {
        $self->not_implemented( $subcmd );

      } elsif ( $can ) {
        $self->$can();

      } else {
        $self->unknown_cmd( $subcmd );
      }
    } ## end else [ if ( !defined $subcmd ...)]

    $self->config->save if $self->saveconfig;
    $self->config->dump if $self->dumpconfig;
  } ## end sub run
}

##############################################################################
sub command         { lc basename( $_[0]->filename, '.pm' ) }
sub config          { $_[0]->{config} }
sub configfile      { $_[0]->config->configfile }
sub dumpconfig      { defined $_[0]->{dumpconfig} ? 1 : undef }
sub not_implemented { die sprintf "%s %s %s is not implemented\n", $_[0]->prog_name, $_[0]->command, $_[1] }
sub saveconfig      { defined $_[0]->{saveconfig} ? 1 : undef }
sub unknown_cmd     { die sprintf "Unknown command for %s: %s\n", $_[0]->command, $_[1] }

# XXX: require App::CLI::Command::Help?
sub help { die "Sorry. Help has not been implemented.\n" }

1;
