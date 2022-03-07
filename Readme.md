# Creating the container

To build the Docker image, run

```shell
$ docker build -f Dockerfile -t korap/euralex22 .
```
This will download and install an image of approximately 6GB.

It will download and install the following
tokenizers in an image to your system:

...

To run the evaluation suite ...

...


# Running the evaluation suite

To run the benchmark, call

```shell
$ docker run --rm -it \
  -v ${PWD}/benchmarks:/euralex/benchmarks \
  -v ${PWD}/corpus:/euralex/corpus \
  korap/euralex22 benchmarks/[BENCHMARK-SCRIPT]
```

The supported benchmark scripts are:

## `benchmark.pl`

Performance measurements of the tools. See the tools section for some
remarks to take into account.


## `empirist.pl`

To run the empirist test suite, you need to download the empirist
gold standard corpus and tooling first and extract it into
the corpus directory.

```shell
$ wget https://sites.google.com/site/empirist2015/home/shared-task-data/empirist_gold_cmc.zip
$ unzip empirist_gold_cmc.zip -d corpus

$ wget https://sites.google.com/site/empirist2015/home/shared-task-data/empirist_gold_web.zip
$ unzip empirist_gold_web.zip -d corpus
```

To run the evaluation using the measurement tools provided by EmpiriST 2015,
run

```shell
$ docker run --rm -it \
  -v ${PWD}/benchmarks:/euralex/benchmarks \
  -v ${PWD}/corpus:/euralex/corpus \
  korap/euralex2 benchmarks/empirist.pl
```


Quality measurements based on EmpiriST 2015.

To investigate the output, start the benchmark with mounted
output folders

```
-v ${PWD}/output_cmc:/euralex/empirist_cmc
-v ${PWD}/output_web:/euralex/empirist_web
```


# Tools

## Waste
- Tokenization

## OpenNLP
- Tokenization

## TreeTagger
- Tokenization

## JTok
- Tokenization

## SynTok
- Tokenization

## SoMaJo
- Tokenization

## Stanford CoreNLP
- Tokenization

All tools are run using [pipelining](https://stanfordnlp.github.io/CoreNLP/pipeline.html),
which obviously introduces some overhead, that needs to be taken into account.

## KorAP-Tokenizer
- Tokenization + Sentence Splitting

## Datok
- Tokenization + Sentence Splitting


# Licenses

For Treetagger:
Please read the [license terms](https://cis.uni-muenchen.de/~schmid/tools/TreeTagger/Tagger-Licence),
before you download the software!
By downloading the software, you agree to the terms stated there. 


# Caveat

When running this benchmark using Docker you may need
to run all processes privileged to get
[meaningful results](https://pythonspeed.com/articles/docker-performance-overhead/).

```shell
docker run --privileged -v
```

# Literature
