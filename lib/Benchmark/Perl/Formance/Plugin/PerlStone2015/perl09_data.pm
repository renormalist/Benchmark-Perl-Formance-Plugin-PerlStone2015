package Benchmark::Perl::Formance::Plugin::PerlStone2015::perl09_data;
# ABSTRACT: benchmark - perl 09 - data

use strict;
use warnings;

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';

my @stuff;

sub array_alloc
{
        my ($options, $goal, $count) = @_;

        my $mygoal  = ($options->{fastmode} ? 10 : 1) * $goal;
        my $mycount = ($options->{fastmode} ? 10 : 1) * $count;

        my $t = timeit $mycount, sub {
                my @stuff1;
                $#stuff1 = $mygoal;
        };
        return {
                Benchmark  => $t,
                goal       => $mygoal,
                count      => $mycount,
               };
}

sub array_copy
{
        my ($options, $goal, $count) = @_;

        my $mygoal  = ($options->{fastmode} ? 10 : 1) * $goal;
        my $mycount = ($options->{fastmode} ? 10 : 1) * $count;
        my $size = 0;

        my @stuff;
        $#stuff = $mygoal;

        eval qq{use Devel::Size 'total_size'};
        $size = total_size(\@stuff) if !$@;

        my $t = timeit $mycount, sub {
                my @copy = @stuff;
        };
        return {
                Benchmark        => $t,
                goal             => $mygoal,
                count            => $mycount,
                total_size_bytes => $size,
               };
}

sub main
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 2_000_000 : 15_000_000;
        my $count  = $options->{fastmode} ? 5 : 20;

        my $results;
        eval {
                $results = {
                            array_alloc => array_alloc($options, $goal, $count),
                            array_copy  => array_copy ($options, $goal, $count),
                           };
        };

        if ($@) {
                $results = { failed => $@ };
        }

        return $results;
}

1;
