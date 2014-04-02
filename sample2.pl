#!/usr/bin/env perl
use warnings;
use strict;

# Comment 1
my $time = <STDIN>;
chomp $time;

   #now write input to STDOUT
print $time . "\n";

sub sample2
{
   print "true or false";
   return 3 + 4 eq "7"; # true or false
}
