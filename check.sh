#!/bin/bash

echo 'Travis Build Dir: '$TRAVIS_BUILD_DIR

# Types of models to save
eg1=minimal
# eg2, etc...

SOURCE_FOLDER=$TRAVIS_BUILD_DIR/testing/$eg1/chemkin/

echo 'Source folder: '$SOURCE_FOLDER

# check generated models:
python $TRAVIS_BUILD_DIR/checkModels.py $SOURCE_FOLDER/chem_annotated.inp $SOURCE_FOLDER/species_dictionary.txt