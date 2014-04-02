#!/usr/bin/env perl
#
use warnings;
use strict;
use 5.010;

sub get_keywords {
  my $functions = `wget http://learn.perl.org/docs/keywords.html#functions`;
  my $syntax    = `wget http://learn.perl.org/docs/keywords.html#barewords`;
  my $file_handlers = `wget http://learn.perl.org/docs/keywords.html#file_handles`;

my $input_file = $ARGV[0];

die "Error: unable to analyse the specified file.\n" if !defined $input_file;
chomp $input_file;

print "File: $input_file\n";

unless ( $input_file =~ /.p[l|m]$/ && -R $input_file && -f $input_file && -s $input_file) {
  die "Error: unable to analyse the specified file.\n";
  exit 1;
}

my $result = `wc -l -w -m $input_file`;
my ($lines, $words, $chars) = $result =~ /[0-9]+/g;

print "Lines: $lines\n";
print "Words: $words\n";
print "Chars: $chars\n";
