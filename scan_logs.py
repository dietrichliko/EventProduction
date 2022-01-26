#!/usr/bin/python3

import os
import fnmatch


DIRS= [
"Minbias-NoPileUp-2011/log",
# "Minbias-PileUp-2011/log"
]

for dir in DIRS:
    for name in sorted(os.listdir(dir)):
        if not fnmatch.fnmatch(name, "*.err"):
            continue
        path = os.path.join(dir, name)
        print(path)   
