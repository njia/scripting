#!/usr/bin/env python

import sys

def aver(mylist):
    total, count = 0,0
    for number in mylist:
        print "number is" , int(number)
        count += 1

    print count


aver(sys.argv[1:])


