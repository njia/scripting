#!/usr/bin/python

import sys

def aver(mylist):
  total, count = 0,0
  for number in mylist:
    total += int(number)
    count += 1
  print float (total/count)

aver(sys.argv[1:])


