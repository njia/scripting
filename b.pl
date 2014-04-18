#!/usr/bin/env perl
use strict;
use warnings;

my @strings = ();
my @comments = ();
my $off_set = 0;
my $end_index = 0;
my $char;
my $input_file = shift;

my $string_color  = '<code style=color:royalblue>';
my $keyward_color = '<code style=color:darkred>';
my $number_color  = '<code style=color:darkcyan>';
my $comment_color = '<code style=color:darkgreen>';
my $color_end      = '</code>';

my $src;

sub read_file {
  open my $IN, "<", $input_file or die "Can't read from $input_file\n";
  local $/ = undef;
  $src = <$IN>;
  print "length of string is ", length $src, "\n";
}

&read_file;

open my $OUT_FILE, ">", "out.html" or die "Could not write to out.html\n";

select $OUT_FILE;

print "<pre>\n";

while ($char = (substr $src, $off_set, 1)) {
  print STDOUT $char."\n";
  print STDOUT "offerset is $off_set \n";
  print STDOUT "length of string is ", length $src, "\n";

  if ($char eq '#') {
    $end_index = index $src, "\n", $off_set+ 1;
    my $c = substr($src, $off_set, $end_index-$off_set+1);
    print $comment_color.$c.$color_end;
  } elsif (($char eq '"') || ($char eq "'")) {
    $end_index = index ($src, $char, $off_set+1);
    my $char_before = substr $src, $end_index-1, 1;

    while ($end_index > 0 && $char_before eq '\\') {
      $end_index = index $src, $char, $end_index + 1;
      $char_before = substr $src, $end_index-1, 1;
    }
    my $s = substr($src, $off_set, $end_index-$off_set+1);
    print $string_color.$s.$color_end;
  } elsif ( $char eq '' ) {
    print "0";
  } else {
    print $char;
    $end_index++;
  }
    $off_set = $end_index + 1;
    # last if $off_set == (length $src) -2;
}

print "\n</pre>\n";
close $OUT_FILE;
exit 0;
