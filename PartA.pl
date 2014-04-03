#!/usr/bin/env perl
#
use warnings;
use strict;
use 5.010;

sub get_keywords {
  my $perl_keywords = `curl -s http://learn.perl.org/docs/keywords.html#functions`;
  my $handle_start = "File Handles</h3>";
  my $end_capture = "</table>";
  my $key_words_start = '">';
  my $key_words_end  = "</a>";
  $perl_keywords =~ /(?:$handle_start)(.+?)(?:$end_capture)/s;
  my $temp = $1;
  my @list = $temp =~ /(?:$key_words_start)([A-Z]+?)(?:$key_words_end)/gs;
  # print @list;

  print join ":", @list;
}

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

&get_keywords;
