package Benchmark::Perl::Formance::Plugin::PerlStone2015::05regex;
# ABSTRACT: benchmark - perl 05 - regex

use strict;
use warnings;

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';

sub fixedstr
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 300_000 : 1_000_000;
        my $count  = $options->{fastmode} ?       1 : 3;

        my $t = timeit $count, sub {
                my $s;
                $s = "a" x 10_000 . "wxyz";
                $s =~ /wxyz/ for 1..$goal;
        };

        return {
                Benchmark  => $t,
                goal       => $goal,
                count      => $count,
               };
}

sub main
{
        my ($options) = @_;

        my $results;
        eval {
                $results = {
                            fixedstr   => fixedstr($options),
                           };
        };

        if ($@) {
                warn $@ if $options->{verbose};
                $results = { failed => $@ };
        }

        return $results;
}

1;
