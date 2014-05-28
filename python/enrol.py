#!/usr/bin/python
import glob
import keyerror
import os
import re
import shutil
import time

class Enrol:
  def __init__(self, dirname):
    self.class_list = []
    self.subs = {}
    self.directory = dirname
    self.sub_filename = os.path.join(dirname, "SUBJECTS")
    self.class_filename  = os.path.join(dirname, "CLASSES")
    self.venues_filename = os.path.join(dirname, "VENUES")
    self.class_stundet_files = glob.glob(os.path.join(dirname, "*.roll"))
    self.allsubs = readlines(self.sub_filename)
    self.allclasses = readlines(self.class_filename)
    self.all_class_venues = readlines(self.venues_filename)
    self.class_to_room = {}
    self.classroom_venuse = {}

    for line in self.allsubs:
      if ":" in line:
        code, name = line.split(":")
        self.subs[code] = name

    for line in self.allclasses:
      if ":" in line:
        class_name = line.split(":")[0]
        class_room = line.split(":")[3]
        self.class_to_room[class_name] = class_room

    for line in self.all_class_venues:
      if ":" in line:
        class_room = line.split(":")[0]
        class_venue = line.split(":")[1]
        self.classroom_venuse[class_room] = class_venue

  def printClassFileName(self):
    for filename in self.class_stundet_files:
      print filename

  def printVenues(self):
    for key in self.classroom_venuse.keys():
      print key + " => " + self.classroom_venuse[key]

  def printClassRoom(self):
    for key in self.class_to_room.keys():
      print key + " => " + self.class_to_room[key]

  def checkStudent(self, student_id, subject_id = ""):
    class_list = []
    if not subject_id:
      for filename in self.class_stundet_files:
        if student_id in open('%s' %filename).read():
          filename = os.path.basename(filename)
          class_list.append(filename[:-5])
    else:
      for a_class in self.classes(subject_id):
        filename = os.path.join(self.directory, (a_class + ".roll"))
        if student_id in readlines(filename):
          a_class = os.path.basename(a_class)
          class_list.append(a_class)

    if len(class_list) == 1:
      return class_list[0]
    elif len(class_list) == 0:
      return None
    else:
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
      raise KeyError(class_id)

  def subject_of_class(self, class_id):
    if class_id not in self.class_to_room:
      raise KeyError

    for a_class in self.allclasses:
      if class_id in a_class:
        return a_class.split(":")[1]

  def enrol(self, student_id, class_id):
    if class_id not in self.class_to_room.keys():
      raise KeyError

    filename = os.path.join(self.directory, (class_id + ".roll"))
    a_list = readlines(filename)
    if student_id in a_list:
      # print "studnet %s already enrolled in the class %s " %(student_id, class_id)
      return 1

    subject_class_list = self.classes(self.subject_of_class(class_id))
    subject_class_list.remove(class_id)

    for a_class in subject_class_list:
      filename = os.path.join(self.directory, (a_class + ".roll"))
      student_list_of_a_class = readlines(filename)
      if student_id in student_list_of_a_class:
        student_list_of_a_class.remove(student_id)
        writelines(filename, student_list_of_a_class)

    filename = os.path.join(self.directory, (class_id + ".roll"))
    student_list_of_class = readlines(filename)
    class_room = self.class_to_room[class_id]
    if (int(self.classroom_venuse[class_room]) > len(student_list_of_class)):
      student_list_of_class.append(student_id)
      writelines(filename, student_list_of_class)
      return 1
    else:
      return

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
