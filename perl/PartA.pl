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
        print $word, "\n" unless ($seen{$word} || ($number_of_keywords >= 15));
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
  my $number = (scalar @comments >= 5) ? 4 : (scalar @comments ) -1;
  print map {$comments[$_]} (0..$number);
  close $IN_FILE;
}

sub print_strings {
  open my $IN_FILE, "<", $_[0] or die "print_strings: Could not read from file $_[0]\n";
  print "[Strings]\n";
  my @strings = ();
  while (<$IN_FILE>) {
    s/^([^#]*?)(#.*?$)/$1/ if /#/;
    push @strings, map {$_."\n"} /(".*?"|'.*?')/g
  }
  my $number = (scalar @strings >= 10) ? 9 : (scalar @strings) -1;
  print map {$strings[$_]} (0..$number);
  close $IN_FILE;
}

my $input_file = $ARGV[0];

die "Error: unable to analyse the specified file.\n" if !defined $input_file;
chomp $input_file;

unless ( $input_file =~ /.p[l|m]$/ && -R -f -s -T $input_file) {
  die "Error: unable to analyse the specified file.\n";
  exit 1;
}

print "File: $input_file\n";

my $result = `wc -l -w -m $input_file`;
my ($lines, $words, $chars) = $result =~ /[0-9]+/g;

print "Lines: $lines\n";
print "Words: $words\n";
print "Chars: $chars\n";

&print_keywords($input_file);
&print_strings($input_file);
&print_comments($input_file);

=head1 NAME

SLP - Perl - Assignment 1::PartA 

=head1 SYNOPSIS

    ./PartA.pl scriptFileName
    ./PartA.pl Hello.pl
    ./PartA.pl Hello.pm

=head1 DESCRIPTION

This module is for scripting language programming assignment 1 PartA.
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

=head1 FUNCTIONS

=over 12

=item C<get_keywords>

Return the hash containing keywords

This function download Perl keyword html file from learn.perl.org and create keyword;

=item C<print_keywords>
 
Print the first 15 keywords in the order as they appear;

=item C<print_comments>

Print the first 5 comments in the order as they appear;

=item C<print_strings>

Print the first 10 comments in the order as they appear;

=back

=head1 ASSUMPTIONS

=over 4

=item *

Keywords appeared in strings and comments are still considered keywords;

=item *

a string is always on the same line;

=item *

comments do not appear inside strings or regular expressions;

=item *

single or double quoted strings do not appear in comments;

=back


=head1 AUTHOR

Haiyan Zhang

=cut  
