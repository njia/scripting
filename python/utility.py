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
    with open('%s' % tmpfile, "w") as f:
      f.write(lines + "\n")
  except IOError:
    shutil.rmtree(tmpfile)
    value = 0
  else:
    shutil.move(tmpfile, filename)
    value = 1
  finally:
    f.close
    return value




