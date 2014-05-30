#!/usr/bin/python

import enrol
import os

try:
  directory = os.environ['ENROLDIR']
except KeyError:
  directory = os.path.join(os.getcwd() + "/data")
  if not os.path.exists(directory):
    print "Data directory does not exist"
    exit()

e = enrol.Enrol(directory)
for s in e.subjects():
  print s + " " + e.subjectName(s) + " classes: " + str(len(e.classes(s))) + " students " + str(e.number_of_student_of_sub(s))
