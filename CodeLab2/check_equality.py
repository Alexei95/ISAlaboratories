import sys

with open(sys.argv[1], 'r') as f:
    with open(sys.argv[2], 'r') as g:
        a = g.read().splitlines()
        b = f.read().splitlines()
        print("-" * 100)
        print("|" + ''.rjust(5) + "|" + sys.argv[1].rjust(
            30) + "|" + sys.argv[2].ljust(30) + "|" + "distance".center(30) + "|")
        print("-" * 100)
        for pos, c in enumerate(a):
            if b[pos] != c:
                print("|" + str(pos).rjust(5) + "|" +
                      b[pos].rjust(30) + "|" + c.ljust(30) + "|" + str(int(b[pos]) - int(c)).center(30) + "|")
                print("-" * 100)
