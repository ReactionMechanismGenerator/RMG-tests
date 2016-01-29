#!/bin/bash

target=$1

if [ -z ${TRAVIS_BUILD_DIR+x} ]; then TRAVIS_BUILD_DIR=$PWD; fi

echo 'Travis Build Dir: '$TRAVIS_BUILD_DIR


ORIGINAL=$TRAVIS_BUILD_DIR/testing/check/$target

SOURCE_FOLDER=$TRAVIS_BUILD_DIR/testing/$target

echo 'Source folder: '$SOURCE_FOLDER

# check generated models:
# core:
python $TRAVIS_BUILD_DIR/checkModels.py $target $SOURCE_FOLDER/chemkin/chem_annotated.inp $SOURCE_FOLDER/chemkin/species_dictionary.txt
grep "checkModels" $target.log > $target.core
echo core for $target:
cat $target.core

# edge:
python $TRAVIS_BUILD_DIR/checkModels.py $target $SOURCE_FOLDER/chemkin/chem_edge_annotated.inp $SOURCE_FOLDER/chemkin/species_edge_dictionary.txt
grep "checkModels" $target.log > $target.edge
echo edge for $target:
cat $target.edge

echo 'Execution time, Tested:'
grep "Execution time" $TRAVIS_BUILD_DIR/testing/$target/RMG.log | tail -1
echo 'Execution time, Original:'
grep "Execution time" $ORIGINAL/RMG.log | tail -1

echo 'Memory used, Tested:'
grep "Memory used" $TRAVIS_BUILD_DIR/testing/$target/RMG.log | tail -1
echo 'Memory used, Original:'
grep "Memory used" $ORIGINAL/RMG.log | tail -1
