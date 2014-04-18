#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;

my $input_file = shift;
die "Error: unable to analyse the specified file.\n" if !defined $input_file;
chomp $input_file;

unless ( $input_file =~ /.p[l|m]$/ && -R -f -s -T $input_file) {
  die "Error: unable to analyse the specified file.\n";
  exit 1;
}

print "File: $input_file\n";

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

my @strings = ();
my @comments = ();
my $src;
my $off_set = 0;

&print_keywords_strings_comments($input_file);

# This sub will download Perl keyword html file from learn.perl.org and create keyword
# list for Perl syntac, Perl functions and Perl find handles
sub get_keywords {
  # Download the Perl keyword HTML file
  my $perl_keywords = `curl -s http://learn.perl.org/docs/keywords.html`;
  # Define start match for Perl filehandles, syntax and functions
  # All keywords section ends at </table>
  # And every keyword is between ">" and "</a>"
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

sub print_keywords_strings_comments {
  my %perl_key_words = &get_keywords;
  my $number_of_keywords = 0;
  my %seen = ();

  open my $IN_FILE, "<", $_[0] or die "print_keywords: Could not read from file $_[0]\n";
  local $/ = undef;
  $src = <$IN_FILE>;

  &find_strings_comments;

  foreach my $item (@strings) {
    $src =~ s/$item//g;
  }

  foreach my $item (@comments) {
    $src =~ s/$item//g;
  }

  print "[Keywords]\n";
    foreach my $word (split " ", $src) {
      $word =~ s/[^@\$%&a-zA-Z_-]//g;
      if ($perl_key_words{$word}) {
        print $word, "\n" unless ($seen{$word} || ($number_of_keywords >= 15));
        $number_of_keywords++ unless ($seen{$word});
        $seen{$word}++;
      }
    }

    print "[Strings]\n";
    my $count = (scalar @strings) >= 10 ? 9: (scalar @strings) -1;
    print map {$strings[$_]."\n"} (0..$count);

    print "[Comments]\n";
    $count = 0;
    foreach my $item (@comments) {
      next if $item =~ /^#!/;
      print "$item" and $count++ ;
      last if $count >= 5;
    }

  close $IN_FILE;
}

sub  find_strings_comments {
  my $end_index = 0;
  while (my ($char, $start_index) = &next_char($off_set)) {
    last if ($char eq "" && $start_index == -1);
    if ($char eq '#') {
      $end_index = index $src, "\n", $start_index + 1;
      push @comments, substr($src, $start_index, $end_index-$start_index+1);
      $off_set = $end_index + 1;
    } elsif (($char eq '"') || ($char eq "'")) {
      &capture_string($char, $start_index, $end_index);
    }
  }
}

sub capture_string($ $ $) {
  my $quote = shift;
  my $start_index = shift;
  my $end_index = shift;

  $end_index = index ($src, $quote, $start_index+1);
  my $char_before = substr $src, $end_index-1, 1;

  while ($end_index > 0 && $char_before eq '\\') {
    $end_index = index $src, $quote, $end_index + 1;
    $char_before = substr $src, $end_index-1, 1;
  }

  push @strings, substr($src, $start_index, $end_index-$start_index+1);
  $off_set = $end_index + 1;
}

sub next_char {
  my %has;
  my $position = shift;

  my $s_index = index $src, "'", $position;
  my $d_index = index $src, '"', $position;
  my $c_index = index $src, '#', $position;

  return ("", -1) if ($s_index == -1 &&
                      $d_index == -1 &&
                      $c_index == -1);

  $has{$s_index} = "'" if ($s_index >= 0);
  $has{$d_index} = '"' if ($d_index >= 0);
  $has{$c_index} = '#' if ($c_index >= 0);

  my @sorted_keys = sort { $a <=> $b} keys %has;
  # print "Next char is $has{$sorted_keys[0]}, and position is $sorted_keys[0]\n";
  return ($has{$sorted_keys[0]}, $sorted_keys[0]);
}

=head1 NAME

SLP - Perl - Assignment 1::PartB 

=head1 SYNOPSIS

    ./PartB.pl scriptFileName
    ./PartB.pl Hello.pl
    ./PartB.pl Hello.pm

=head1 DESCRIPTION

This module is for scripting language programming assignment 1 PartB.
It is to analyse another Perl script specified as the first argument.

The Acceptable file extensions are .pl and .pm.

=over 5

=item 1 

It displays the number of lines, words, and characters;

=item 2

Identify the keywords in the script file, and display in the order as they first appeared in the file.  If a keyword appeared multiple times, only the first instance should be displayed and display the first 15 keywords only;

=item 3

Identify the strings in the script file, and display in the order as they appeared in the file, display the first 10 strings only;

=item 4

Identify the comments in the script file, display in the order as they appeared in the file, display the first 5 comments only.

=back

=head1 ASSUMPTIONS

=over 4

=item *

Keywords appeared in strings and comments are not considered keywords;

=item *

a string may appear on multiple lines;

=item *

comments may appear inside strings or regular expressions;

=item *

single or double quoted strings may appear in comments;

=back

=head1 AUTHOR

Haiyan Zhang

=cut  
