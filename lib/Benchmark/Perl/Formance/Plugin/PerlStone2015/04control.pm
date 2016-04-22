package Benchmark::Perl::Formance::Plugin::PerlStone2015::04control;
# ABSTRACT: benchmark - perl 04 - control

use strict;
use warnings;

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';

# Entering, iterating and leaving scopes
# http://www.nntp.perl.org/group/perl.perl5.porters/2016/01/msg233631.html
sub blocks1
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ?  9_200 : 46_000;
        my $count  = $options->{fastmode} ?      1 : 3;

        my $t = timeit $count, sub {
            my @a = 1..10_000;
            for (1..$goal) {
                $_++ for @a;
            }
        };

        return {
                Benchmark  => $t,
                goal       => $goal,
                count      => $count,
               };
}

# Entering, iterating and leaving scopes - with subs
# http://www.nntp.perl.org/group/perl.perl5.porters/2016/01/msg233631.html

sub inc { $_[0]++ }

sub blocks2
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 2_000 : 10_000;
        my $count  = $options->{fastmode} ?     1 : 3;

        my $t = timeit $count, sub {
                my @a = 1..10_000;
                for (1..$goal) {
                        inc($_) for @a;
                }
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
                            blocks1  => blocks1($options),
                            blocks2  => blocks2($options),
                           };
        };

        if ($@) {
                warn $@ if $options->{verbose};
                $results = { failed => $@ };
        }

        return $results;
}

1;
