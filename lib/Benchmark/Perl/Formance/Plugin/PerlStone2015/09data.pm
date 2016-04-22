package Benchmark::Perl::Formance::Plugin::PerlStone2015::09data;
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

sub a_alloc
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 10_000_000 : 20_000_000;
        my $count  = $options->{fastmode} ?        154 : 950;

        my $t = timeit $count, sub {
                my @stuff1;
                $#stuff1 = $goal;
        };
        return {
                Benchmark  => $t,
                goal       => $goal,
                count      => $count,
               };
}

sub a_copy
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 10_000_000 : 20_000_000;
        my $count  = $options->{fastmode} ?          6 : 38;
        my $size = 0;

        my @stuff;
        $#stuff = $goal;

        eval qq{use Devel::Size 'total_size'};
        $size = total_size(\@stuff) if !$@;

        my $t = timeit $count, sub {
                my @copy = @stuff;
        };
        return {
                Benchmark        => $t,
                goal             => $goal,
                count            => $count,
                total_size_bytes => $size,
               };
}

sub main
{
        my ($options) = @_;

        my $results;
        eval {
                $results = {
                            a_alloc => a_alloc($options),
                            a_copy  => a_copy ($options),
                           };
        };

        if ($@) {
                warn $@ if $options->{verbose};
                $results = { failed => $@ };
        }

        return $results;
}

1;
