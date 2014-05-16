#!/usr/bin/python
import utility
import os

class Enrol:
  def __init__(self, dirname):
    self.subs = {}
    self.directory = dirname
    self.sub_filename = os.path.join(self.directory, "SUBJECTS")
    self.class_fname  = os.path.join(self.directory, "CLASSES")
    self.allsubs = utility.readlines(self.sub_filename)
    self.allclasses = utility.readlines(self.class_fname)
    print self.allclasses
    for line in self.allsubs:
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

  def classes(self, class_id):
    for line in self.allclasses:
      if (class_id in line):
        print line.split(":")[0]
