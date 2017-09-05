import os

from rmgpy.species import Species

class ThermoEstimator(object):

    def __init__(self, kernel_type):

        self.kernel_type = kernel_type
        if kernel_type == 'GA':

            from rmgpy.data.thermo import ThermoDatabase
            from rmgpy import settings
            database = ThermoDatabase()
            print('GA Database directory:\n{0}'.format(settings['database.directory']))
            database.load(os.path.join(settings['database.directory'], 'thermo'),libraries = [])

            self.kernel = database

        else:
            raise Exception('Kernel type {0} not supported yet.'.format(kernel_type))


    def predict_thermo(self, smiles):

        if self.kernel_type == 'GA':
            spec = Species().fromSMILES(smiles)
            spec.generateResonanceIsomers()

            thermo = self.kernel.getThermoDataFromGroups(spec)

            return thermo

        else:
            raise Exception('Kernel type {0} not supported yet.'.format(self.kernel_type))