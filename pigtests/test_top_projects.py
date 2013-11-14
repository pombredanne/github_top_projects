from testlib import PigTestCase
from unittest import main

class FilterTest(PigTestCase):

    PigScript = 'top_projects'

    def test__results__sorted_correctly(self):
        self.stubAlias('top_repos', [
            ['2013-02', 'repo_1', 3],
            ['2013-02', 'repo_2', 2],
            ['2013-02', 'repo_3', 7]
        ])

        self.assertAliasEquals('results', [
            ('2013-02', 'repo_3', 7),
            ('2013-02', 'repo_1', 3),
            ('2013-02', 'repo_2', 2),
        ])

if __name__ == '__main__':
    main()
