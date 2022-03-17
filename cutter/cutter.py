import Cutter
import sys

sys.setrecursionlimit(100000)

cutter = Cutter.Cutter(profile='de')

sent = sys.argv[1]

file = open(sys.argv[2], 'r')

text = file.read()

file.close()

for token in cutter.cut(text):
    if token[0]:
        print(token[0])

    if sent == "sent":
        if token[1].startswith("+EOS"):
            print("</eos>")
