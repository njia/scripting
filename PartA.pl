#!/usr/bin/env perl
#
use warnings;
use strict;
use 5.010;

# this sub will download Perl keyword html file from learn.perl.org and create keyword
# list for Perl syntac, Perl functions and Perl find handles
sub get_keywords {
  # Download the Perl keyword HTML file
  my $perl_keywords = `curl -s http://learn.perl.org/docs/keywords.html#functions`;
  # define start match for Perl file handle
  # define start match for Perl functions
  # define start match for Perl syntax
  # all ends at </table>
  # every keyword is between ">" and "</a>"
  my $handle_start   = "File Handles</h3>";
  my $function_start = ">Perl functions</h3>";
  my $syntax_start   = ">Perl syntax</h3>";
  my $end_capture = "</table>";
  my $key_words_start = '">';
  my $key_words_end  = "</a>";

  # Match all Perl find handls (still with HTML tags)
  # Assign capture group to $temp as $1 is read only
  # All file handls are in upper case, so extract upper case words
  $perl_keywords =~ /(?:$handle_start)(.+?)(?:$end_capture)/s;
  my $temp = $1;
  my @filehandle_keyword_list = $temp =~ /(?:$key_words_start)([A-Z]+?)(?:$key_words_end)/gs;
  print join ":", @filehandle_keyword_list, "\n";

  $perl_keywords =~ /(?:$function_start)(.+?)(?:$end_capture)/s;
  $temp = $1;
  my @function_keywoard_list = $temp =~ /(?:$key_words_start)([_a-zA-Z\-]+?)(?:$key_words_end)/gs;
  print "Number of function keywords: \n", scalar @function_keywoard_list;
  print join ":", @function_keywoard_list, "\n";

  $perl_keywords =~ /(?:$syntax_start)(.+?)(?:$end_capture)/s;
  $temp = $1;
  my @syntax_keywrod_list = $temp =~ /(?:$key_words_start)([_a-zA-Z\-]+?)(?:$key_words_end)/gs;
  print "number of syntax keywords: \n", scalar @syntax_keywrod_list;
  print join ":", @syntax_keywrod_list, "\n";

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
