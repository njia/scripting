#! /usr/bin/env python2.6

import os
import shutil
import unittest

import enrol

class TestEnrol(unittest.TestCase):
    def setUp(self):
        self.data = 'test-data'

        self.fullpath = os.path.join(os.getcwd(), self.data)

        if os.path.exists(self.data):
            shutil.rmtree(self.data)

        os.mkdir(self.data)

        enrol.writelines(os.path.join(self.data, 'SUBJECTS'), [
            'bw101:Introductory Basketweaving 1',
            'bw110:Introductory Basketweaving 2',
            'bw330:Underwater Basketweaving'])

        enrol.writelines(os.path.join(self.data, 'CLASSES'), [
            'bw101.1:bw101:Mon 9.30:2.5.10:Alice Chiswick',
            'bw101.2:bw101:Wed 14.30:2.6.1:Bob Turnham',
            'bw330A:bw330:Tue 15.30:23.5.32:Carlos Stamford'])

        enrol.writelines(os.path.join(self.data, 'VENUES'),
            ['2.5.10:4', '2.5.11:18', '2.6.1:22', '23.5.32:50'])

        enrol.writelines(os.path.join(self.data, 'bw101.1.roll'),
            ['1124395', '1125622', '1109202', '1136607'])

        enrol.writelines(os.path.join(self.data, 'bw101.2.roll'),
            ['1887754'])

        enrol.writelines(os.path.join(self.data, 'bw330A.roll'),
            ['1125622', '1136607'])

        self.e = enrol.Enrol(self.data)

    def tearDown(self):
        if os.path.exists(self.data):
            shutil.rmtree(self.data)

    def testSubjects(self):
        result = self.e.subjects()
        result.sort()

        self.assertEqual(result, ['bw101', 'bw110', 'bw330'])

    def testSubjectNameValid(self):
        self.assertEqual(self.e.subjectName('bw110'), "Introductory Basketweaving 2")

    def testSubjectNameInvalid(self):
        self.assertEqual(self.e.subjectName('Guam'), None)

    def testClassesValid(self):
        result = self.e.classes('bw101')
        result.sort()

        self.assertEqual(result, ['bw101.1', 'bw101.2'])

    def testClassesInvalid(self):
        self.assertRaises(KeyError, self.e.classes, 'Guam')

    def testClassInfoValid(self):
        result = self.e.classInfo('bw101.1')

        lhs = result[:-1]
        rhs = result[-1]
        rhs.sort()

        repack = lhs + (rhs,)

        answer = ('bw101', 'Mon 9.30', '2.5.10', 'Alice Chiswick',
                  ['1109202', '1124395', '1125622', '1136607'])

        self.assertEqual(repack, answer)

    def testClassInfoInvalid(self):
        self.assertRaises(KeyError, self.e.classInfo, 'Guam')

    def testCheckStudentOneArgument(self):
        result = self.e.checkStudent('1125622')
        result.sort()

        self.assertEqual(result, ['bw101.1', 'bw330A']);

    def testCheckStudentOneArgumentNoEnrolments(self):
        self.assertEqual(self.e.checkStudent('Guam'), []);

    def testCheckStudentTwoArguments(self):
        self.assertEqual(self.e.checkStudent('1124395','bw101'), 'bw101.1')

    def testCheckStudentTwoArgumentsNotInClass(self):
        self.assertEqual(self.e.checkStudent('1124395','bw330'), None)

    def _checkRollInMemory(self, classid, answer):
        result = self.e.classInfo(classid)
        inmemory = result[-1]
        inmemory.sort()

        self.assertEqual(inmemory, answer)

    def _checkRollOnDisk(self, classid, answer):
        # We use a full path here as some scripts call os.chdir() which
        # modifies the working directory of this script too.
        ondisk = enrol.readlines(os.path.join(self.fullpath, classid + '.roll'))
        ondisk.sort()

        self.assertEqual(ondisk, answer)

    def testEnrolBasic(self):
        self.assertEqual(self.e.enrol('1887754', 'bw330A'), 1)

    def testEnrolBasicRollInMemeory(self):
        self.e.enrol('1887754', 'bw330A')
        self._checkRollInMemory('bw330A', ['1125622', '1136607', '1887754'])

    def testEnrolBasicRollOnDisk(self):
        self.e.enrol('1887754', 'bw330A')
        self._checkRollOnDisk('bw330A', ['1125622', '1136607', '1887754'])

    def testEnrolAdvanced(self):
        self.assertEqual(self.e.enrol('1124395', 'bw101.2'), 1)

    def testEnrolAdvancedFromRollInMemory(self):
        self.e.enrol('1124395', 'bw101.2')
        self._checkRollInMemory('bw101.1', ['1109202', '1125622', '1136607'])

    def testEnrolAdvancedFromRollOnDisk(self):
        self.e.enrol('1124395', 'bw101.2')
        self._checkRollOnDisk('bw101.1', ['1109202', '1125622', '1136607'])

    def testEnrolAdvancedToRollInMemory(self):
        self.e.enrol('1124395', 'bw101.2')
        self._checkRollInMemory('bw101.2', ['1124395', '1887754'])

    def testEnrolAdvancedToRollOnDisk(self):
        self.e.enrol('1124395', 'bw101.2')
        self._checkRollOnDisk('bw101.2', ['1124395', '1887754'])

    def testEnrolInvalidCapicity(self):
        self.assertEqual(self.e.enrol('1732341', 'bw101.1'), None)

    def testEnrolInvalidClass(self):
        self.assertRaises(KeyError, self.e.enrol, '1732341', 'Guam')

if __name__ == '__main__':
    unittest.main()
