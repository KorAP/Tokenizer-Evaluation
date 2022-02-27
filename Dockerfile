FROM --platform=linux/amd64 debian:bookworm-slim

WORKDIR /euralex

RUN echo "Dies ist ein Test. Also, nur ein Beispiel." > example.txt

RUN apt-get update && \
    apt-get install -y git \
    perl


############
# Check WC #
############
RUN echo "WC\n" && wc -w ./example.txt


##################
# Install SoMaJo #
##################
RUN apt-get install -y \
    python3-dev \
    python3 \
    python3-pip

RUN pip3 install SoMaJo

RUN echo "SOMAJO\n" && somajo-tokenizer --split_sentences ./example.txt

###################
# Install Datok #
###################
RUN apt-get install -y golang wget unzip && \
    wget https://github.com/KorAP/Datok/archive/refs/tags/v0.1.1.zip && \
    unzip v0.1.1.zip && \
    rm v0.1.1.zip && \
    mv Datok-0.1.1 Datok && \
    cd Datok && \
    go build ./cmd/datok.go

RUN echo "DATOK\n" && cat example.txt | ./Datok/datok tokenize -t ./Datok/testdata/tokenizer.matok -


###################
# Install OpenNLP #
###################
RUN apt-get install -y openjdk-11-jre

RUN wget https://dlcdn.apache.org/opennlp/opennlp-1.9.4/apache-opennlp-1.9.4-bin.zip && \
    unzip apache-opennlp-1.9.4-bin.zip -x apache-opennlp-1.9.4/docs/* && \
    rm apache-opennlp-1.9.4-bin.zip && \
    mv apache-opennlp-1.9.4 opennlp && \
    mkdir ./opennlp/models && \
    wget https://dlcdn.apache.org/opennlp/models/ud-models-1.0/opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin && \
    wget https://dlcdn.apache.org/opennlp/models/ud-models-1.0/opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin && \
    mv opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin ./opennlp/models/ && \
    mv opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin ./opennlp/models/

RUN echo "OpenNLP (1)" && cat example.txt | ./opennlp/bin/opennlp SimpleTokenizer 

RUN echo "OpenNLP (2)" && cat example.txt | ./opennlp/bin/opennlp TokenizerME ./opennlp/models/opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin

RUN echo "OpenNLP (3)" && cat example.txt | ./opennlp/bin/opennlp SentenceDetector ./opennlp/models/opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin


######################
# Install TreeTagger #
######################
RUN mkdir ./treetagger && \
    cd treetagger && \
    wget https://cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tagger-scripts.tar.gz && \
    tar -xvzf tagger-scripts.tar.gz && \
    rm tagger-scripts.tar.gz

RUN echo "TreeTagger" && cat example.txt | ./treetagger/cmd/utf8-tokenize.perl -a ./treetagger/lib/german-abbreviations


####################
# Install deep-eos #
####################
RUN wget https://github.com/dbmdz/deep-eos/archive/refs/tags/v0.1.zip && \
    unzip v0.1.zip && \
    mv deep-eos-0.1 deep-eos && \
    cd deep-eos && \
    wget https://github.com/dbmdz/deep-eos/releases/download/v0.1/cnn-de.model && \
    wget https://github.com/dbmdz/deep-eos/releases/download/v0.1/cnn-de.vocab && \
    wget https://github.com/dbmdz/deep-eos/releases/download/v0.1/bi-lstm-de.model && \
    wget https://github.com/dbmdz/deep-eos/releases/download/v0.1/bi-lstm-de.vocab && \
    wget https://github.com/dbmdz/deep-eos/releases/download/v0.1/lstm-de.model && \
    wget https://github.com/dbmdz/deep-eos/releases/download/v0.1/lstm-de.vocab

RUN pip3 install --upgrade pip && \
    pip3 install --upgrade tensorflow && \
    pip3 install keras && \
    sed -i 's/from keras.utils import plot_model/from tensorflow.keras.utils import plot_model/' ./deep-eos/eos.py

RUN echo "deep-eos (1)" && python3 ./deep-eos/main.py --input-file example.txt --model-filename ./deep-eos/cnn-de.model --vocab-filename ./deep-eos/cnn-de.vocab --eos-marker "§" tag

RUN echo "deep-eos (2)" && python3 ./deep-eos/main.py --input-file example.txt --model-filename ./deep-eos/bi-lstm-de.model --vocab-filename ./deep-eos/bi-lstm-de.vocab --eos-marker "§" tag

RUN echo "deep-eos (3)" && python3 ./deep-eos/main.py --input-file example.txt --model-filename ./deep-eos/lstm-de.model --vocab-filename ./deep-eos/lstm-de.vocab --eos-marker "§" tag


ENTRYPOINT [ "sh" ]

LABEL maintainer="korap@ids-mannheim.de"
LABEL description="Tokenizer evaluation for EURALEX"