# -*- mode: cperl -*-
use 5.008;
use strict;
use warnings;
package Benchmark::Perl::Formance::Plugin::PerlStone2015;
# ABSTRACT: Benchmark::Perl::Formance plugin covering a representative set of sub benchmarks

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

sub perlstone
{
        my ($options) = @_;

        no strict "refs"; ## no critic

        my $verbose = $options->{verbose};
        my %results = ();
                             #
                             # need threaded perl:
                             # fannkuch
                             # knucleotide
                             # mandelbrot
        for my $subtest (qw( binarytrees
                             fasta
                             regexdna
                             nbody
                             revcomp
                             spectralnorm
                             fib
                          ))
        {
                print STDERR "#  - $subtest...\n" if $options->{verbose} > 2;
                eval "use ".__PACKAGE__."::$subtest"; ## no critic
                if ($@) {
                        print STDERR "# Skip PerlStone plugin '$subtest'" if $verbose;
                        print STDERR ":$@"                                if $verbose >= 2;
                        print STDERR "\n"                                 if $verbose;
                }
                else {
                        eval {
                                my $main = __PACKAGE__."::$subtest"."::main";
                                $results{$subtest} = $main->($options);
                        };
                        if ($@) {
                                $results{$subtest} = { failed => $@ };
                        }
                }
        }
        return \%results;
}

sub main
{
        my ($options) = @_;

        return perlstone($options);
}

1; # End of Benchmark::Perl::Formance::Plugin::PerlStone2015

__END__

=pod

=head2 main

Main entry point to start the benchmarks.

=head2 perlstone

The primary benchmarking function which in turn starts the sub
benchmarks.

=cut
