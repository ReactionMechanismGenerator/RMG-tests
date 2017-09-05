import os
import time
import argparse
import pandas as pd

from model import ThermoEstimator
from data import get_datasets, get_data
from utils import get_RTD_authentication_info
from connector import RMGTestsDatabaseInterface

def evaluate_performance(dataset_file, 
                        model_kernel='GA'):
    
    # get a list of test table names
    # from files or input
    test_tables = get_datasets(dataset_file)

    # model instantiation
    model = ThermoEstimator(kernel_type=model_kernel)

    # start test evaluation
    performance_dict = {}
    for _, db_name, collection_name in test_tables:

        data = get_data(db_name, collection_name)

        spec_labels = []
        spec_dict = {}
        H298s_true = []
        H298s_pred = []

        comments = []
        
        for db_mol in data:
            smiles_in = str(db_mol["SMILES_input"])
            H298_true = float(db_mol["Hf298(kcal/mol)"]) # unit: kcal/mol
            
            thermo = model.predict_thermo(smiles_in)
            H298_pred = thermo.H298.value_si/4184.0
            
            spec_labels.append(smiles_in)
            H298s_true.append(H298_true)
            H298s_pred.append(H298_pred)
            comments.append(thermo.comment)

        # create pandas dataframe
        test_df = pd.DataFrame(index=spec_labels)
        test_df['SMILES'] = test_df.index

        test_df['H298_pred(kcal/mol)'] = pd.Series(H298s_pred, index=test_df.index)
        test_df['H298_true(kcal/mol)'] = pd.Series(H298s_true, index=test_df.index)

        diff = abs(test_df['H298_pred(kcal/mol)']-test_df['H298_true(kcal/mol)'])
        test_df['H298_diff(kcal/mol)'] = pd.Series(diff, index=test_df.index)
        test_df['Comments'] = pd.Series(comments, index=test_df.index)

        # save test_df for future reference and possible comparison
        test_df_save_path = os.path.join(os.path.dirname(dataset_file),
                                        'test_df_{0}_{1}.csv'.format(db_name, collection_name))
        with open(test_df_save_path, 'w') as fout:
            test_df.to_csv(fout, index=False)

        performance_dict[(db_name, collection_name)] = test_df['H298_diff(kcal/mol)'].describe()['mean']

    return performance_dict

def parseCommandLineArguments():
   
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-d', '--datasets', metavar='FILE', type=str, 
        nargs='+', help='a file specifies on which datasets to test')

    parser.add_argument('-pb', '--rmgpy_branch', type=str, 
        help='rmgpy branch name')

    parser.add_argument('-dbb', '--rmgdb_branch', type=str, 
        help='rmgdb branch name')

    parser.add_argument('-psha', '--rmgpy_sha', type=str, 
        help='rmgpy last commit sha')

    parser.add_argument('-dbsha', '--rmgdb_sha', type=str, 
        help='rmgdb last commit sha')

    return parser.parse_args()

def save_results_in_file(performance_dict, save_path):

    print_str = "\nValidation Test Results"
    for db_name, collection_name in performance_dict:

        performance = performance_dict[(db_name, collection_name)]

        print_str += "\n========================="
        print_str += "\nDatabase: {0}".format(db_name)
        print_str += "\nDataset: {0}".format(collection_name)
        print_str += "\nPerformance (MAE): {0:0.2f} kcal/mol".format(performance)

    print(print_str)
    with open(save_path, 'w') as fout:
            fout.write(print_str)

def save_results_in_database(table, meta_dict, performance_dict):

    if table.find(meta_dict).count() == 0:
        # prepare insert_entry and push to database
        insert_entry = {"rmgpy_branch": meta_dict["rmgpy_branch"],
                        "rmgdb_branch": meta_dict["rmgdb_branch"],
                        "rmgpy_sha": meta_dict["rmgpy_sha"],
                        "rmgdb_sha": meta_dict["rmgdb_sha"],
                        "timestamp" : time.time()}
    else:
        insert_entry = list(table.find(meta_dict))[0]
    

    for tup, value in performance_dict.iteritems():
        db_name, collection_name = tup
        key = db_name + ":" + collection_name
        insert_entry[key] = value

    table.update(meta_dict, {'$set':insert_entry}, upsert=True)

def need_evaluate_performance(thermo_val_table, meta_dict, test_tables):

    # check if database has this record
    if thermo_val_table.find(meta_dict).count() == 0:
       return True
    else:
        registered_entry = list(thermo_val_table.find(meta_dict))[0]

        for _, db_name, collection_name in test_tables:
            if db_name + ':' + collection_name not in registered_entry:
                return True

        return False


def main():

    args = parseCommandLineArguments()
    
    rmgpy_branch = args.rmgpy_branch
    rmgdb_branch = args.rmgdb_branch
    rmgpy_sha = args.rmgpy_sha
    rmgdb_sha = args.rmgdb_sha
    meta_dict = {
        "rmgpy_branch": rmgpy_branch,
        "rmgdb_branch": rmgdb_branch,
        "rmgpy_sha": rmgpy_sha,
        "rmgdb_sha": rmgdb_sha

    }

    dataset_file = args.datasets[0]
    test_tables = get_datasets(dataset_file)

    # connect to database
    auth_info = get_RTD_authentication_info()
    rtdi = RMGTestsDatabaseInterface(*auth_info)
    rtd =  getattr(rtdi.client, 'rmg_tests')
    thermo_val_table = getattr(rtd, 'thermo_val_table')

    # check if database has this record
    need_evaluation = need_evaluate_performance(thermo_val_table, meta_dict, test_tables)
    if need_evaluation:
        performance_dict = evaluate_performance(dataset_file, 
                                            model_kernel='GA')
        # push to database
        save_results_in_database(thermo_val_table, meta_dict, performance_dict)
    else:
        registered_entry = list(thermo_val_table.find(meta_dict))[0]

        performance_dict = {}
        for _, db_name, collection_name in test_tables:
            key = db_name + ':' + collection_name
            performance_dict[(db_name, collection_name)] = registered_entry[key]

    # save to txt file
    validataion_summary_path = os.path.join(os.path.dirname(dataset_file),
                                    'validation_summary.txt')
    save_results_in_file(performance_dict, validataion_summary_path)

if __name__ == '__main__':
    main()
