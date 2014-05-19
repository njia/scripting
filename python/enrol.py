#!/usr/bin/python
import utility
import os
import keyerror

class Enrol:
  def __init__(self, dirname):
    self.class_list = []
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

  def classes(self, sub_code):
    for line in self.allclasses:
      if (sub_code in line):
        self.class_list.append(line.split(":")[0])

    if len(self.class_list) > 0:
      return self.class_list
    else:
      raise KeyError("Not Found")

  def classinfo(self, class_id):
    class_info = []
    for line in self.allclasses:
      if (class_id in line):
        class_info = (line.split(":")[0], line.split(":")[2], line.split(":")[3], line.split(":")[4])

    if len(class_info) > 0:
      return class_info
    else:
      raise KeyError("Class not found")
