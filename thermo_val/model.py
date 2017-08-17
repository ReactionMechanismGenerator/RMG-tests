import os

from rmgpy.species import Species

class ThermoEstimator(object):

    def __init__(self, kernel_type):

        self.kernel_type = kernel_type
        if kernel_type == 'GA':

            from rmgpy.data.thermo import ThermoDatabase
            from rmgpy import settings
            database = ThermoDatabase()
            database.load(os.path.join(settings['database.directory'], 'thermo'),libraries = [])

            self.kernel = database

        else:
            raise Exception('Kernel type {0} not supported yet.'.format(kernel_type))


    def predict_h298(self, smiles):

        if self.kernel_type == 'GA':
            spec = Species().fromSMILES(smiles)
            spec.generateResonanceIsomers()

            thermo = self.kernel.getThermoDataFromGroups(spec)
            H298 = thermo.H298.value_si/4184.0

            return H298

        else:
            raise Exception('Kernel type {0} not supported yet.'.format(self.kernel_type))