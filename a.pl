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
    &capture_comment($start_index);
  } elsif (($char eq '"') || ($char eq "'")) {
    &capture_string($char, $start_index, $end_index);
  }
}

print "[Strings]\n";
foreach my $item (@strings) {
  print "$item\n";
}

print "[Comments]\n";
foreach my $item (@comments) {
  print "$item";
}

sub capture_comment($) {
  my $start_index = shift;
  my $char_before = substr $src, $start_index-1, 1;
  # print "\$char_before before # is $char_before\n";
  if ((substr $src, $start_index-1, 1) ne "\$") {
    $end_index = index $src, "\n", $start_index + 1;
    push @comments, substr($src, $start_index, $end_index-$start_index+1);
    $off_set = $end_index + 1;
  } else {
    $off_set = $start_index + 1;
    # print "Arry index variable found\n";
    next;
  }
}

sub capture_string($ $ $) {
  my $quote = shift;
  my $start_index = shift;
  my $end_index = shift;

  $end_index = index ($src, $quote, $start_index+1);

  CHECK_BACKSLASH:
  my $char_before = substr $src, $end_index-1, 1;
  # print "\$char_before is $char_before\n";

  if ($char_before eq '\\') {
    # print "There is a \\ before $quote\n";
    # print "end index before checking backslash $end_index \n";

    if (&odd_number_backslash($char_before, $start_index, $end_index) == 1) {
      # print "end index after checking backslash $end_index \n";
      $end_index = index $src, $quote, $end_index + 1;
      # print "end index after checking backslash and another index $end_index \n";
      goto CHECK_BACKSLASH;
    }
  }

  push @strings, substr($src, $start_index, $end_index-$start_index+1);
  $off_set = $end_index + 1;
}

sub odd_number_backslash($ $ $) {
  my $char_before = shift;
  my $start_index = shift;
  my $end_index = shift;
  my $count = 0;

  if ($char_before eq '\\') {
    my $ts = substr $src, $start_index, $end_index-$start_index;
    # print "\$ts is $ts\n";
    while ($count <= length $ts) {
      if (chop $ts eq '\\') {
        $count++;
      } else {
        last;
      }
    }
    # print "\$count is $count\n";
    return ($count % 2);
  } else {
    # print "else \$count is $count\n";
    return 1;
  }
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
my $string = "this is a \" string";
my $windows_path = "C:\\somewhere\\not\\important\\"; # and a comment " yep
# this is a comment, should be matched.
# # "I am not a string" . 'because I am inside a comment'
my $string = " #I am not a comment, because I am quoted";
my $another_string = "I am a multiline string with # on
                      each line #, have fun!";
my @list = (0..99);
print $#list;
my $descap_string = "I am a \ escaped \" \"string"; # and some comments after double;
my $sescap_string = 'I am a \ escaped \' \'string'; # and some comments after single;
my $sescap_string = 'I am a \ escaped \' \'\'\'\'\\'; # and some ' comments by Miller;
my $windows_path = "C:\\somewhere\\not\\important\\"; # and a comment ", yep
    my @array = (1..12);
my $empty_d ="";
my $empty_s ='';

