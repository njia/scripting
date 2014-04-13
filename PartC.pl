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
  my %key_words = map { $_ => 1 } (@filehandle_keyword_list, @function_keywoard_list,  @syntax_keywrod_list);
  return %key_words;
}

sub print_keywords {
  open my $IN_FILE, "<", $_[0] or die "print_keywords: Could not read from file $_[0]\n";
  my %perl_key_words = &get_keywords;
  my $number_of_keywords = 0;
  my %seen = ();
  print "[Keywords]\n";
  while (<$IN_FILE>) {
    chomp;
    foreach my $word (split) {
      $word =~ s/[^@\$%&a-zA-Z_-]//g;
      if ($perl_key_words{$word}) {
        print $word, "\n" unless ($seen{$word} || ($number_of_keywords > 15));
        $number_of_keywords++ unless ($seen{$word});
        $seen{$word}++;
      }
    }
  }
  close $IN_FILE;
}

sub print_comments {
  open my $IN_FILE, "<", $_[0] or die "print_comments: Could not read from file $_[0]\n";
  print "[Comments]\n";
  my @comments = ();
  while (<$IN_FILE>) { # inline comments for test
    push @comments, "$1" if /^(#[^!]+$)/;
    push @comments, "$1" if m{(?:^[^#]+?)(#[^/]+$)};
  }
  my $number = (scalar @comments > 4) ? 4 : (scalar @comments);
  print map {$comments[$_]} (0..$number-1);
  close $IN_FILE;
}

sub print_strings {
  open my $IN_FILE, "<", $_[0] or die "print_strings: Could not read from file $_[0]\n";
  print "[Strings]\n";
  my @strings = ();
  while (<$IN_FILE>) {
    push @strings, map {$_."\n"} /(".*?"|'.*?')/g
  }
  my $number = (scalar @strings > 4) ? 4 : (scalar @strings);
  print map {$strings[$_]} (0..$number-1);
  close $IN_FILE;
}

my $input_file = $ARGV[0];

die "Error: unable to analyse the specified file.\n" if !defined $input_file;
chomp $input_file;

print "File: $input_file\n";

unless ( $input_file =~ /.p[l|m]$/ && -R $input_file && -f $input_file && -s $input_file) {
  die "Error: unable to analyse the specified file.\n";
  exit 1;
}

my $lines = 0;
my @words = ();
my @chars = ();

open my $IN_FILE, "<", $input_file or die "Could not read from $input_file\n";
  while (<$IN_FILE>) {
    $lines = $. if eof;
    push @words, split;
    push @chars, split //, $_;
  }

print "Lines: $lines\n";
print "Words: ", scalar @words, "\n";
print "Chars: ", scalar @chars, "\n";

&print_keywords($input_file);
&print_strings($input_file);
&print_comments($input_file);
