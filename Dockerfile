FROM --platform=linux/amd64 debian:bookworm-slim

WORKDIR /TOKENBENCH

RUN echo "Dies ist ein Test. Also, nur ein Beispiel." > example.txt

RUN apt-get update && \
    apt-get install -y git \
    wget \
    unzip \
    perl \
    golang

############
# Check WC #
############
RUN echo "WC\n" && wc -w ./example.txt


##################
# Install SoMaJo #
##################
RUN apt-get install -y python3-dev \
    python3 \
    python3-pip && \
    pip3 install SoMaJo==2.2.0

RUN echo "SOMAJO\n" && somajo-tokenizer --split_sentences ./example.txt


###################
# Install OpenNLP #
###################
RUN apt-get install -y openjdk-11-jdk

RUN wget https://dlcdn.apache.org/opennlp/opennlp-1.9.4/apache-opennlp-1.9.4-bin.zip && \
    unzip apache-opennlp-1.9.4-bin.zip -x apache-opennlp-1.9.4/docs/* && \
    rm apache-opennlp-1.9.4-bin.zip && \
    mv apache-opennlp-1.9.4 opennlp && \
    mkdir ./opennlp/models && \
    wget https://dlcdn.apache.org/opennlp/models/ud-models-1.0/opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin && \
    wget https://dlcdn.apache.org/opennlp/models/ud-models-1.0/opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin && \
    mv opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin ./opennlp/models/ && \
    mv opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin ./opennlp/models/

RUN echo "OpenNLP (1)\n" && cat example.txt | ./opennlp/bin/opennlp SimpleTokenizer 

RUN echo "OpenNLP (2)\n" && cat example.txt | ./opennlp/bin/opennlp TokenizerME ./opennlp/models/opennlp-de-ud-gsd-tokens-1.0-1.9.3.bin

RUN echo "OpenNLP (3)\n" && cat example.txt | ./opennlp/bin/opennlp SentenceDetector ./opennlp/models/opennlp-de-ud-gsd-sentence-1.0-1.9.3.bin


######################
# Install TreeTagger #
######################
RUN mkdir ./treetagger && \
    cd treetagger && \
    wget https://cis.uni-muenchen.de/~schmid/tools/TreeTagger/data/tagger-scripts.tar.gz && \
    tar -xvzf tagger-scripts.tar.gz && \
    rm tagger-scripts.tar.gz

RUN echo "TreeTagger\n" && cat example.txt | ./treetagger/cmd/utf8-tokenize.perl -a ./treetagger/lib/german-abbreviations


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
    pip3 install --upgrade tensorflow

RUN pip3 install keras

RUN sed -i 's/from keras.utils import plot_model/from tensorflow.keras.utils import plot_model/' ./deep-eos/eos.py

RUN echo "deep-eos (1)\n" && python3 ./deep-eos/main.py --input-file example.txt --model-filename ./deep-eos/cnn-de.model --vocab-filename ./deep-eos/cnn-de.vocab --eos-marker "§" tag

RUN echo "deep-eos (2)\n" && python3 ./deep-eos/main.py --input-file example.txt --model-filename ./deep-eos/bi-lstm-de.model --vocab-filename ./deep-eos/bi-lstm-de.vocab --eos-marker "§" tag

RUN echo "deep-eos (3)\n" && python3 ./deep-eos/main.py --input-file example.txt --model-filename ./deep-eos/lstm-de.model --vocab-filename ./deep-eos/lstm-de.vocab --eos-marker "§" tag


################
# Install JTok #
################

RUN apt-get install -y maven

RUN wget https://github.com/DFKI-MLT/JTok/archive/refs/tags/v2.1.19.zip && \
    unzip v2.1.19.zip && \
    rm v2.1.19.zip && \
    cd JTok-2.1.19 && \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 mvn clean package assembly:single && \
    cd .. && \
    unzip ./JTok-2.1.19/target/jtok-core-2.1.19-bin.zip && \
    rm -r JTok-2.1.19 && \
    mv jtok-core-2.1.19 JTok

RUN echo "JTok\n" && \
    cd ./JTok/bin && \
    sh tokenize /tokenbench/example.txt de


##################
# Install Syntok #
##################
RUN pip3 install syntok==1.4.3

RUN echo "Syntok (1)\n" && python3 -m syntok.tokenizer ./example.txt

RUN echo "Syntok (2)\n" && python3 -m syntok.segmenter ./example.txt


#################
# Install Waste #
#################
RUN mkdir Waste && \
    cd Waste && \
    wget https://cudmuncher.de/~moocow/mirror/projects/moot/moot-2.0.20-1.tar.gz && \
    wget https://kaskade.dwds.de/waste/waste-models/waste-data.de-dstar-tiger.tar.gz && \
    tar -xvzf moot-2.0.20-1.tar.gz && \
    tar -xvzf waste-data.de-dstar-tiger.tar.gz
    
RUN cd ./Waste/moot-2.0.20-1 && \
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    echo "abbrevs /tokenbench/Waste/de-dstar-dtiger/abbr.lex\nstopwords /tokenbench/Waste/de-dstar-dtiger/stop.lex\nconjunctions /tokenbench/Waste/de-dstar-dtiger/conj.lex\nmodel /tokenbench/Waste/de-dstar-dtiger/model.hmm" > /tokenbench/Waste/waste.rc

RUN echo "Waste\n" && cat ./example.txt | waste -N --rcfile=./Waste/waste.rc


###################
# Install nnsplit #
###################

COPY nnsplit_bench /tokenbench/nnsplit_bench/

RUN apt-get update && apt-get install -y cargo

RUN cd ./nnsplit_bench && \
    cargo build --release

RUN mkdir ./nnsplit && \
    mv ./nnsplit_bench/target/release/nnsplit_bench ./nnsplit/nnsplit_bench && \
    rm -r ./nnsplit_bench/target

RUN echo "nnsplit\n" && ./nnsplit/nnsplit_bench example.txt

####################
# Install Elephant #
####################

RUN apt-get install -y python2

RUN ln -s /usr/bin/python2 /usr/bin/python

RUN git clone https://github.com/erwanm/elephant-wrapper.git && \
    cd elephant-wrapper/third-party && \
    git clone https://github.com/ParallelMeaningBank/elephant.git && \
    git clone https://github.com/Jekub/Wapiti.git && \
    git clone https://github.com/mspandit/rnnlm.git

RUN cd elephant-wrapper && \
    make && \
    make install && \
    cd .. && \
    mv ./elephant-wrapper/bin/elephant /usr/local/bin/ && \
    mv ./elephant-wrapper/bin/wapiti /usr/local/bin/

RUN echo "Elephant-Wrapper" && ./elephant-wrapper/bin/tokenize.sh -i example.txt UD_German


#################
# Install SpaCy #
#################

RUN pip3 install click==8.0.4 && \
    pip3 install -U spacy==3.2.3

COPY spacy /tokenbench/spacy/

RUN echo "SpaCy" && python3 ./spacy/spacy_tok.py example.txt

# Sentence splitter
RUN python3 -m spacy download de_core_news_sm && \
    python3 -m spacy download de_dep_news_trf


###########################
# Install Stanford parser #
###########################

# Following https://stanfordnlp.github.io/CoreNLP/index.html

RUN wget https://nlp.stanford.edu/software/stanford-corenlp-latest.zip

RUN wget https://search.maven.org/remotecontent?filepath=edu/stanford/nlp/stanford-corenlp/4.4.0/stanford-corenlp-4.4.0-models-german.jar -O stanford-corenlp-4.4.0-models-german.jar

RUN unzip stanford-corenlp-latest.zip && \
    rm stanford-corenlp-latest.zip && \
    mv stanford-corenlp-4.4.0-models-german.jar stanford-corenlp-4.4.0/

# Run with threads!
RUN echo "StanfordNLP" && \
    CLASSPATH=/tokenbench/stanford-corenlp-4.4.0/* java edu.stanford.nlp.pipeline.StanfordCoreNLP \
    -annotators tokenize \
    -tokenize.language=german \
    -file example.txt


##################
# Install Cutter #
##################

RUN pip3 install cutter-ng==2.5

COPY cutter /tokenbench/cutter/

RUN echo "Cutter\n" && python3 ./cutter/cutter.py nosent example.txt


#####################
# Install BlingFire #
#####################

RUN pip3 install -U blingfire==0.1.8

COPY blingfire /tokenbench/blingfire/

RUN echo "BlingFire\n" && python3 ./blingfire/blingfire_tok.py example.txt


#################
# Install Datok #
#################

RUN wget https://github.com/KorAP/Datok/archive/refs/tags/v0.1.5.zip && \
    unzip v0.1.5.zip && \
    rm v0.1.5.zip && \
    mv Datok-0.1.5 Datok && \
    cd Datok && \
    go build ./cmd/datok.go

RUN echo "DATOK\n" && cat example.txt | ./Datok/datok tokenize -t ./Datok/testdata/tokenizer.matok -


###########################
# Install KorAP-Tokenizer #
###########################

RUN mkdir KorAP-Tokenizer && \
    cd KorAP-Tokenizer && \
    wget https://github.com/KorAP/KorAP-Tokenizer/releases/download/v2.2.2/KorAP-Tokenizer-2.2.2-standalone.jar && \
    mv KorAP-Tokenizer-2.2.2-standalone.jar KorAP-Tokenizer.jar

RUN echo "KorAP-Tokenizer\n" && cat example.txt | java -jar KorAP-Tokenizer/KorAP-Tokenizer.jar -l de -s -


RUN useradd -ms /bin/bash tokenbench

RUN rm -r ./nnsplit_bench && \
    rm /tokenbench/v0.1.zip

RUN chown tokenbench:tokenbench -R /tokenbench

USER tokenbench

WORKDIR /tokenbench

ENTRYPOINT [ "perl" ]

LABEL maintainer="korap@ids-mannheim.de"
LABEL description="Tokenizer evaluation"