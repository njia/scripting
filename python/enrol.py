#!/usr/bin/python
import glob
import os
import re
import shutil
import time

class Enrol:
  def __init__(self, dirname):
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

    # generate a dict of subject code and name
    for line in self.allsubs:
      if ":" in line:
        code, name = line.split(":")
        self.subs[code] = name

    # generate a dict of class to class room mapping
    for line in self.allclasses:
      if ":" in line:
        class_name = line.split(":")[0]
        class_room = line.split(":")[3]
        self.class_to_room[class_name] = class_room

    # genereate a dict of class room to number of seats mapping
    for line in self.all_class_venues:
      if ":" in line:
        class_room = line.split(":")[0]
        class_venue = line.split(":")[1]
        self.classroom_venuse[class_room] = class_venue

  # get subject name by class ID used by stat client
  def get_subject_name_by_classid(self, class_id):
    for line in self.allclasses:
      if class_id in line:
        sub_id = line.split(":")[1]
        return self.subjectName(sub_id)

  # get number of student of a subject, used by stat client
  def number_of_student_of_sub(self, subject_id):
    class_list = self.classes(subject_id)
    total = 0
    for c in class_list:
      fname = os.path.join(self.directory, (c + ".roll"))
      total += len(readlines(fname))

    return total

  # debug fuction
  def printClassFileName(self):
    for filename in self.class_stundet_files:
      print filename

  # debug fuction
  def printVenues(self):
    for key in self.classroom_venuse.keys():
      print key + " => " + self.classroom_venuse[key]

  # debug fuction
  def printClassRoom(self):
    for key in self.class_to_room.keys():
      print key + " => " + self.class_to_room[key]

  # checkStudent function see assignment spec for details
  def checkStudent(self, student_id, subject_id = ""):
    class_list = []
    if not subject_id:
      for filename in self.class_stundet_files:
        if student_id in open('%s' %filename).read():
          # print "filename before os.path.basename " + filename
          filename = os.path.basename(filename)
          # print "filename after os.path.basename " + filename
          class_list.append(filename[:-5])
    else:
      for a_class in self.classes(subject_id):
        filename = os.path.join(self.directory, (a_class + ".roll"))
        if student_id in readlines(filename):
          a_class = os.path.basename(a_class)
          class_list.append(a_class)

    if len(class_list) == 1:
      return class_list[0]
    elif (subject_id == ""):
      return class_list
    else:
      return None

  # return the student list of a class
  def students_of_class(self, class_name):
    filename = os.path.join(self.directory, (class_name + ".roll"))
    student_list = []
    student_list = readlines(filename)
    return student_list

  # return a list of all subjects
  def subjects(self):
    mylist = list(self.subs.keys())
    mylist.sort()
    return mylist

  # get subject name by subject code
  def subjectName(self, code):
    if (str(code) in self.subs):
      return self.subs[code]
    else:
      return

  # return a list of all classes of a specified subject
  def classes(self, sub_code):
    class_list = []
    for line in self.allclasses:
      if (sub_code in line):
        class_list.append(line.split(":")[0])

    if len(class_list) > 0:
      return class_list
    else:
      raise KeyError()

  # return class related information, like class code, class room,
  # date and time and who is teaching the class
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

  # return subject code of a class id, raise KeyError if class ID is not found
  def subject_of_class(self, class_id):
    if class_id not in self.class_to_room:
      raise KeyError

    for a_class in self.allclasses:
      if class_id in a_class:
        return a_class.split(":")[1]

  # enrol fuction, see assignment for spec
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

# utility function, part 1
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

# utility function, part 1
def readtable(filename):
  f = open('%s' % filename, "r")
  myLines = []
  for line in f:
    myLines.append(line.strip().split(":"))

  f.close
  return myLines

# utility function, part 1
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

# simple function to get total number of lines of a file
def file_len(fname):
  with open(fname) as f:
    for i, l in enumerate(f):
      pass
  return i + 1
