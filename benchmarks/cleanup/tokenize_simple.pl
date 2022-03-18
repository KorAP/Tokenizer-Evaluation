#!/usr/bin/env perl
use strict;
use warnings;

foreach (<>) {
  s/[\s\n\t]+//g;
  print $_, "\n";
};
