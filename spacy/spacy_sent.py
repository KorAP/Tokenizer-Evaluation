import spacy
import sys
from spacy.lang.de import German

# slower and more accurate: ("de_dep_news_trf")

model = sys.argv[1]

if model == 'dep':
  nlp = spacy.load("de_core_news_sm")
elif model == 'stat':
  nlp = spacy.load("de_core_news_sm", exclude=["parser"])
  nlp.enable_pipe("senter")
elif model == 'sentencizer':
    nlp = German()
    nlp.add_pipe("sentencizer")
  
# Create a Sentence Splitter based on dependency parsing.

with open(sys.argv[2], 'r') as f:
    contents = f.read()

    nlp.max_length = len(contents) + 100

    doc = nlp(contents, disable = ['ner'])
    
    for sent in doc.sents:
        print(sent.text)
        print(" </eos> ")
