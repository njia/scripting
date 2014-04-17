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

sub print_keywords_strings_comments {
  my @strings  = &find_strings($_[0]);
  my @comments = &find_comments($_[0]);
  my %perl_key_words = &get_keywords;
  my $number_of_keywords = 0;
  my %seen = ();
  
  open my $IN_FILE, "<", $_[0] or die "print_keywords: Could not read from file $_[0]\n";
  local $/ = undef;
  my $file_content = <$IN_FILE>;

  foreach my $item (@strings) {
    $file_content =~ s/$item//sg;
  }

  foreach my $item (@comments) {
    $file_content =~ s/$item//g;
  }

  print "[Keywords]\n";
    foreach my $word (split " ", $file_content) {
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
    $count = (scalar @comments) >= 5 ? 4: (scalar @comments) -1;
    print map {$comments[$_]} (0..$count);

  close $IN_FILE;
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
  push @strings, $content =~ /"(?:[^\\"]|\\.)*"|'(?:[^\\"]|\\.)*'/gs;
  close $IN_FILE;

  return @strings;
}

my $input_file = $ARGV[0];

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

&print_keywords_strings_comments($input_file);
