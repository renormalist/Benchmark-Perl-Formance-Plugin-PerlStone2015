package Benchmark::Perl::Formance::Plugin::PerlStone2015::01overview;
# ABSTRACT: benchmark - perl 01 - overview

use strict;
use warnings;
no warnings 'recursion';

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';
use Data::Dumper;

my @a;
my %h;
my $s;

# ----- operator mix -----

sub opmix1_worker
{
    my $n = shift;

    $n % 2 and bless{1..4} and $h{$n} and $a[$n] and $s =~ s/$/../;
    $n<2 and return $n;
    opmix1_worker($n-1) + opmix1_worker($n-2);
}

sub opmix1
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 25 : 27;
        my $count  = $options->{fastmode} ?  1 : 5;

        my $t = timeit $count, sub {
                @a = (0..31);
                %h = (1..100);
                $s = '0123456789';
                opmix1_worker($goal)
        };

        return {
                Benchmark  => $t,
                goal       => $goal,
                count      => $count,
               };
}

# ----- operator mix with method calls -----
{
        package Benchmark::Perl::Formance::Plugin::PerlStone2015::01overview::opmix2;

        sub new { my $c = shift; bless { @_ }, $c }

        sub opmix2_worker
        {
                my ($self, $n) = (shift, shift);

                $n % 2 and bless{1..4} and $h{$n} and $a[$n] and $s =~ s/$/../;
                $n<2 and return $n;
                $self->opmix2_worker($n-1) + $self->opmix2_worker($n-2);
        }
}

sub opmix2
{
        my ($options) = @_;

        my $goal   = $options->{fastmode} ? 25 : 27;
        my $count  = $options->{fastmode} ?  1 : 5;

        my $worker = Benchmark::Perl::Formance::Plugin::PerlStone2015::01overview::opmix2->new;
        my $t = timeit $count, sub {
                @a = (0..31);
                %h = (1..100);
                $s = '0123456789';
                $worker->opmix2_worker($goal)
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
                            opmix1   => opmix1($options),
                            opmix2   => opmix2($options),
                           };
        };

        if ($@) {
                warn $@ if $options->{verbose};
                $results = { failed => $@ };
        }

        return $results;
}

1;
