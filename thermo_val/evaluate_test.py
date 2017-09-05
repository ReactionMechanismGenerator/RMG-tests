import os
import unittest

import utils
from evaluate import *

class TestEvaluator(unittest.TestCase):

    def test_evaluate_performance(self):

        dataset_file = os.path.join(os.path.dirname(__file__), 
                                    'test_data',
                                    'dataset.txt')

        performance_dict = evaluate_performance(dataset_file)

        self.assertEqual(len(performance_dict), 1)
        self.assertEqual(performance_dict.keys()[0], ('sdata134k', 'rmg_rings_130_table'))
        self.assertAlmostEqual(performance_dict.values()[0], 0.2, 1)

        test_df_save_path = os.path.join(os.path.dirname(dataset_file),
                                        'test_df_{0}_{1}.csv'.format('sdata134k', 'rmg_rings_130_table'))

        os.remove(test_df_save_path)

    def test_save_results_in_database(self):

        # connect to database
        auth_info = utils.get_testing_RTD_authentication_info()
        rtdi = RMGTestsDatabaseInterface(*auth_info)
        rtd =  getattr(rtdi.client, 'rmg_tests')
        thermo_val_table = getattr(rtd, 'thermo_val_table')

        # prepare data
        meta_dict = {
            "rmgpy_branch": "pybranch",
            "rmgdb_branch": "dbbranch",
            "rmgpy_sha": "fadf232124jk3",
            "rmgdb_sha": "farelsdaem23m"

        }

        performance_dict = {
            ("db0", "table0"): 12
        }

        self.assertEqual(thermo_val_table.find(meta_dict).count(), 0)
        save_results_in_database(thermo_val_table, meta_dict, performance_dict)
        self.assertEqual(thermo_val_table.find(meta_dict).count(), 1)

        # remove test insertion from db
        thermo_val_table.delete_many(meta_dict)
        self.assertEqual(thermo_val_table.find(meta_dict).count(), 0)
