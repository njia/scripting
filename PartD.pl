#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;

my $lines = 0;
my @words = ();
my @chars = ();

my @strings = ();
my @comments = ();
my @numbers = ();

my %unique_strings;
my %unique_comments;
my %unique_keywords;

my $fnumber_regex = qr{(?<!['|"|\w|\[|#])([-+]?([0-9_]+(\.[0-9_]+)?|[-+]?\.[0-9_]+)([eE]?[-+]?[0-9_]+)?)(?!['|"|\w])};
my $bin_oct_hex = qr{(0[x|X][0-9a-fA-F_]+)|(0[0-7]+?)|(0[b|B][01_]+)};
my $dquo_re = qr{"(?:(?>[^"\\]+)|\\.)*"};
my $squo_re = qr{'(?:(?>[^'\\]+)|\\.)*'};
my $comment_re = qr{(?<!\$)#.*};

my $string_color  = '<code style=color:royalblue>';
my $keyward_color = '<code style=color:darkred>';
my $number_color  = '<code style=color:darkcyan>';
my $comment_color = '<code style=color:darkgreen>';
my $color_end      = '</code>';
my $src;
my $off_set = 0;
my $end_index = 0;
my $char;

my $input_file = shift;
die "Error: unable to analyse the specified file.\n" if !defined $input_file;
chomp $input_file;

unless ( $input_file =~ /\.p[l|m]$/ && -R -f -s -T $input_file) {
  die "Error: unable to analyse the specified file.\n";
  exit 1;
}

my $output_file = shift;
die "Error: need output file name\n" if !defined $output_file;
die "Error: please enter a output file name with .htm or .html.\n" unless $output_file =~ /\.htm|\.html$/;

&read_file;

sub read_file {
  open my $IN_FILE, "<", $input_file or die "Could not read from $input_file\n";
  local $/ = undef;
  $src = <$IN_FILE>;
  close $IN_FILE;
}


  $src =~ s/($dquo_re)/$string_color$1$color_end/g;
  $src =~ s/($squo_re)/$string_color$1$color_end/g;
  $src =~ s/($comment_re)/$comment_color$1$color_end/g;

  &find_keywords($src);

  open my $OUT_FILE, ">", $output_file or die "Could not write to $output_file\n";
  print $OUT_FILE "<pre>\n";

  foreach my $line (split "\n", $src) {
    print $OUT_FILE $line."\n" and next if $line =~ /^\s*($comment_color)/;
    foreach my $kw (keys %unique_keywords) {
      $line =~ s/\b$kw\b/$keyward_color$kw$color_end/g;
    }
    $line =~ s/($fnumber_regex|$bin_oct_hex)/$number_color$1$color_end/g;
    print $OUT_FILE $line."\n";
  }

  print $OUT_FILE "</pre>\n";
  close $OUT_FILE;
  exit 0;

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

sub find_keywords {
  my %perl_key_words = &get_keywords;
  my $number_of_keywords = 0;
  my $src = shift;

  foreach my $item (@strings) {
    $src =~ s/$item//g;
  }

  foreach my $item (@comments) {
    $src =~ s/$item//g;
  }

  foreach my $word (split " ", $src) {
    if ($word =~ /^[-|+|\d|.]/) {
      # push @numbers, $1 if $word =~ s/([-+]?([0-9_]+(\.[0-9_]+)?|[-+]?\.[0-9_]+)([eE]?[-+]?[0-9_]+)?)\b//;
      # push @numbers, $1 if $word =~ /((0[x|X][0-9a-fA-F_]+)|(0[0-7]+?)|(0[b|B][01_]+))/;
    } else {
      $word =~ s/[^@\$%&a-zA-Z_-]//g;
      if ($perl_key_words{$word}) {
        $unique_keywords{$word}++;
      }
    }
  }
}
