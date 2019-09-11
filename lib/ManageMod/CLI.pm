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

# Add configuration when instantiating an object
sub new {
  my ( $class ) = @_;
  my $self = bless {}, $class;
  $self->{'app_argv'} = undef;
  $self->{'config'} = 'config';
  return $self;
};

1;
