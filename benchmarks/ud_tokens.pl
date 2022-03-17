#!/usr/bin/env perl
use strict;
use warnings;

# Comparison path
my $cmd = '/euralex/corpus/empirist_gold_cmc/tools/compare_tokenization.perl';

# Output path
my $ud_path = '/euralex/ud_tokens';
mkdir $ud_path;

my $base = 'de_gsd-ud-train.conllu';

# Split files
chdir '/euralex/corpus/';
system 'perl /euralex/benchmarks/cleanup/split_conllu.pl /euralex/corpus/' . $base;
chdir '/euralex';

my $gold = '/euralex/corpus/' . $base . '.split';
my $raw = '/euralex/corpus/' . $base . '.raw';

my %tools = (
  waste => sub {
    system 'cat ' . $raw . ' | waste -N -v0 --rcfile=./Waste/waste.rc > ' . $ud_path . '/waste/' . $base;
  },
  datok => sub {
    system 'cat ' . $raw . ' | ./Datok/datok tokenize -t ./Datok/testdata/tokenizer.matok - > ' . $ud_path . '/datok/' . $base;
  },
  korap_tokenizer => sub {
    system 'cat ' . $raw . ' | java -jar ./KorAP-Tokenizer/KorAP-Tokenizer.jar -l de > ' . $ud_path . '/korap_tokenizer/' . $base;
  },
  opennlp_simple => sub {
    system 'cat ' . $raw . ' | ./opennlp/bin/opennlp SimpleTokenizer 2> /dev/null | sed "s/\s/\n/g" > ' . $ud_path . '/opennlp_simple/' . $base;
  },
  opennlp_tokenizer => sub {
    system 'cat ' . $raw . ' | ./opennlp/bin/opennlp TokenizerME ./opennlp/models/opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin 2> /dev/null | sed "s/\s/\n/g" > ' . $ud_path . '/opennlp_tokenizer/' . $base;
  },
  tree_tagger => sub {
    system 'cat ' . $raw . ' | perl ./treetagger/cmd/utf8-tokenize.perl -a ./treetagger/lib/german-abbreviations 2> /dev/null > ' . $ud_path . '/tree_tagger/' . $base;
  },
  jtok => sub {
    chdir '/euralex/JTok/bin';
    system 'sh tokenize ' . $raw . ' de | grep "Token: " | perl -CS -pe "s/\s +Token: \"//; s/^(\"?[^\"]*?)\".+?$/\1/g" > ' . $ud_path . '/jtok/' . $base;
    chdir '/euralex';
  },
  syntok => sub {
    system 'python3 -m syntok.tokenizer ' . $raw . ' | sed "s/\s/\n/g" > ' . $ud_path . '/syntok/' . $base;
  },
  elephant => sub {
    system './elephant-wrapper/bin/tokenize.sh -i ' . $raw . ' UD_German | sed "s/\s/\n/g" > ' . $ud_path . '/elephant/' . $base;
  },
  spacy => sub {
    system 'python3 ./spacy/spacy_tok.py ' . $raw . ' > ' . $ud_path . '/spacy/' . $base;
  },
  cutter => sub {
    system 'python3 ./cutter/cutter.py nosent ' . $raw . ' > ' . $ud_path . '/cutter/' . $base;
  },
  somajo => sub {
    system 'somajo-tokenizer ' . $raw . ' 2> /dev/null > ' . $ud_path . '/somajo/' . $base;
  },
  stanford => sub {
    system 'CLASSPATH=/euralex/stanford-corenlp-4.4.0/* java edu.stanford.nlp.pipeline.StanfordCoreNLP ' .
      '-props german -annotators tokenize,ssplit,mwt -tokenize.language=german -file ' . $raw . ' 2> /dev/null';
    system 'perl /euralex/benchmarks/cleanup/stanford.pl ' . $base . '.raw.out > ' . $ud_path . '/stanford/' . $base;
    system 'rm ' . $base . '.raw.out';
  }
);

# delete $tools{waste};
# delete $tools{datok};
# delete $tools{korap_tokenizer};
# delete $tools{opennlp_simple};
# delete $tools{opennlp_tokenizer};
# delete $tools{tree_tagger};
# delete $tools{jtok};
# delete $tools{syntok};
# delete $tools{somajo};
# delete $tools{stanford};
# delete $tools{elephant};
# delete $tools{spacy};
# delete $tools{cutter};

# Create project folders
foreach (keys %tools) {
  mkdir $ud_path . '/' . $_;
};

# Run tokenization
foreach (keys %tools) {
  $tools{$_}->();
};

foreach my $tool (keys %tools) {
  print "\n##########\n";
  print "##### $tool - UD\n";
  print "##\n";
  system $cmd . ' -x ' . $gold . ' ' . $ud_path . '/' . $tool . '/' . $base . ' 2> /dev/null';
};
