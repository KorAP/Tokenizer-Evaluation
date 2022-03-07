#!/usr/bin/env perl
use strict;
use warnings;

# This script rewrites the pipeline output
# of the stanford parser for tokenize,ssplit,mwt

our @ARGV;

if (open(my $file, '<' . $ARGV[0])) {
  foreach (readline($file)) {
    if (s/^\[Text\=(.+?)\s+CharacterOffsetBegin\=\d+\s+CharacterOffsetEnd=\d+\]$/$1/) {
      print $_;
    }
    elsif (m/^Sentence\s+\#\d+\s+\(/) {
      print "\n";
    };
  };

  print "Done.";
  close($file);
}
else {
  warn 'Unable to open file'
};
