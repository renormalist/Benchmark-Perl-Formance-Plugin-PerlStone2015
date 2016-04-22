package Benchmark::Perl::Formance::Plugin::PerlStone2015::fannkuch;
# ABSTRACT: benchmark - Indexed-access to tiny integer-sequence

# COMMAND LINE:
# /usr/bin/perl fannkuch.perl-3.perl 12

# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org/

# Initial port from C by Steve Clark
# Rewrite by Kalev Soikonen
# Modified by Kuang-che Wu
# Multi-threaded by Andrew Rodland
# Benchmark::Perl::Formance plugin by Steffen Schwigon

use strict;
use warnings;
no warnings 'uninitialized';

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';

use integer;
use threads;

sub fannkuch {
  my ($n, $last) = @_;
  my ($iter, $flips, $maxflips);
  my (@q, @p, @count);

  @p = (1 .. $last - 1, $last + 1 .. $n, $last);
  @count = (1..$n);

  TRY: while (1) {
    if ($p[0] != 1 && $p[-1] != $n) {
      @q = @p;
      for ($flips=0; $q[0] != 1; $flips++) {
        unshift @q, reverse splice @q, 0, $q[0];
      }
      $maxflips = $flips if $flips > $maxflips;
    }

    for my $i (1 .. $n - 2) {
      splice @p, $i, 0, shift @p;
      next TRY if (--$count[$i]);
      $count[$i] = $i + 1;
    }
    return $maxflips;
  }
}

sub print30 {
  my ($n, $iter) = @_;
  my @p = my @count = (1..$n);

  TRY: while (1) {
    #print @p, "\n";
    return if ++$iter >= 30;
    for my $i (1 .. $n - 1) {
      splice @p, $i, 0, shift @p;
      next TRY if (--$count[$i]);
      $count[$i] = $i + 1;
    }
  }
}

sub run
{
        my ($n) = @_;

        print30($n);

        my @threads;
        for my $i (1 .. $n) {
                push @threads, threads->create(\&fannkuch, $n, $i);
        }

        my $max = 0;
        for my $thread (@threads) {
                my $val = $thread->join;
                $max = $val if $val > $max;
        }
        return $max;
}

sub main
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 9 : 10;
        my $count  = $options->{fastmode} ? 2 : 5;

        my $result;
        my $t = timeit $count, sub { $result = run($goal) };
        return {
                Benchmark     => $t,
                goal          => $goal,
                count         => $count,
                result        => $result,
               };
}

1;
