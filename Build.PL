use Module::Build;

Module::Build->new(
    module_name => 'CGI::Application::Plugin::DBH',
    license => 'perl',
    requires => {
        'CGI::Application' => 0,
        'DBI'              => 0,
        'DBD::Mock'        => .11,
    },
    create_makefile_pl => 'traditional',
    create_readme => 1,
    dist_author => 'Mark Stosberg <mark@summersault.com>',
    dist_abstract => 'Plugin that adds DBH support to CGI::Application',
)->create_build_script;

