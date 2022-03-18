#!/usr/bin/env perl
use strict;
use warnings;

my $c = '';
foreach (<>) {
  $c .= $_;
};
$c =~ s/^\n+//s;
foreach my $c (split(/\n\n/, $c)) {
  $c =~ s/[\s\n\t]+//g;
  print $c, "\n";
};

