import unittest

from model import *

class TestThermoEstimator(unittest.TestCase):

    @classmethod
    def setUpClass(self):
        """A function that is run ONCE before all unit tests in this class."""
        self.model_ga = ThermoEstimator(kernel_type='GA')

    def testGroupAdditivityModelInstantiation(self):

        self.assertTrue(self.model_ga is not None)

    def testUnsupportedModelInstantiation(self):

        with self.assertRaises(Exception):
            model = ThermoEstimator(kernel_type='Not-supported')


    def test_predict_h298_using_ga_model(self):

        smiles = 'CC'
        H298_pred = self.model_ga.predict_h298(smiles)
        H298_expected = -20.40

        self.assertAlmostEqual(H298_pred, H298_expected, 2)

        

