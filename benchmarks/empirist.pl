#!/usr/bin/env perl
use strict;
use warnings;

# Comparison path
my $cmd = '/euralex/corpus/empirist_gold_cmc/tools/compare_tokenization.perl';

# Output path
my $empirist_path = '/euralex/empirist_';
mkdir $empirist_path . 'cmc';
mkdir $empirist_path . 'web';

my $gold_path = '/euralex/corpus/empirist_gold_';

my %tools = (
  waste => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'cat ' . $raw . ' | waste -N -v0 --rcfile=./Waste/waste.rc > ' . $empirist_path . $_[1] . '/waste/' . $_[0],
  },
  datok => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'cat ' . $raw . ' | ./Datok/datok tokenize -t ./Datok/testdata/tokenizer.matok - > ' . $empirist_path . $_[1] . '/datok/' . $_[0];
  },
  korap_tokenizer => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'cat ' . $raw . ' | java -jar ./KorAP-Tokenizer/KorAP-Tokenizer.jar -l de > ' . $empirist_path . $_[1] . '/korap_tokenizer/' . $_[0];
  },
  opennlp_simple => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'cat ' . $raw . ' | ./opennlp/bin/opennlp SimpleTokenizer 2> /dev/null | sed "s/\s/\n/g" > ' . $empirist_path . $_[1] . '/opennlp_simple/' . $_[0];
  },
  opennlp_tokenizer => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'cat ' . $raw . ' | ./opennlp/bin/opennlp TokenizerME ./opennlp/models/opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin 2> /dev/null | sed "s/\s/\n/g" > ' . $empirist_path . $_[1] . '/opennlp_tokenizer/' . $_[0];
  },
  tree_tagger => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'cat ' . $raw . ' | perl ./treetagger/cmd/utf8-tokenize.perl -a ./treetagger/lib/german-abbreviations 2> /dev/null > ' . $empirist_path . $_[1] . '/tree_tagger/' . $_[0];
  },
  jtok => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    chdir '/euralex/JTok/bin';
    system 'sh tokenize ' . $raw . ' de | grep "Token: " | perl -CS -pe "s/\s +Token: \"//; s/^(\"?[^\"]*?)\".+?$/\1/g" > ' . $empirist_path . $_[1] . '/jtok/' . $_[0];
    chdir '/euralex';
  },
  syntok => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'python3 -m syntok.tokenizer ' . $raw . ' | sed "s/\s/\n/g" > ' . $empirist_path . $_[1] . '/syntok/' . $_[0];
  },
  somajo => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'somajo-tokenizer ' . $raw . ' 2> /dev/null > ' . $empirist_path . $_[1] . '/somajo/' . $_[0];
  },
  stanford => sub {
    my $raw = $gold_path . $_[1] . '/raw/' . $_[0];
    system 'CLASSPATH=/euralex/stanford-corenlp-4.4.0/* java edu.stanford.nlp.pipeline.StanfordCoreNLP ' .
      '-props german -annotators tokenize,ssplit,mwt -tokenize.language=german -file ' . $raw . ' 2> /dev/null';
    system 'perl /euralex/benchmarks/cleanup/stanford.pl ' . $_[0] . '.out > ' . $empirist_path . $_[1] . '/stanford/' . $_[0];
    system 'rm ' . $_[0] . '.out';
  }
);

#delete $tools{waste};
#delete $tools{datok};
#delete $tools{korap_tokenizer};
#delete $tools{opennlp_simple};
#delete $tools{opennlp_tokenizer};
#delete $tools{tree_tagger};
#delete $tools{jtok};
#delete $tools{syntok};
#delete $tools{somajo};
#delete $tools{stanford};

# Create project folders
foreach (keys %tools) {
  mkdir $empirist_path . 'cmc/' . $_;
  mkdir $empirist_path . 'web/' . $_;
};


# Run the CMC test suite
my @files = (
  'cmc_test_blog_comment.txt',
  'cmc_test_professional_chat.txt',
  'cmc_test_social_chat.txt',
  'cmc_test_twitter.txt',
  'cmc_test_whatsapp.txt',
  'cmc_test_wiki_discussion.txt',
);


# Run tokenization
foreach my $file (@files) {
  foreach (keys %tools) {
    $tools{$_}->($file, 'cmc');
  }
};

foreach my $tool (keys %tools) {
  print "\n##########\n";
  print "##### $tool - Empirist-CMC\n";
  print "##\n";
  system $cmd . ' -x ' . $gold_path . 'cmc/tokenized/ ' . $empirist_path . 'cmc/' . $tool . '/ 2> /dev/null';
};


# Run the Web test suite
@files = (
  'web_test_001.txt',
  'web_test_002.txt',
  'web_test_003.txt',
  'web_test_004.txt',
  'web_test_005.txt',
  'web_test_006.txt',
  'web_test_007.txt',
  'web_test_008.txt',
  'web_test_009.txt',
  'web_test_010.txt',
  'web_test_011.txt',
  'web_test_012.txt'
);

# Run tokenization
foreach my $file (@files) {
  foreach (keys %tools) {
    $tools{$_}->($file, 'web');
  }
};

foreach my $tool (keys %tools) {
  print "\n##########\n";
  print "##### $tool - Empirist-Web\n";
  print "##\n";
  system $cmd . ' -x ' . $gold_path . 'web/tokenized/ ' . $empirist_path . 'web/' . $tool . '/ 2> /dev/null';
};
