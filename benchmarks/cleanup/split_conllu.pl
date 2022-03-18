#!/usr/bin/env perl
use strict;
use warnings;

our @ARGV;

my $file = $ARGV[0];
my $file_name = $file;
$file_name =~ s!^.+?/([^/]+?)$!$1!;


my $out = $ARGV[1];

open(X, '<' . $file);
unlink $file . '.raw';
open(RAW, '>' . $out . '/' . $file_name . '.raw') or die $!;
unlink $file . '.split';
open(SPLIT, '>' . $out . '/' . $file_name . '.split') or die $!;
unlink $file . '.eos';
open(EOS, '>' . $out . '/' . $file_name . '.eos') or die $!;

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
