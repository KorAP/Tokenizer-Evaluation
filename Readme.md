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
  korap/euralex22 benchmarks/benchmark.pl
```


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
