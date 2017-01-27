#!/bin/bash

target=$1

if [ -z ${2+x} ]; then 
	echo "2nd argument not set. Exiting..."
	exit 1
fi

if [ -z ${3+x} ]; then 
	echo "3rd argument not set. Exiting..."
	exit 1
fi

if [ -z ${TRAVIS_BUILD_DIR+x} ]; then TRAVIS_BUILD_DIR=$PWD; fi

echo 'Travis Build Dir: '$TRAVIS_BUILD_DIR

benchmarkmodel=$2
testmodel=$3
echo 'benchmark model folder: '$benchmarkmodel
echo 'Test model folder: '$testmodel

# check generated models:
# core:
python $RMG_BENCHMARK/scripts/checkModels.py $target $benchmarkmodel/chemkin/chem_annotated.inp $benchmarkmodel/chemkin/species_dictionary.txt $testmodel/chemkin/chem_annotated.inp $testmodel/chemkin/species_dictionary.txt

echo core for $target:
if grep "checkModels" $target.log | cut -f2- -d'=' > $target.core ; then
	cat $target.core
	rm $target.core
fi

# edge:
python $RMG_BENCHMARK/scripts/checkModels.py $target $benchmarkmodel/chemkin/chem_edge_annotated.inp $benchmarkmodel/chemkin/species_edge_dictionary.txt $testmodel/chemkin/chem_edge_annotated.inp $testmodel/chemkin/species_edge_dictionary.txt
echo edge for $target:
if grep "checkModels" $target.log | cut -f2- -d'=' > $target.edge ; then
	cat $target.edge
	rm $target.edge
fi

echo 'Execution time, Benchmark:'
grep "Execution time" $benchmarkmodel/RMG.log | tail -1
echo 'Execution time, Tested:'
grep "Execution time" $testmodel/RMG.log | tail -1

echo 'Memory used, Benchmark:'
grep "Memory used:" $benchmarkmodel/RMG.log | tail -1
echo 'Memory used, Tested:'
grep "Memory used:" $testmodel/RMG.log | tail -1

# regression testing
regr=$BASE_DIR/../examples/rmg/$target/regression_input.py
if [ -f "$regr" ];
then
	python $RMG_BENCHMARK/rmgpy/tools/regression.py $regr $benchmarkmodel/chemkin $testmodel/chemkin/
else
	echo "Regression input file not found. Not running a regression test."
fi