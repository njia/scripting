#!/usr/bin/python

import enrol
import sys
import os

try:
  directory = os.environ['ENROLDIR']
except KeyError:
  directory = os.path.join(os.getcwd() + "/data")
  if not os.path.exists(directory):
    print "Data directory does not exist"
    exit()

e = enrol.Enrol(directory)

if len(sys.argv) == 1:
  for s in e.subjects():
    print s + " " + e.subjectName(s) + " classes: " + str(len(e.classes(s))) + " students " + str(e.number_of_student_of_sub(s))
elif (str(sys.argv[1]) == '--student' and len(sys.argv) == 3):
  class_list = e.checkStudent(sys.argv[2])
  for c in class_list:
    info = e.classInfo(c)
    print c +', ' + str(e.subjectName(info[0])) + ', ' + info[1] + ', ' + 'in ' + info[2]

