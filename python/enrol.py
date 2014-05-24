#!/usr/bin/python
import utility
import os
import keyerror
import glob

class Enrol:
  def __init__(self, dirname):
    self.class_list = []
    self.subs = {}
    self.directory = dirname
    self.sub_filename = os.path.join(self.directory, "SUBJECTS")
    self.class_fname  = os.path.join(self.directory, "CLASSES")
    self.allsubs = utility.readlines(self.sub_filename)
    self.allclasses = utility.readlines(self.class_fname)
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
    student_list = utility.readlines(filename)
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
      raise KeyError("Not Found")

  def classinfo(self, class_id):
    class_info = []
    for line in self.allclasses:
      if (class_id in line):
        class_info = (line.split(":")[0], line.split(":")[2], line.split(":")[3], line.split(":")[4])

    if len(class_info) > 0:
      student_list = self.students_of_class(class_id)
      return (class_info, student_list)
    else:
      raise KeyError("Class not found")
