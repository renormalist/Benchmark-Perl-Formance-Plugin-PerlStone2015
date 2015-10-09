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

our $goal;
our $count;
our $length;

sub pathological
{
        # http://swtch.com/~rsc/regexp/regexp1.html

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

sub fieldsplit1
{
        my $re     = '(.*) (.*) (.*) (.*) (.*)';
        my $string = (("a" x $length) . " ") x 5;
        chop $string;

        my $t = timeit $count, sub { $string =~ /$re/ };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

sub fieldsplit2
{
        my $re     = '([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)';
        my $string = ( ("a" x $length) . " " ) x 5;
        chop $string;

        my $t = timeit $count, sub { $string =~ /$re/ };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

sub precompile_access
{
        my $r = qr/\d+/;
        my $t = timeit $count, sub { "1234" =~ $r for 1..50000*$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

# how quickly run-time regexes are compiled
sub runtime_compile
{
        my $r ='\d+';
        my $t = timeit $count, sub { "1234" =~ $r for 1..100000*$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

# run-time regexes are compiled but defeating the caching
sub runtime_compile_nocache
{

        my $r ='\d+';
        my $t = timeit $count, sub { "1234" =~ /$r$_/ for 1..10000*$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

# run-time code-blocks
sub code_runtime
{

        my $counter;
        my $code = '(?{$counter++})';
        use re 'eval';

        my $t = timeit $count, sub { $counter = 0; "1234" =~ /\d+$code/ for 1..20000*$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
                counter   => $counter,
               };
}

# This block here must come *LAST* - it *HEAVILY* influences others!

# literal code-blocks
sub code_literal
{

        my $t = timeit $count, sub { "1234" =~ /\d+(?{$count++})/ for 1..40000*$goal };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
               };
}

sub main
{
        my ($options) = @_;

        $goal   = $options->{fastmode} ? 20 : 29;
        $length = $options->{fastmode} ? 1_000_000 : 10_000_000;
        $count  = 5;
        my $results;

        eval {
                $results = {
                            pathological            => pathological(),
                            fieldsplit1             => fieldsplit1(),
                            fieldsplit2             => fieldsplit2(),
                            precompile_access       => precompile_access(),
                            runtime_compile         => runtime_compile(),
                            runtime_compile_nocache => runtime_compile_nocache(),
                            code_runtime            => code_runtime(),
                            code_literal            => code_literal(),
                           };
                $results->{fieldsplitratio} = sprintf("%0.4f",$results->{fieldsplit1}{Benchmark}[1] / $results->{fieldsplit2}{Benchmark}[1]);
        };

        print STDERR Dumper($results);
        if ($@) {
                $results = { failed => $@ };
        }

        return $results;
}

1;
