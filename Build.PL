use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'AWS',
    license             => 'perl',
    dist_author         => 'Thomas Burke <tburke@tb99.com>',
    dist_version_from   => 'lib/AWS.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
        'URI::Escape' => 1.35,
    },
    add_to_cleanup      => [ 'AWS-*' ],
);

$builder->create_build_script();
