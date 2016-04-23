use Test::More;
use Data::Dumper;
use Benchmark::Perl::Formance::Plugin::PerlStone2015;

diag "\nSample run. May take some seconds...";
my $result = Benchmark::Perl::Formance::Plugin::PerlStone2015::main
 ({subtests => [qw(nbody 01overview)],
   verbose  => 1,
   fastmode => 1,
  })->{perlstone}{subresults};

ok($result->{"01overview.opmix1"}, "sample run in fast mode");
diag Dumper($result);

done_testing();
