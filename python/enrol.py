#!/usr/bin/python
import utility
import os

class Enrol:
  def __init__(self, dirname):
    self.subs = {}
    self.directory = dirname
    self.sub_filename = os.path.join(self.directory, "SUBJECTS")
    alllines = utility.readlines(self.sub_filename)
    for line in alllines:
      code, name = line.split(":")
      self.subs[code] = name

  def subjects(self):
    mylist = list(self.subs.keys())
    mylist.sort()
    return mylist

  def subjectName(self, code):
    if (str(code) in self.subs):
      return self.subs[code]
    else:
      return
