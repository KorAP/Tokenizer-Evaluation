#!/usr/bin/env perl
use strict;
use warnings;
use Benchmark qw!:hireswallclock :all!;
use Data::Dumper;
use POSIX 'round';

my $FILE = 'effi-1x-utf8.txt';

system 'gzip -dkf ./corpus/' . $FILE . '.gz';

my $iter = 1;

# Result of wc -w
my $effi_wc = `wc -w ./corpus/$FILE`;
$effi_wc =~ s/^(\d+)\s.*$/$1/;


my $models = {
  'wc' => sub {
    system 'wc -w ./corpus/'.$FILE.' > /dev/null';
  },
  'SoMaJo' => sub {
    system 'somajo-tokenizer ./corpus/'.$FILE.' --split_sentences > /dev/null';
  },
  'SoMaJo_p2' => sub {
    system 'somajo-tokenizer ./corpus/'.$FILE.' --parallel=2 --split_sentences > /dev/null';
  },
  'Datok_matok' => sub {
    system 'cat ./corpus/'.$FILE.' | ./Datok/datok tokenize -t ./Datok/testdata/tokenizer.matok - > /dev/null'
  },
  'Datok_datok' => sub {
    system 'cat ./corpus/'.$FILE.' | ./Datok/datok tokenize -t ./Datok/testdata/tokenizer.datok - > /dev/null'
  },
  'OpenNLP_Simple' => sub {
    system 'cat ./corpus/'.$FILE.' | ./opennlp/bin/opennlp SimpleTokenizer > /dev/null';
  },
  'OpenNLP_Tokenizer_de-ud-gsd' => sub {
    system 'cat ./corpus/'.$FILE.' | ./opennlp/bin/opennlp TokenizerME ./opennlp/models/opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin > /dev/null';
  },
  'OpenNLP_Sentence_de-ud-gsd' => sub {
    system 'cat ./corpus/'.$FILE.' | ./opennlp/bin/opennlp SentenceDetector ./opennlp/models/opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin > /dev/null';
  },
  'TreeTagger' => sub {
    system 'cat ./corpus/'.$FILE.' | perl ./treetagger/cmd/utf8-tokenize.perl -a ./treetagger/lib/german-abbreviations > /dev/null';
  },
  'deep-eos_bi-lstm-de' => sub {
    system 'python3 ./deep-eos/main.py --input-file ./corpus/'.$FILE.' --model-filename ./deep-eos/bi-lstm-de.model --vocab-filename ./deep-eos/bi-lstm-de.vocab --eos-marker "§" tag > /dev/null';
  },
  'deep-eos_cnn-de' => sub {
    system 'python3 ./deep-eos/main.py --input-file ./corpus/'.$FILE.' --model-filename ./deep-eos/cnn-de.model --vocab-filename ./deep-eos/cnn-de.vocab --eos-marker "§" tag > /dev/null';
  },
  'deep-eos_lstm-de' => sub {
    system 'python3 ./deep-eos/main.py --input-file ./corpus/'.$FILE.' --model-filename ./deep-eos/lstm-de.model --vocab-filename ./deep-eos/lstm-de.vocab --eos-marker "§" tag > /dev/null';
  },
  'JTok' => sub {
    chdir '/euralex/JTok/bin';
    system 'sh tokenize ../../corpus/'.$FILE.' de > /dev/null';
    chdir '/euralex';
  },
  'KorAP-Tokenizer' => sub {
    system 'cat ./corpus/'.$FILE.' | java -jar ./KorAP-Tokenizer/KorAP-Tokenizer.jar -l de -s > /dev/null'
  },
  Syntok_tokenizer => sub {
    system 'python3 -m syntok.tokenizer ./corpus/'.$FILE.' > /dev/null';
  },
  Syntok_segmenter => sub {
    system 'python3 -m syntok.segmenter ./corpus/'.$FILE.' > /dev/null';
  },
  Waste => sub {
    system 'cat ./corpus/'.$FILE.' | waste -N -v0 --rcfile=./Waste/waste.rc > /dev/null';
  },
  nnsplit => sub {
    system './nnsplit/nnsplit_bench ./corpus/'.$FILE.' > /dev/null'
  },
  elephant => sub {
    system './elephant-wrapper/bin/tokenize.sh -i ./corpus/'.$FILE.' UD_German > /dev/null'
  },
  SpaCy => sub {
    system 'python3 ./spacy/spacy_tok.py ./corpus/'.$FILE.' > /dev/null'
  },
  Stanford => sub {
    system 'CLASSPATH=/euralex/stanford-corenlp-4.4.0/* java edu.stanford.nlp.pipeline.StanfordCoreNLP ' .
      '-props german -annotators tokenize,ssplit,mwt -tokenize.language=german -file ./corpus/' . $FILE
  },
  Stanford_t4 => sub {
    system 'CLASSPATH=/euralex/stanford-corenlp-4.4.0/* java edu.stanford.nlp.pipeline.StanfordCoreNLP ' .
      '-props german -annotators tokenize,ssplit,mwt -tokenize.language=german -threads=4 -file ./corpus/' . $FILE
  }
};

#delete $models->{'SoMaJo'};
#delete $models->{'SoMaJo_p2'};
#delete $models->{'Datok_matok'};
#delete $models->{'Datok_datok'};
#delete $models->{'OpenNLP_Simple'};
#delete $models->{'OpenNLP_Tokenizer_de-ud-gsd'};
#delete $models->{'OpenNLP_Sentence_de-ud-gsd'};
#delete $models->{'TreeTagger'};
#delete $models->{'deep-eos_bi-lstm-de'};
#delete $models->{'deep-eos_cnn-de'};
#delete $models->{'deep-eos_lstm-de'};
#delete $models->{'JTok'};
#delete $models->{'KorAP-Tokenizer'};
#delete $models->{'Syntok_tokenizer'};
#delete $models->{'Syntok_segmenter'};
#delete $models->{'Waste'};
#delete $models->{'nnsplit'};
#delete $models->{'elephant'};
#delete $models->{'SpaCy'};
#delete $models->{'Stanford'};
#delete $models->{'Stanford_t4'};


my $t0 = Benchmark->new;
my $cmp = timethese($iter => $models);

print "\n----------------------------------\n";

foreach my $tool (sort keys %$cmp) {
  my $seconds_per_run = $cmp->{$tool}->[0] / $cmp->{$tool}->[5];
  my $tokens_per_msecond = ($effi_wc / $seconds_per_run) / 1000;
  print $tool, "\t", $seconds_per_run, "\t", $tokens_per_msecond, "\t", sprintf("%.2f", $tokens_per_msecond), "\n";
};

print "\n----------------------------------\n";

cmpthese($cmp);

print "Benchmarking took: ", timestr(timediff(Benchmark->new, $t0)), "\n";

