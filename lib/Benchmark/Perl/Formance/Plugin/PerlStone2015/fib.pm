package Benchmark::Perl::Formance::Plugin::PerlStone2015::fib;
# ABSTRACT: benchmark - Fibonacci - Stress recursion and function calls

use strict;
use warnings;

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

our $goal;
our $count;

use Benchmark ':hireswallclock';

sub fib
{
        my $n = shift;

        $n < 2
            ? 1
            : fib($n-1) + fib($n-2);
}

sub main
{
        my ($options) = @_;

        # ensure same values over all fib* plugins!
        $goal  = $options->{fastmode} ? 28 : 35;
        $count = 5;

        my $result;
        my $t = timeit $count, sub { $result = fib $goal };
        return {
                Benchmark => $t,
                result    => $result,
                goal      => $goal,
               };
}

1;
