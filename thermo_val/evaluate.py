import pandas as pd

from data import get_datasets, get_data
from model import ThermoEstimator

def evaluate_performance(dataset_file, model_kernel='GA'):
    
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
        
        for db_mol in data:
            smiles_in = str(db_mol["SMILES_input"])
            spec_labels.append(smiles_in)
            
            H298_true = float(db_mol["Hf298(kcal/mol)"]) # unit: kcal/mol
            H298s_true.append(H298_true)
            
            H298_pred = model.predict_h298(smiles_in)
            H298s_pred.append(H298_pred)

        # create pandas dataframe
        test_df = pd.DataFrame(index=spec_labels)

        test_df['H298_pred(kcal/mol)'] = pd.Series(H298s_pred, index=test_df.index)
        test_df['H298_true(kcal/mol)'] = pd.Series(H298s_true, index=test_df.index)

        diff = abs(test_df['H298_pred(kcal/mol)']-test_df['H298_true(kcal/mol)'])
        test_df['H298_diff(kcal/mol)'] = pd.Series(diff, index=test_df.index)

        performance_dict[(db_name, collection_name)] = test_df['H298_diff(kcal/mol)'].describe()['mean']

    return performance_dict

def parseCommandLineArguments():
   
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-d', '--datasets', metavar='FILE', type=str, 
        nargs='+', help='a file specifies on which datasets to test')

    return parser.parse_args()


def main():

    args = parseCommandLineArguments()
    dataset_file = args.datasets[0]
    performance_dict = evaluate_performance(dataset_file, model_kernel='GA')

    print "\nValidation Test Results"
    for db_name, collection_name in performance_dict:

        performance = performance_dict[(db_name, collection_name)]

        print "========================="
        print "Database: {0}".format(db_name)
        print "Dataset: {0}".format(collection_name)
        print "Performance (MAE): {0:0.2f} kcal/mol".format(performance)

if __name__ == '__main__':
    main()
