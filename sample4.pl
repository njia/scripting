#!/usr/bin/env perl
use warnings;
use strict;

# Comment 1
my $time = <STDIN>;
chomp $time;

   #now write input to STDOUT
print $time . "\n";

my $pi = 3.1415926;

my $test = -3.22;

my $t = +0.01;

print "hello" if $ARGV[0];
my $mad = 6_54_3.1_4_1_5_9_2 ;        # a very important number
print $mad, "\n";

my $crazy = .23E-1_0;
print $crazy, "\n";

my $jj = 25E-10_0;
print $jj, "\n";

my $ii = 25E-100;
print $ii, "\n";

my $wow = 0xff;
print $wow, "\n";

my @array = (12345, 12345.67, .23E-10, 3.1_4_1_5_9_2, 4_294_967_296, 0xff, 0xdead_beef, 0377, 0b011011);
my $numbers = (8..11);

sub sample2
{
  print "true or false";
  return 3 + 4 eq "7"; # true or false
}
