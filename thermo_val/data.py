
from pymongo import MongoClient

def get_data(db_name, collection_name):

    # connect to db and query
    client = MongoClient('mongodb://user:user@rmg.mit.edu/admin', 27018)
    db =  getattr(client, db_name)
    collection = getattr(db, collection_name)
    db_cursor = collection.find()

    # collect data
    print('Reading data from {0}:{1}...'.format(db_name, collection_name))
    db_mols = []
    for db_mol in db_cursor:
        db_mols.append(db_mol)

    return db_mols

def get_datasets(dataset_file):

    test_tables = []
    with open(dataset_file, 'r') as f_in:
        for line in f_in:
            line = line.strip()
            if line and not line.startswith('#'):
                host, db, table = [token.strip() for token in line.split('.')]

                test_tables.append((host, db, table))

    return test_tables
