import os
import unittest

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
                                        'test_df_{0}_{1}_{2}.csv'.format('sdata134k', 'rmg_rings_130_table', "benchmark"))

		os.remove(test_df_save_path)

