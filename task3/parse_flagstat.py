#!/usr/bin/env python3

import re
import sys

with open(sys.argv[1]) as f:
    text = f.read()

m = re.search(r'mapped \(([\d.]+)%', text)

if m:
    print(m.group(1))
else:
    print("ERROR")

