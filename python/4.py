#!/usr/bin/python

import sys

def longest(strlist):
  index = 0
  longeststr = ''
  for string in strlist:
    if len(string) > index:
      index = len(string)
      longeststr = string

  print longeststr
  print(sys.argv[1:].index(longeststr))

longest(sys.argv[1:])
