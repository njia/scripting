#!/usr/bin/env perl
use strict;
use warnings;

my $src = do {local $/; <DATA>};

my @strings = ();
my @comments = ();
my $off_set = 0;
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

print "[Strings]\n";
foreach my $item (@strings) {
  print "$item\n";
}

print "[Comments]\n";
foreach my $item (@comments) {
  print "$item";
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


__DATA__
# this is a comment, should be matched.
# # "I am not a string" . 'because I am inside a comment'
my $string = " #I am not a comment, because I am quoted";
my $another_string = "I am a multiline string with # on
                      each line #, have fun!";
my $descap_string = "I am a \ escaped \" \"string"; # and some comments;
my $sescap_string = 'I am a \ escaped \' \'string'; # and some comments;
my $empty_d ="";
my $empty_s ='';
