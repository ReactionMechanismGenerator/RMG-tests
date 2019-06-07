#!/bin/bash

test_case=$1
test_name=$(basename "$test_case")

set -e

if [ -z ${2+x} ]; then 
  echo "2nd argument not set. Exiting..."
  exit 1
fi

if [ -z ${3+x} ]; then 
  echo "3rd argument not set. Exiting..."
  exit 1
fi

benchmark_model=$2
testing_model=$3
echo 'Benchmark model folder: '$benchmark_model
echo 'Testing model folder: '$testing_model

# check generated models:
# core:
python $RMG_TESTING/scripts/checkModels.py $test_name $benchmark_model/chemkin/chem_annotated.inp $benchmark_model/chemkin/species_dictionary.txt $testing_model/chemkin/chem_annotated.inp $testing_model/chemkin/species_dictionary.txt

echo "Core for $test_case:"
if grep "checkModels" $test_name.log | cut -f2- -d'=' > $test_name.core ; then
  cat $test_name.core
  rm $test_name.core
fi

# edge:
python $RMG_TESTING/scripts/checkModels.py $test_name $benchmark_model/chemkin/chem_edge_annotated.inp $benchmark_model/chemkin/species_edge_dictionary.txt $testing_model/chemkin/chem_edge_annotated.inp $testing_model/chemkin/species_edge_dictionary.txt
echo "Edge for $test_case:"
if grep "checkModels" $test_name.log | cut -f2- -d'=' > $test_name.edge ; then
  cat $test_name.edge
  rm $test_name.edge
fi

echo 'Execution time, Benchmark:'
grep "Execution time" $benchmark_model/RMG.log | tail -1
echo 'Execution time, Tested:'
grep "Execution time" $testing_model/RMG.log | tail -1

echo 'Memory used, Benchmark:'
grep "Memory used:" $benchmark_model/RMG.log | tail -1
echo 'Memory used, Tested:'
grep "Memory used:" $testing_model/RMG.log | tail -1

# regression testing
regr=$BASE_DIR/tests/$test_case/regression_input.py
if [ -f "$regr" ];
then
  python $RMG_TESTING/rmgpy/tools/regression.py $regr $benchmark_model/chemkin $testing_model/chemkin/
else
  echo "Regression input file not found. Not running a regression test."
fi
