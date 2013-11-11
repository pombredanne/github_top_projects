#from pigtest import PigTestCase, main
from testlib import PigTestCase
from unittest import main

class FilterTest(PigTestCase):

    PigScript = 'top_projects'

    def testFilterAndDate(self):
        self.stubAlias('events', [
            ['ForkedRepo', 'ForkEvent', '2013-02-07T10:00:42-08:00'],
            ['PushRepo', 'PushEvent ', '2013-02-07T10:00:42-08:00'],
            ['WatchRepo', 'WatchEvent', '2013-02-07T10:00:42-08:00']
        ])

        self.assertAliasEquals('events_with_date', [
            ('ForkedRepo', '2013-02'),
            ('WatchRepo', '2013-02')
        ])

    def testFinalOutput(self):
        records = list(self.getAlias('results'))
        self.assertTrue(3 == len(records))

        for (year_month, repo, score) in records:
            self.assertTrue(score > 1)

if __name__ == '__main__':
    main()
