import os
import unittest

from data import *

class TestData(unittest.TestCase):

	def test_get_datasets(self):

		dataset_file = os.path.join(os.path.dirname(__file__), 
									'test_data',
									'dataset.txt')
		test_tables = get_datasets(dataset_file)

		self.assertEqual(len(test_tables), 1)
		self.assertEqual(test_tables[0][0], 'rmg')
		self.assertEqual(test_tables[0][1], 'sdata134k')
		self.assertEqual(test_tables[0][2], 'rmg_rings_130_table')

	def test_get_data(self):

		db_name = 'sdata134k'
		collection_name = 'small_cyclic_table'
		data = get_data(db_name, collection_name)

		self.assertEqual(len(data), 2903)