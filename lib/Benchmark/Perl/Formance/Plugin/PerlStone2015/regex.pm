package Benchmark::Perl::Formance::Plugin::PerlStone2015::regex;
# ABSTRACT: benchmark - regex - regular expression handling

# Regexes

use strict;
use warnings;

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';
use Data::Dumper;

sub backtrack
{
        my ($options) = @_;

        # http://swtch.com/~rsc/regexp/regexp1.html

        my $goal   = $options->{fastmode} ? 25 : 28;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $n      = $goal;
        my $re     = ("a?" x $n) . ("a" x $n);
        my $string = "a" x $n;

        my $t = timeit $count, sub { $string =~ /$re/ };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

sub split1
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 5_000_000 : 50_000_000;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $re     = '(.*) (.*) (.*) (.*) (.*)';
        my $string = (("a" x $goal) . " ") x 5;
        chop $string;

        my $t = timeit $count, sub { $string =~ /$re/ };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

sub split2
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 25_000_000 : 250_000_000;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $re     = '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)';
        my $string = ( ("a" x $goal) . " " ) x 5;
        chop $string;

        my $t = timeit $count, sub { $string =~ /$re/ };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

sub precomp_access
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 50 : 500;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $r = qr/\d+/;
        my $t = timeit $count, sub { "1234" =~ $r for 1..50_000*$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

# how quickly run-time regexes are compiled
sub runtime_comp
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 5_000_000 : 10_000_000;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $r ='\d+';
        my $t = timeit $count, sub { "1234" =~ $r for 1..$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

# run-time regexes are compiled but defeating the caching
sub runtime_comp_nocache
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 5_000_000 : 10_000_000;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $r ='\d+';
        my $t = timeit $count, sub { "1234" =~ /$r$_/ for 1..$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

# run-time code-blocks
sub code_runtime
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 50_000 : 200_000;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $counter;
        my $code = '(?{$counter++})';
        use re 'eval';

        my $t = timeit $count, sub { $counter = 0; "1234" =~ /\d+$code/ for 1..$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
                counter   => $counter,
               };
}

# literal code-blocks
sub code_literal
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 2_900_000 : 11_600_000;
        my $count  = $options->{fastmode} ? 1 : 5;

        my $counter;
        my $t = timeit $count, sub { "1234" =~ /\d+(?{$counter++})/ for 1..$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

sub main
{
        my ($options) = @_;

        my $results;

        eval {
                $results = {
                            backtrack               => backtrack($options),
                            split1                  => split1($options),
                            split2                  => split2($options),
                            precomp_access          => precomp_access($options),
                            runtime_comp            => runtime_comp($options),
                            runtime_comp_nocache    => runtime_comp_nocache($options),
                            code_runtime            => code_runtime($options),
                            code_literal            => code_literal($options),
                           };
                #my $splitratio = sprintf("%0.4f",$results->{split1}{Benchmark}[0] / $results->{split2}{Benchmark}[0]);
                # fake 'splitratio' as Benchmark.pm structure, just for symmetry
                #$results->{splitratio} = {Benchmark => bless([ $splitratio, $splitratio, 0, 0, 0, $results->{split1}{count}], 'Benchmark')};
        };

        if ($@) {
                warn $@ if $options->{verbose};
                $results = { failed => $@ };
        }

        return $results;
}

1;
