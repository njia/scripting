#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;

# this sub will download Perl keyword html file from learn.perl.org and create keyword
# list for Perl syntac, Perl functions and Perl find handles
sub get_keywords {
  # Download the Perl keyword HTML file
  my $perl_keywords = `curl -s http://learn.perl.org/docs/keywords.html`;
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

  $perl_keywords =~ /(?:$function_start)(.+?)(?:$end_capture)/s;
  $temp = $1;
  my @function_keywoard_list = $temp =~ /(?:$key_words_start)([_a-zA-Z\-]+?)(?:$key_words_end)/gs;

  $perl_keywords =~ /(?:$syntax_start)(.+?)(?:$end_capture)/s;
  $temp = $1;
  my @syntax_keywrod_list = $temp =~ /(?:$key_words_start)([_a-zA-Z\-]+?)(?:$key_words_end)/gs;
  my %key_words = map { $_ => 1 } (@filehandle_keyword_list, @function_keywoard_list, @syntax_keywrod_list);
  return %key_words;
}

sub print_numbers {
  open my $IN_FILE, "<", $_[0] or die "print_keywords: Could not read from file $_[0]\n";
  my @numbers = ();
  my @words = ();
  print "[Numbers]\n";
  while (<$IN_FILE>) {
    s/^(#[^!]+$)//;
    s{(^[^#]+?)(#[^/]+$)}{$1};
    s/('.*?'|".*?")//g;
    push @words, split;
  }

  foreach my $item (@words) {
    next if $item =~ /^[^-|^+|^\d|^.]/;
    push @numbers, $1 if $item =~ s/([-+]?([0-9_]+(\.[0-9_]+)?|[-+]?\.[0-9_]+)([eE]?[-+]?[0-9_]+)?)\b//;
    push @numbers, $1 if $item =~ /((0[x|X][0-9a-fA-F_]+)|(0[0-7]+?)|(0[b|B][01_]+))/;
  }

  close $IN_FILE;
}

sub find_keywords {
  open my $IN_FILE, "<", $_[0] or die "print_keywords: Could not read from file $_[0]\n";
  my %perl_key_words = &get_keywords;
  my $number_of_keywords = 0;
  my %key_words;
  while (<$IN_FILE>) {
    chomp;
    foreach my $word (split) {
      $word =~ s/[^@\$%&a-zA-Z_-]//g;
      $key_words{$word}++ if ($perl_key_words{$word})
    }
  }
  close $IN_FILE;
  my @key_words = keys %key_words;
}

sub find_comments {
  open my $IN_FILE, "<", $_[0] or die "print_comments: Could not read from file $_[0]\n";
  my @comments = ();
  while (<$IN_FILE>) { # inline comments for test
    push @comments, "$1" if /^(#[^!]+$)/;
    push @comments, "$1" if m{(?:^[^#]+?)(#[^/]+$)};
  }
  close $IN_FILE;
  return @comments;
}

sub find_strings {
  open my $IN_FILE, "<", $_[0] or die "print_strings: Could not read from file $_[0]\n";
  my @strings = ();
  local $/ = undef;
  my $content = <$IN_FILE>;
  push @strings, $content =~ /(".*?"|'.*?')/sg;
  close $IN_FILE;
  return @strings;
}

sub read_whole_file {
  open my $IN_FILE, "<", $_[0] or die "print_strings: Could not read from file $_[0]\n";
  local $/ = undef;
  my $content = <$IN_FILE>;
  close $IN_FILE;
  return $content;
}

my $royalblue = '<style="color:#2B60DE">';
my $keyward_color = '<code style="color:#08B000">';
my $darkcyan  = '<style="color:#008B8B">';
my $darkgreen = '<style="color:#006400">';
my $colorend  = '</code>';

my $input_file = $ARGV[0];
die "Error: unable to analyse the specified file.\n" if !defined $input_file;

my $output_file = $ARGV[1];
die "Error: Please enter output filename.\n" if !defined $output_file;

unless ( $input_file =~ /.p[l|m]$/ && -R -f -s -T $input_file) {
  die "Error: unable to analyse the specified file.\n";
  exit 1;
}

open my $OUT_FILE, ">", $output_file or die "Could not write to $output_file\n";

my $file_content = &read_whole_file($input_file);
my @kw = &find_keywords($input_file);

foreach my $item (@kw) {
  $file_content =~ s/\b($item)\b/$keyward_color$1$colorend/g;
}
print $OUT_FILE $file_content;
close $OUT_FILE;
exit 0;
