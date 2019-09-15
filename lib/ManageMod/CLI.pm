package ManageMod::CLI;

## no critic

use strictures 2;
use base qw(App::CLI App::CLI::Command);

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

use constant global_options => ( 'c|config=s' => 'configfile' );

##############################################################################
# Add my own functions to App::CLI::Command object
package App::CLI::Command;

use strictures 2;

use File::Basename 'basename';
use Hash::Merge 'merge';

our $defaults = {
#  configfile => 'manage-mod.cfg',
};

{
  no warnings 'redefine';

  ## Add configuration when instantiating an object
  sub new {
    my ( $class, @global_args ) = @_;

    #my %args = %{ merge( $defaults, {@global_args} ) };
    #my $self = bless \%args, $class;
    my $self = bless merge( $defaults, {@global_args} ), $class;

    # Set defaults based on how we are running
    $self->{configfile} //= $self->prog_name . '.cfg';

    my $cfg_args = { 'configfile' => $self->configfile };

    #$cfg_args->{create} = 1
    #  if $class eq 'ManageMod::CLI::Config' && lc $ARGV[0] eq 'create';

    $self->{'config'} = ManageMod::Config->new( $cfg_args );

    return $self;
  } ## end sub new

  sub run {
    my ( $self ) = @_;
    my $cmd = shift @ARGV;

    $self->help if !defined $cmd || $cmd eq '';
    $self->can( $cmd ) ? $self->$cmd : $self->unknown_cmd( $cmd );
  }

}

# Convenience methods
sub config { $_[0]->{config} }
sub configfile { $_[0]->{configfile} }

# What command are we running as?
sub command { lc basename( $_[0]->filename, '.pm' ) }

sub unknown_cmd {
  my ( $self ) = @_;

  my $command = $self->command;
  my $attempt = $self->{app}{app_argv}[0];

  die "Unknown command for $command: $attempt\n";
}

sub help {

  # require App::CLI::Command::Help?
  my ( $self ) = @_;
  die "Help yourself!\n";
}

1;
