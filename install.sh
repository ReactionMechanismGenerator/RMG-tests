#!/bin/bash

set -e

# create a folder with benchmark version of RMG-Py and RMG-database:
# go to parent-folder of the RMG-tests repo:
cd ..
# prepare benchmark RMG-Py and RMG-db
export benchmark=$BASE_DIR/code/benchmark
rm -rf $benchmark
mkdir -p $benchmark
cd $benchmark

# clone benchmark RMG-Py
git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

# check out the SHA-ID of the RMG-Py commit:
cd RMG-Py
sed -i -e 's/rmg_env/benchmark/g' environment_${CURRENT_OS}.yml
conda env create -q -f environment_${CURRENT_OS}.yml # name will set by the name key in the environment yaml.
git checkout environment_${CURRENT_OS}.yml

export RMG_BENCHMARK=`pwd`

# compile RMG-Py:
source activate benchmark
make
source deactivate

cd ..

# clone benchmark RMG-database:
git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
cd RMG-database
export RMGDB_BENCHMARK=`pwd`

cd ..

# prepare testing RMG-Py and RMG-db
export testing=$BASE_DIR/code/testing
rm -rf $testing
mkdir -p $testing
cd $testing

if [ $RMG_TESTING_BRANCH == "master" ]; then
  # set the RMG environment variable:
  export RMG_TESTING=$RMG_BENCHMARK

  conda create --name testing --clone benchmark

  # check out the SHA-ID of the RMG-database commit:
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  cd RMG-database
  if [ $RMGDB_TESTING_BRANCH != "master" ]; then
    git checkout -b ${RMGDB_TESTING_BRANCH} origin/${RMGDB_TESTING_BRANCH}
  fi
  export RMGDB_TESTING=`pwd`
  cd ..

elif [ $RMGDB_TESTING_BRANCH == "master" ]; then
  # clone entire RMG-Py:
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

  # check out the SHA-ID of the RMG-Py commit:
  cd RMG-Py
  git checkout -b ${RMG_TESTING_BRANCH} origin/${RMG_TESTING_BRANCH}
  sed -i -e 's/rmg_env/testing/g' environment_${CURRENT_OS}.yml
  conda env create -q -f environment_${CURRENT_OS}.yml

  git checkout environment_${CURRENT_OS}.yml
  export RMG_TESTING=`pwd`

  # compile RMG-Py:
  source activate testing
  make
  source deactivate

  # return to parent directory:
  cd ..
  export RMGDB_TESTING=$RMGDB_BENCHMARK

else
  # clone entire RMG-Py:
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

  # check out the SHA-ID of the RMG-Py commit:
  cd RMG-Py
  git checkout -b ${RMG_TESTING_BRANCH} origin/${RMG_TESTING_BRANCH}
  sed -i -e 's/rmg_env/testing/g' environment_${CURRENT_OS}.yml
  conda env create -q -f environment_${CURRENT_OS}.yml

  git checkout environment_${CURRENT_OS}.yml
  export RMG_TESTING=`pwd`


  # check out right RMG-database
  cd ..
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  cd RMG-database
  git checkout -b ${RMGDB_TESTING_BRANCH} origin/${RMGDB_TESTING_BRANCH}
  export RMGDB_TESTING=`pwd`

  # go to RMG-Py
  cd ../RMG-Py

  # compile RMG-Py:
  source activate testing
  make
  source deactivate

fi

# go to RMG-tests folder:
cd $BASE_DIR
