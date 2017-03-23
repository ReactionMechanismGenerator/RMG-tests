from rmgpy.data.rmg import RMGDatabase
from rmgpy import settings
from rmgpy.species import Species
import os
import pandas as pd
from pymongo import MongoClient
import logging


def get_data(host, db_name, collection_name, port=27017):
    # connect to db and query
    client = MongoClient(host, port)
    db =  getattr(client, db_name)
    collection = getattr(db, collection_name)
    db_cursor = collection.find()

    # collect data
    print('reading data...')
    db_mols = []
    for db_mol in db_cursor:
        db_mols.append(db_mol)
    print('done')

    return db_mols

database = RMGDatabase()
database.load(settings['database.directory'], thermoLibraries=[],\
             kineticsFamilies='none', kineticsDepositories='none', reactionLibraries = [])

thermoDatabase = database.thermo

# fetch testing dataset
db_name = 'sdata134k'
collection_name = 'small_polycyclic_table'
host = 'mongodb://user:user@rmg.mit.edu/admin'
port = 27018
db_mols = get_data(host, db_name, collection_name, port)
len(db_mols)

test_size = 0
validation_test_dict = {} # key: spec.label, value: (thermo_heuristic, thermo_qm)

spec_labels = []
spec_dict = {}
H298s_qm = []
H298s_gav = []
for db_mol in db_mols:
    smiles_out = str(db_mol["SMILES_output"])
    smiles_in = str(db_mol["SMILES_input"])
    
    spec_out = Species().fromSMILES(smiles_out)
    spec_out.generateResonanceIsomers()
    spec_in = Species().fromSMILES(smiles_in)
    spec_in.generateResonanceIsomers()
    if not spec_out.isIsomorphic(spec_in):
        continue
    spec_labels.append(smiles_in)
    
    H298_qm = float(db_mol["Hf298"]) # unit: kcal/mol
    H298s_qm.append(H298_qm)
    
    thermo_gav = thermoDatabase.getThermoDataFromGroups(spec_in)
    H298_gav = thermo_gav.H298.value_si/4184.0
    H298s_gav.append(H298_gav)
    
    spec_dict[smiles_in] = spec_in

# create pandas dataframe
validation_test_df = pd.DataFrame(index=spec_labels)

validation_test_df['H298_heuristic(kcal/mol)'] = pd.Series(H298s_gav, index=validation_test_df.index)
validation_test_df['H298_qm(kcal/mol)'] = pd.Series(H298s_qm, index=validation_test_df.index)

heuristic_qm_diff = abs(validation_test_df['H298_heuristic(kcal/mol)']-validation_test_df['H298_qm(kcal/mol)'])
validation_test_df['H298_heuristic_qm_diff(kcal/mol)'] = pd.Series(heuristic_qm_diff, index=validation_test_df.index)

print "Validation test dataframe has {0} tricyclics.".format(len(spec_labels))

print validation_test_df['H298_heuristic_qm_diff(kcal/mol)'].describe()