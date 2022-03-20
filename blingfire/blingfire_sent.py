import sys
from blingfire import *

with open(sys.argv[1], 'r') as f:
    contents = f.read()

    print(text_to_sentences(contents))

