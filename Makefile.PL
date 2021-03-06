use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'AWS',
    AUTHOR              => 'Thomas Burke <tburke@tb99.com>',
    VERSION_FROM        => 'lib/AWS.pm',
    ABSTRACT_FROM       => 'lib/AWS.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'AWS-*' },
);
