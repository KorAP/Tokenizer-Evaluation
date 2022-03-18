#!/usr/bin/env perl
use strict;
use warnings;

our @ARGV;

my $file = $ARGV[0];

open(X, '<' . $file);
open(RAW, '>' . $file . '.raw');
open(SPLIT, '>' . $file . '.split');
open(EOS, '>' . $file . '.eos');

my $init;

while(!eof(X)) {
  local $_ = <X>;

  if (/^# text = (.+?)$/) {
    if ($init) {
      print SPLIT "\n";
      print RAW ' ';
    };
    print RAW $1;
    my $temp = $1;
    $temp =~ s/[\s\n\t]+//g;
    print EOS $temp, "\n";
  }
  elsif (m/^\d+[\s\t]/) {
    if (/^\d+[\s\t]+([^\t\s]+)[\t\s]/) {
      print SPLIT $1,"\n";
      $init = 1;
    }
  };
};

close(X);
close(RAW);
close(EOS);
close(SPLIT);
