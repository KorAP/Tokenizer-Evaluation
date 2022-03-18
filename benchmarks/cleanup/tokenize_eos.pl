#!/usr/bin/env perl
use strict;
use warnings;

my $c = '';
foreach (<>) {
  $c .= $_;
};

foreach my $c (split("</eos>", $c)) {
  $c =~ s/[\s\n\t]+//g;
  print $c, "\n";
};

