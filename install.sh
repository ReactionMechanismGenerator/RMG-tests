#!/bin/bash

set -e

# create a folder with benchmark version of RMG-Py and RMG-database:
# go to parent-folder of the RMG-tests repo:
cd ..
# prepare benchmark RMG-Py and RMG-db
export benchmark=$BASE_DIR/code/benchmark
mkdir -p $benchmark
cd $benchmark

# clone benchmark RMG-Py
if [ ! -d "RMG-Py" ]; then
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git
fi

cd RMG-Py
conda env create -n benchmark -f environment_${CURRENT_OS}.yml

export RMG_BENCHMARK=`pwd`

cd ..

# clone benchmark RMG-database:
if [ ! -d "RMG-database" ]; then
git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
fi

cd RMG-database
export RMGDB_BENCHMARK=`pwd`

cd ..

# prepare testing RMG-Py and RMG-db
export testing=$BASE_DIR/code/testing
mkdir -p $testing
cd $testing

if [ $RMG_TESTING_BRANCH == "master" ]; then
  # set the RMG directory variable
  export RMG_TESTING=$RMG_BENCHMARK
  # copy the conda environment
  conda create --name testing --clone benchmark

else
  # clone entire RMG-Py
  if [ ! -d "RMG-Py" ]; then
    git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git
  fi
  # check out the SHA-ID of the RMG-Py commit
  cd RMG-Py
  git checkout ${RMG_TESTING_BRANCH}
  conda env create -n testing -f environment_${CURRENT_OS}.yml

  export RMG_TESTING=`pwd`

  cd ..
fi

if [ $RMGDB_TESTING_BRANCH == "master" ]; then
  # set the RMG database directory
  export RMGDB_TESTING=$RMGDB_BENCHMARK

else
  # clone RMG-database
  if [ ! -d "RMG-database" ]; then
    git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  fi
  # check out the SHA-ID of the RMG-database commit
  cd RMG-database
  git checkout ${RMGDB_TESTING_BRANCH}

  export RMGDB_TESTING=`pwd`

  cd ..

fi

# go to RMG-tests folder
cd $BASE_DIR
