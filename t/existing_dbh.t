use Test::More qw/no_plan/;
BEGIN { use_ok('CGI::Application::Plugin::DBH') };

use lib './t';
use strict;

$ENV{CGI_APP_RETURN_ONLY} = 1;

use TestAppExistingDBH;
my $t1_obj = TestAppExistingDBH->new();
my $t1_output = $t1_obj->run();

use UNIVERSAL;
ok($t1_obj->dbh->isa('DBI::db'), 'dbh() method returns DBI handle when using existing handle');

