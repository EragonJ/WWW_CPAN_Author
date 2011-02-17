#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::CPAN::Author' ) || print "Bail out!
";
}

diag( "Testing WWW::CPAN::Author $WWW::CPAN::Author::VERSION, Perl $], $^X" );
