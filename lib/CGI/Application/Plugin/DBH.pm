package CGI::Application::Plugin::DBH;


use strict;
use vars qw($VERSION @ISA  @EXPORT_OK);
require Exporter;
@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(
    dbh
    dbh_config
);

$VERSION = '1.00';

sub dbh {
    my $self = shift;

    die "must call dbh_config() before calling dbh()." unless $self->{__DBH_CONFIG};

    if (!$self->{__DBH}) {

        # create DBH object
        if ($self->{__DBH_CONFIG}) {
            require DBI;
            # use the parameters the user supplied
            $self->{__DBH} = DBI->connect(@{ $self->{__DBH_CONFIG} });
        } else {
        }
    }

    return $self->{__DBH};
}

sub dbh_config  {
    my $self = shift;
    die "Calling dbh_config after the dbh has already been created" if (defined $self->{__DBH});

    # See if a handle is being passed in directly.
    require UNIVERSAL;
    if ((ref $_[0]) and $_[0]->isa('DBI::db')) {
        $self->{__DBH} = $_[0];

        # Set this to note that we have completed the 'config' stage.
        $self->{__DBH_CONFIG} = 1;
    }
    else {
        $self->{__DBH_CONFIG} = \@_;
    }

}

1;
__END__

=head1 NAME

CGI::Application::Plugin::DBH - Easy DBI access from CGI::Application

=head1 SYNOPSIS

 use CGI::Application::Plugin::DBH (qw/dbh_config dbh/);

 sub cgiapp_init  {
    my $self = shift;

    # use the same args as DBI->connect();
    $self->dbh_config($data_source, $username, $auth, \%attr);
 }

 sub my_run_mode {
    my $self = shift;

    my $date = $self->dbh->selectrow_array("SELECT CURRENT_DATE");

    # OR ...

    my $dbh = $self->dbh;
    my $date = $dbh->selectrow_array("SELECT CURRENT_DATE");


 } 


=head1 DESCRIPTION

CGI::Application::Plugin::DBH adds easy access to a L<DBI|DBI> database handle to
your L<CGI::Application|CGI::Application> modules.  Lazy loading is used to prevent a database
connection from being made if the C<dbh> method is not called during the
request.  In other words, the database connection is not created until it is
actually needed. 

=head1 METHODS

=head2 dbh()

 my $date = $self->dbh->selectrow_array("SELECT CURRENT_DATE");

 # OR ...

 my $dbh = $self->dbh;
 my $date = $dbh->selectrow_array("SELECT CURRENT_DATE");

This method will return the current L<DBI|DBI> database handle.  The database handle is created on
the first call to this method, and any subsequent calls will return the same handle. 

=head2 dbh_config()

 sub cgiapp_init  {
    my $self = shift;

    # use the same args as DBI->connect();
    $self->dbh_config($data_source, $username, $auth, \%attr);

    # ...or use some existing handle you have
    $self->dbh_config($DBH);

 }

Used to provide your DBI connection parameters. You can either pass in an existing 
DBI database handle, or provide the usual parameters used for DBI->connect().

The recommended place to call C<dbh_config> is in the C<cgiapp_init>
stage of L<CGI::Application|CGI::Application>.  If this method is called after the database handle
has already been accessed, then it will die with an error message.

=head1 LIMITATIONS

To keep things simple only one database handle is supported. Nothing prevents
you from creating a second handle on your own.

=head1 SEE ALSO

L<Ima::DBI|Ima::DBI> is similar, but has much more complexity and features, including
support for multiple database handles. 

L<CGI::Application|CGI::Application>, L<DBI|DBI>, L<CGI::Application::Plugin::ValidateRM|CGI::Application::Plugin::ValidateRM>, perl(1)

=head1 AUTHOR

Mark Stosberg <mark@summersault.com>

=head1 LICENSE

Copyright (C) 2004 Mark Stosberg <mark@summersault.com>

This library is free software. You can modify and or distribute it under the same terms as Perl itself.

=cut

