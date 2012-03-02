use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Text::Xtangle',
    AUTHOR              => 'MIZUTANI Tociyuki <tociyuki@gmail.com>',
    LICENSE             => 'perl',
    VERSION_FROM        => 'lib/Text/Xtangle.pm',
    ABSTRACT_FROM       => 'lib/Text/Xtangle.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::Base' => 0,
        'Encode' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
