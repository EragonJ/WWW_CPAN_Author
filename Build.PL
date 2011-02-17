use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::CPAN::Author',
    license             => 'perl',
    dist_author         => q{EragonJ / Chia-Lung, Chen (陳佳隆) <eragonj@hax4.in>},
    dist_version_from   => 'lib/WWW/CPAN/Author.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'WWW-CPAN-Author-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
