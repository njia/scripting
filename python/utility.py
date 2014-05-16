#!/usr/bin/python
import re
import time
import shutil

def readlines(filename):
  f = open('%s' % filename, "r")
  myLines = []
  for line in f:
    if (re.search('^\s*#', line)):
      continue
    else:
      myLines.append(line.strip())

  f.close
  return myLines

def readtable(filename):
  f = open('%s' % filename, "r")
  myLines = []
  for line in f:
    myLines.append(line.strip().split(":"))

  f.close
  return myLines

def writelines(filename, lines):
  tmpfile = str(time.time())
  try:
    f = open('%s' % tmpfile, "w")
    f.write(lines + "\n")
  except IOError:
    f.close
    shutil.rmtree(tmpfile)
    return 0
  else:
    f.close
    shutil.move(tmpfile, filename)




