package WWW::CPAN::Author;

use warnings;
use strict;

use WWW::Mechanize;
use Data::Dumper;
use Readonly;
use utf8;
use Carp;
use File::stat;
use Time::localtime;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(search_author);
our $VERSION = '0.01';

Readonly my $CPAN_AUTHOR_URL => 'http://ppm.activestate.com/CPAN/authors/00whois.html';
Readonly my $TEMP_FILENAME   => 'WWW_CPAN_AUTHOR.tmp';
Readonly my $TEMP_DIRECTORY  => '/tmp/';
Readonly my $TEMP_FILE       => $TEMP_DIRECTORY.$TEMP_FILENAME;

Readonly my $ONE_DAY         => 86400;

my %author = ();

sub _is_old {
    
    my $duration   = shift || $ONE_DAY;
    my $file_mtime = stat($TEMP_FILE)->mtime;
    my $now        = time();

    return (($now - $file_mtime) > $duration);
}

sub _check_temp_file {

    mkdir ($TEMP_DIRECTORY, 0777) if (!-d $TEMP_DIRECTORY);

    if (!-e $TEMP_FILE) {
        return 0;
    }

    return 1;
}

sub _get_author_list {

    # if file doesn't exist or too old
    if (!_check_temp_file() || _is_old(864000)) {
 
        my $url     = shift;
        my $mech    = WWW::Mechanize->new();
        my $content = $mech->get($url)->content;

        # cache it 
        open(my $temp_file_handler, ">$TEMP_FILE") or croak("Can't write file: $TEMP_FILE");
        print $temp_file_handler $content;
        close($temp_file_handler);

        # need the list separated by new-line
        return split /\n/,$content;
    }
    # otherwise
    else {

        # eat eat eat
        open(my $temp_file_handler, "<$TEMP_FILE") or croak("Can't read file: $TEMP_FILE");
        my @contents = <$temp_file_handler> ;
        close($temp_file_handler);
        
        return @contents;
    }
}

sub _process_author_list {

    my @lists   = _get_author_list($CPAN_AUTHOR_URL);

    # I am still finding better ways to manipulate this html file.
    foreach(@lists) {
        if (m{
                    # $1
            <a\sid="(.*?)"\sname="\1"></a>        # nickname
                         # $2   # $3      # $2
            (?|<a\shref="(.*?)">(.*?)</a>|(.*?))  # cpan_link & nick_name
            \s+                             
                         # $4   # $5      # $4
            (?|<a\shref="(.*?)">(.*?)</a>|(.*?))  # website_link & realname
            \s+
                # $6
            &lt;(.*?)&gt;                         # email
            }x) {
           
            my $nickname = $1;

            if ( defined($3) ) {
                $author{$nickname}{cpan_link} = $3;
            }

            if ( defined($5) ) {
                $author{$nickname}{website_link} = $4;
                $author{$nickname}{realname}     = $5;
            }
            else {
                $author{$nickname}{website_link} = 'none';
                $author{$nickname}{realname}     = $4;
            }

            $author{$nickname}{email} = $6 || 'none';
        }
    }
}

sub search_author {
    my $nickname = uc shift;
    if ( exists $author{$nickname} ) {
        return $author{$nickname};
    }
    return;
}

_process_author_list();

1; # End of WWW::CPAN::Author

=head1 NAME

WWW::CPAN::Author - You can use this module to find registered authors on PAUSE

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

    use WWW::CPAN::Author qw(search_author);

    # You will get a hash ref of this user or undef
    my $user_ref = search_author('eragonj');

=cut

=head1 AUTHOR

EragonJ / Chia-Lung, Chen (陳佳隆), C<< <eragonj at hax4.in> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-cpan-author at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-CPAN-Author>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::CPAN::Author

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-CPAN-Author>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-CPAN-Author>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-CPAN-Author>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-CPAN-Author/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 EragonJ / Chia-Lung, Chen (陳佳隆).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

