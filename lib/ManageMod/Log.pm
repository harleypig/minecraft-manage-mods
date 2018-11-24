package ManageMod::Log;

warn "Don't use " . __PACKAGE__ . ", it's not ready yet!"
exit 1

use strict;
use warnings;

use parent 'Exporter::Tiny';

use Log::Any '$log';

#our @EXPORT_OK = map { ( "log_$_", "log_${_}f" ) } qw(
#  alert crit critical debug emergency err error
#  fatal info inform notice trace warn warning
#);

our @EXPORT_OK = 'log_info';

sub _generate_log_info {
  return sub { return "hi\n" };
}

our $AUTOLOAD;

sub AUTOLOAD {
  print "$AUTOLOAD\n";
  my $sub = $AUTOLOAD;
  $sub =~ s/^.*:://;

  die "Unknown level ($sub) in " . __PACKAGE__ . ' autoload'
    unless grep /^$sub$/, @EXPORT_OK;

  ( my $level = $sub ) =~ s/^log_//;

  no warnings 'uninitialized';

  for my $clevel ( 0 .. 5 ) {
    my $caller = join ':', caller( $clevel );

    #$log->$sub( "$clevel: $caller" );
    print "$clevel: $caller\n";
  }
} ## end sub AUTOLOAD

1;
