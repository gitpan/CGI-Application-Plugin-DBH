package CGI::Application::Plugin::DBH;


use strict;
use vars qw($VERSION @ISA  @EXPORT_OK);
use Carp;
require Exporter;
@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(
    dbh
    dbh_config
    dbh_default_name
);

$VERSION = '2.00';

sub dbh {
    my $self = shift;
    my $name = shift;

    $self->{__DBH_DEFAULT_NAME} ||= "__cgi_application_plugin_dbh";     # First use case.
    $name ||= $self->{__DBH_DEFAULT_NAME};                              # Unamed handle case.

    croak "must call dbh_config() before calling dbh()." unless $self->{__DBH_CONFIG}{$name};

    unless( defined($self->{__DBH}{$name}) && $self->{__DBH}{$name}->ping ) {
        # create DBH object
        if( $self->{__DBH_CONFIG}{$name} ) {
            require DBI;
            # use the parameters the user supplied
            $self->{__DBH}{$name} = DBI->connect(@{ $self->{__DBH_CONFIG}{$name} });
        } else {
        }
    }

    return $self->{__DBH}{$name};
}

sub dbh_config {
    my $self = shift;

    $self->{__DBH_DEFAULT_NAME} ||= "__cgi_application_plugin_dbh";     # First use case.

    my $name = shift if( ref($_[1]) );
    $name ||= $self->{__DBH_DEFAULT_NAME};                              # Unamed handle case.
    
    croak "Calling dbh_config after the dbh has already been created" if( defined $self->{__DBH}{$name} );

    # See if a handle is being passed in directly.
    require UNIVERSAL;
    if( ref($_[0]) eq 'ARRAY' ) {
	$self->{__DBH_CONFIG}{$name} = shift;
    }
    elsif( ref($_[0]) and $_[0]->isa('DBI::db') ) {
        $self->{__DBH}{$name} = shift;

        # Set this to note that we have completed the 'config' stage.
        $self->{__DBH_CONFIG}{$name} = 1;
    }
    else {
        $self->{__DBH_CONFIG}{$name} = \@_;
    }

}

sub dbh_default_name {
    my $self = shift;
    my $old_name = $self->{__DBH_DEFAULT_NAME} || "__cgi_application_plugin_dbh"; # Possible first use case.
    $self->{__DBH_DEFAULT_NAME} = shift if $_[0];
    return $old_name;
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

    # or to use more than one dbh
    $self->dbh_config('my_handle', 
		    [ $data_source, $user, $auth, \%attr ]);
    $self->dbh_config('my_other_handle', 
		    [ $data_source, $user, $auth, \%attr ]);
 }

 sub my_run_mode {
    my $self = shift;

    my $date = $self->dbh->selectrow_array("SELECT CURRENT_DATE");
    # again with a named handle
    $date = $self->dbh('my_handle')->selectrow_array("SELECT CURRENT_DATE");

    # OR ...

    my $dbh = $self->dbh;
    # again with a named handle
    $dbh = $self->dbh('my_other_handle');
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
 # again with a named handle
 $date = $self->dbh('my_handle')->selectrow_array("SELECT CURRENT_DATE");

 # OR ...

 my $dbh = $self->dbh;
 # again with a named handle
 $dbh = $self->dbh('my_other_handle');
 my $date = $dbh->selectrow_array("SELECT CURRENT_DATE");

This method will return the current L<DBI|DBI> database handle.  The database handle is created on
the first call to this method, and any subsequent calls will return the same handle. 

=head2 dbh_config()

 sub cgiapp_init  {
    my $self = shift;

    # use the same args as DBI->connect();
    $self->dbh_config($data_source, $username, $auth, \%attr);

    # or to use more than one dbh
    $self->dbh_config('my_handle', 
		    [ $data_source, $user, $auth, \%attr ]);
    $self->dbh_config('my_other_handle', 
		    [ $data_source, $user, $auth, \%attr ]);

    # ...or use some existing handle you have
    $self->dbh_config($DBH);
    $self->dbh_config('my_handle', $DBH);   # this works too
 }

Used to provide your DBI connection parameters. You can either pass in an existing 
DBI database handle, or provide the usual parameters used for DBI->connect().

The recommended place to call C<dbh_config> is in the C<cgiapp_init>
stage of L<CGI::Application|CGI::Application>.  If this method is called after the database handle
has already been accessed, then it will die with an error message.

=head2 dbh_default_name()

 sub my_runmode {
    my $self = shift;

    my $old_handle_name = $self->dbh_default_name('my_handle');
    $self->some_legacy_code();  # some_legacy_code() will get "my_handle"
                                # when it calls $self->dbh() without parameters

    $self->dbh_default_name($old_handle_name);    # Return to normal.
 }

Can be used to alter the name of the handle that is returned by dbh() when
called with no parameters. It can even be used to alter the name used for the
unamed handle if called before dbh_config().

Using this method is completely optional. If you don't have a use for it don't
use it. Internally the handle name "__cgi_application_plugin_dbh" is used to
keep track of the unnamed handle unless it is changed by dbh_default_name()
before a call to dbh_config() without a name parameter.

=head1 SEE ALSO

L<Ima::DBI|Ima::DBI> is similar, but has much more complexity and features. 

L<CGI::Application|CGI::Application>, L<DBI|DBI>, L<CGI::Application::Plugin::ValidateRM|CGI::Application::Plugin::ValidateRM>, perl(1)

=head1 AUTHOR

Mark Stosberg <mark@summersault.com>

Multi Handle Support added by:
Tony Fraser <tony@sybaspace.com>

=head1 LICENSE

Copyright (C) 2004 Mark Stosberg <mark@summersault.com>

This library is free software. You can modify and or distribute it under the same terms as Perl itself.

=cut

