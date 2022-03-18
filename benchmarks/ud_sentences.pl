#!/usr/bin/env perl
use strict;
use warnings;

# Comparison path
my $cmd = '/euralex/corpus/empirist_gold_cmc/tools/compare_tokenization.perl';
# my $cmd = '/euralex/corpus/deep-eos/eval.py';

my $cleanup = 'perl /euralex/benchmarks/cleanup/';
my $tokenize_eos = $cleanup . 'tokenize_eos.pl';
my $tokenize_nn = $cleanup . 'tokenize_nn.pl';

# Output path
my $ud_path = '/euralex/ud_eos';
mkdir $ud_path;

my $base = 'de_gsd-ud-train.conllu';

# Split files
chdir '/euralex/corpus/';
system 'perl /euralex/benchmarks/cleanup/split_conllu.pl /euralex/corpus/' . $base;
chdir '/euralex';

my $gold = '/euralex/corpus/' . $base . '.eos';
my $raw = '/euralex/corpus/' . $base . '.raw';

my %tools = (
  waste => sub {
    system 'cat ' . $raw . ' | waste -N -v0 --rcfile=./Waste/waste.rc | ' . $tokenize_nn . ' > ' . $ud_path . '/waste/' . $base;
  },
  datok => sub {
    system 'cat ' . $raw . ' | ./Datok/datok tokenize -t ./Datok/testdata/tokenizer.matok - | ' . $tokenize_nn . ' > ' . $ud_path . '/datok/' . $base;
  },
  cutter => sub {
    system 'python3 ./cutter/cutter.py sent ' . $raw . ' | ' . $tokenize_eos. ' > ' . $ud_path . '/cutter/' . $base;
  },
  korap_tokenizer => sub {
    system 'cat ' . $raw . ' | java -jar ./KorAP-Tokenizer/KorAP-Tokenizer.jar -s -l de | ' . $tokenize_nn . ' > ' . $ud_path . '/korap_tokenizer/' . $base;
  },
  'opennlp_sentence' => sub {
    system 'cat ' . $raw . ' | ./opennlp/bin/opennlp SentenceDetector ./opennlp/models/opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin 2> /dev/null > ' . $ud_path . '/opennlp_sentence/' . $base;
  },
  jtok => sub {
    chdir '/euralex/JTok/bin';
    system 'sh tokenize ' . $raw . ' de utf8 | ' . $cleanup . '/jtok.pl > ' . $ud_path . '/jtok/' . $base;
    chdir '/euralex';
  },
  syntok => sub {
    system 'python3 -m syntok.segmenter ' . $raw . ' | ' . $cleanup . '/tokenize_simple.pl > ' . $ud_path . '/syntok/' . $base;
  },
  somajo => sub {
    system 'somajo-tokenizer --split_sentences ' . $raw . ' 2> /dev/null | ' . $tokenize_nn . ' > ' . $ud_path . '/somajo/' . $base;
  },
  stanford => sub {
    system 'CLASSPATH=/euralex/stanford-corenlp-4.4.0/* java edu.stanford.nlp.pipeline.StanfordCoreNLP ' .
      '-props german -annotators tokenize,ssplit,mwt -tokenize.language=german -file ' . $raw . ' 2> /dev/null';
    system 'perl /euralex/benchmarks/cleanup/stanford.pl ' . $base . '.raw.out | ' . $tokenize_nn . ' > ' . $ud_path . '/stanford/' . $base;
    system 'rm ' . $base . '.raw.out';
  },
  nnsplit => sub {
    system './nnsplit/nnsplit_bench ' . $raw . ' | ' . $tokenize_eos. ' > ' . $ud_path . '/nnsplit/' . $base
  },
  spacy_dep => sub {
    system 'python3 ./spacy/spacy_sent.py dep ' . $raw . ' | ' . $tokenize_eos . ' > ' . $ud_path . '/spacy_dep/' . $base
  },
  spacy_stat => sub {
    system 'python3 ./spacy/spacy_sent.py stat ' . $raw . ' | ' . $tokenize_eos . ' > ' . $ud_path . '/spacy_stat/' . $base
  },
  spacy_sentencizer => sub {
    system 'python3 ./spacy/spacy_sent.py sentencizer ' . $raw . ' | ' . $tokenize_eos . ' > ' . $ud_path . '/spacy_sentencizer/' . $base
  },
  'deep-eos_bi-lstm-de' => sub {
    system 'python3 ./deep-eos/main.py --input-file '.$raw.' --model-filename ./deep-eos/bi-lstm-de.model --vocab-filename ./deep-eos/bi-lstm-de.vocab --eos-marker "</eos>" tag | ' . $tokenize_eos . ' > ' . $ud_path . '/deep-eos_bi-lstm-de/' . $base;
  },
  'deep-eos_cnn-de' => sub {
    system 'python3 ./deep-eos/main.py --input-file '.$raw.' --model-filename ./deep-eos/cnn-de.model --vocab-filename ./deep-eos/cnn-de.vocab --eos-marker "</eos>" tag | ' . $tokenize_eos . ' > ' . $ud_path . '/deep-eos_cnn-de/' . $base;
  },
  'deep-eos_lstm-de' => sub {
    system 'python3 ./deep-eos/main.py --input-file '.$raw.' --model-filename ./deep-eos/lstm-de.model --vocab-filename ./deep-eos/lstm-de.vocab --eos-marker "</eos>" tag | ' . $tokenize_eos . ' > ' . $ud_path . '/deep-eos_lstm-de/' . $base;;
  },
);


#delete $tools{waste};
#delete $tools{datok};
#delete $tools{korap_tokenizer};
#delete $tools{'opennlp_sentence'};
#delete $tools{jtok};
#delete $tools{syntok};
#delete $tools{somajo};
#delete $tools{stanford};
#delete $tools{nnsplit};
#delete $tools{'deep-eos_bi-lstm-de'};
#delete $tools{'deep-eos_cnn-de'};
#delete $tools{'deep-eos_lstm-de'};
#delete $tools{'spacy_dep'};
#delete $tools{'spacy_stat'};
#delete $tools{'spacy_sentencizer'};
#delete $tools{'cutter'};


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
