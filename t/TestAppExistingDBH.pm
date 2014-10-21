package TestAppExistingDBH;

use strict;

use CGI::Application;
@TestAppExistingDBH::ISA = qw(CGI::Application);

use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);

sub cgiapp_init {
  my $self = shift;

  require DBI;
  my $dbh = DBI->connect('DBI:Mock:','','');
  $self->dbh_config($dbh);

}

sub setup {
    my $self = shift;

    $self->start_mode('test_mode');

    $self->run_modes(test_mode => 'test_mode' );
}

sub test_mode {
  my $self = shift;
  return 1;
}


1;
