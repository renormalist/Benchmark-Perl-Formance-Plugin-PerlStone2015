# -*- mode: cperl -*-
use 5.008;
use strict;
use warnings;
package Benchmark::Perl::Formance::Plugin::PerlStone2015;
# ABSTRACT: Benchmark::Perl::Formance plugin covering a representative set of sub benchmarks

use Data::DPath 'dpath', 'dpathi';

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
                             regex
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

sub _find_sub_results
{
        my ($RESULTS) = @_;

        my %sub_results = ();

        my $benchmarks = dpathi($RESULTS)->isearch("//Benchmark");
        while ($benchmarks->isnt_exhausted) {
                my @keys;
                my $benchmark = $benchmarks->value;
                my $ancestors = $benchmark->isearch ("/::ancestor");

                while ($ancestors->isnt_exhausted) {
                        my $key = $ancestors->value->first_point->{attrs}{key};
                        push @keys, $key if defined $key;
                }
                $sub_results{join(".", reverse @keys)} = ${$benchmark->first_point->{ref}}->{Benchmark}[0];
        }
        return \%sub_results;
}

sub _aggregations
{
        my ($results, $options) = @_;

        my @keys = keys %$results;
        my $basemean = 1;
        return {
                basemean => { Benchmark => [ $basemean ] },
               };
}

sub main
{
        my ($options) = @_;

        my $results = perlstone($options);

        $results->{perlstone} = _aggregations($results, $options);
        return $results;
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
