#!/usr/bin/python
import os
import keyerror
import glob
import time
import shutil
import re

class Enrol:
  def __init__(self, dirname):
    self.class_list = []
    self.subs = {}
    self.directory = dirname
    self.sub_filename = os.path.join(self.directory, "SUBJECTS")
    self.class_fname  = os.path.join(self.directory, "CLASSES")
    self.allsubs = readlines(self.sub_filename)
    self.allclasses = readlines(self.class_fname)
    self.class_stundet_files = glob.glob(os.path.join(self.directory, "*.roll"))

    for line in self.allsubs:
      code, name = line.split(":")
      self.subs[code] = name

  def checkStudent(self, student_id, subject_id = ""):
    class_list = []
    if not subject_id:
      for filename in self.class_stundet_files:
        if student_id in open('%s' %filename).read():
          filename = os.path.basename(filename)
          class_list.append(filename[:-5])
    else:
      for a_class in self.classes(subject_id):
        if student_id in open('%s' %a_class+".roll").read():
          a_class = os.path.basename(a_class)
          class_list.append(a_class)

    return class_list

  def students_of_class(self, class_name):
    filename = os.path.join(self.directory, (class_name + ".roll"))
    student_list = []
    student_list = readlines(filename)
    return student_list

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
      raise KeyError()

  def classInfo(self, class_id):
    sub_name = ""
    for line in self.allclasses:
      if (class_id in line):
        sub_name = line.split(":")[0].split(".")[0]
        class_date = line.split(":")[2]
        class_room = line.split(":")[3]
        class_tutor = line.split(":")[4]
        student_list = self.students_of_class(class_id)

    if (sub_name):
      return (sub_name, class_date, class_room, class_tutor, student_list)
    else:
      raise KeyError("Class not found")

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
      for line in lines:
        f.write(line + "\n")
  except IOError:
    f.close
    shutil.rmtree(tmpfile)
    value = 0
    return value
  else:
    f.close
    shutil.move(tmpfile, filename)
    value = 1
    return value
