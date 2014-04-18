#!/usr/bin/env perl

use warnings;
use strict;
use 5.010;

my @str_and_comm = ();
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

open my $OUT, ">", "out.html" or die "Could not write to out.html\n";
select $OUT;
print "<pre>\n";

while ($off_set < (length $src)) {
$char = substr $src, $off_set, 1;

if ($char eq '#') {
    $end_index = index $src, "\n", $off_set+ 1;
    my $c = substr($src, $off_set, $end_index-$off_set+1);
    push @str_and_comm, $c;
    print $comment_color.$c.$color_end;
  } elsif (($char eq '"') || ($char eq "'")) {
    $end_index = index ($src, $char, $off_set+1);
    my $char_before = substr $src, $end_index-1, 1;

    while ($end_index > 0 && $char_before eq '\\') {
      $end_index = index $src, $char, $end_index + 1;
      $char_before = substr $src, $end_index-1, 1;
    }
    my $s = substr($src, $off_set, $end_index-$off_set+1);
    push @str_and_comm, $s;
    print $string_color.$s.$color_end;
    } else {
    print $char;
    $end_index++;
  }
    $off_set = $end_index + 1;
}

print "\n</pre>\n";
close $OUT;

&find_keywords($src);

open my $OUT_FILE, ">", $output_file or die "Could not write to $output_file\n";
print $OUT_FILE "<pre>\n";

open my $fd, "<", "out.html" or die "Missing out.html\n";

  foreach my $line (<$fd>) {
    print $OUT_FILE $line and next if $line =~ /^\s*($comment_color)/;
    foreach my $kw (keys %unique_keywords) {
      $line =~ s/\b$kw\b/$keyward_color$kw$color_end/g;
    }
    $line =~ s/($fnumber_regex|$bin_oct_hex)/$number_color$1$color_end/g;
    print $OUT_FILE $line;
  }

  print $OUT_FILE "</pre>\n";
  close $OUT_FILE;
  close $fd;
  unlink "out.html";
  exit 0;

# Read file into src
sub read_file {
  open my $IN_FILE, "<", $input_file or die "Could not read from $input_file\n";
  local $/ = undef;
  $src = <$IN_FILE>;
  close $IN_FILE;
}

# find Perl keywords
sub find_keywords {
  my %perl_key_words = &get_keywords;
  my $number_of_keywords = 0;
  my $src = shift;

  foreach my $item (@str_and_comm) {
    $src =~ s/$item//g;
  }

  foreach my $line (split "\n", $src) {
    next if $line =~ /^\s*#/;
    foreach my $word (split " ", $line) {
      $word =~ s/[^@\$%&a-zA-Z_-]//g;
      if ($perl_key_words{$word}) {
        $unique_keywords{$word}++;
      }
    }
  }
}

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

