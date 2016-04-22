package Benchmark::Perl::Formance::Plugin::PerlStone2015::06subroutines;
# ABSTRACT: benchmark - perl 06 - subroutines

use strict;
use warnings;

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';

sub main
{
        my ($options) = @_;

        my $results;
        eval {
                $results = {
                           };
        };

        if ($@) {
                warn $@ if $options->{verbose};
                $results = { failed => $@ };
        }

        return $results;
}

1;
