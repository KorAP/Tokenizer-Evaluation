import sys

from spacy.lang.de import German

nlp = German()

# Create a Tokenizer with the default settings for English
# including punctuation rules and exceptions
tokenizer = nlp.tokenizer

with open(sys.argv[1], 'r') as f:
    contents = f.read()

    tokens = tokenizer(contents)

    for t in tokens:
        print(t)
