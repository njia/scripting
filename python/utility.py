#!/usr/bin/python
import re

def readlines(filename):
  f = open('%s' % filename, "r")
  myLines = []
  for line in f:
    if (re.search('^\s*#', line)):
      continue
    else:
      myLines.append(line.strip())

  return myLines

