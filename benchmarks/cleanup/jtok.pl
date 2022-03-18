#!/usr/bin/env perl
use strict;
use warnings;

my $init = 1;
my $c = '';
foreach (<>) {
  if (s/\s +Token: \"// && s/^(\"?[^\"]*?)\".+?$/$1/g) {
    $c .= $_;
  }
  elsif (m/Text Unit Start/) {
    if ($init) {
      $init = 0;
    } else {
      $c =~ s/[\s\n\t]+//g;
      print $c,"\n";
      $c = '';
    };
  };
};

print "\n";
