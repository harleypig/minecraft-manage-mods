package TestLog;

use strict;
use warnings;

use ManageMod::Log ':all';

warn log_info('from TestLog but not in a sub');

sub testsub { warn log_info('from TestLog and in a sub') }

1;
