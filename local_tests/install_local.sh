#!/bin/bash

set -e

# prepare benchmark RMG-Py and RMG-db
benchmark=$DATA_DIR/code/benchmark/$(date +%Y-%m-%d:%H:%M:%S)
rm -rf $benchmark
mkdir -p $benchmark
cd $benchmark

# prepare benchmark RMG-Py
git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

# create benchmark environment:
cd RMG-Py
export benchmark_py_sha=$(git rev-parse HEAD)

cd ..
# prepare benchmark RMG-database:
git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
cd RMG-database
export benchmark_db_sha=$(git rev-parse HEAD)

cd $DATA_DIR/code/benchmark
# rename benchmark code folder
benchmark_code=${benchmark_py_sha}_${benchmark_db_sha}
if [ ! -d "${benchmark_code}" ]; then
  	mv $benchmark ${benchmark_py_sha}_${benchmark_db_sha}
else
	rm -rf $benchmark
fi
export benchmark=$DATA_DIR/code/benchmark/${benchmark_py_sha}_${benchmark_db_sha}

cd $benchmark/RMG-Py

export benchmark_env='benchmark_env_'${benchmark_py_sha:0:8}'_'${benchmark_db_sha:0:8}
sed -i -e "s/rmg_env/${benchmark_env}/g" environment_${CURRENT_OS}.yml
conda env create -f environment_${CURRENT_OS}.yml # name will set by the name key in the environment yaml.
git checkout environment_${CURRENT_OS}.yml

# compile RMG-Py:
source activate ${benchmark_env}
make
source deactivate

export RMG_BENCHMARK=$benchmark/RMG-Py
export RMGDB_BENCHMARK=$benchmark/RMG-database

# prepare testing RMG-Py and RMG-db
testing=$DATA_DIR/code/testing/$(date +%Y-%m-%d:%H:%M:%S)
rm -rf $testing
mkdir -p $testing
cd $testing

# prepare testing RMG-Py:
git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

# checkout right RMG-Py branch:
cd RMG-Py

if [ $RMG_TESTING_BRANCH != "master" ]; then
  git checkout -b ${RMG_TESTING_BRANCH} origin/${RMG_TESTING_BRANCH}
fi
export testing_py_sha=$(git rev-parse HEAD)

# prepare testing RMG-database
cd ..
git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
cd RMG-database
# checkout right RMG-database branch:
if [ $RMGDB_TESTING_BRANCH != "master" ]; then
  git checkout -b ${RMGDB_TESTING_BRANCH} origin/${RMGDB_TESTING_BRANCH}
fi
export testing_db_sha=$(git rev-parse HEAD)

cd $DATA_DIR/code/testing

# rename testing code folder
testing_code=${testing_py_sha}_${testing_db_sha}
if [ ! -d "${testing_code}" ]; then
  	mv $testing ${testing_py_sha}_${testing_db_sha}
else
	rm -rf $testing
fi
export testing=$DATA_DIR/code/testing/${testing_py_sha}_${testing_db_sha}

cd $testing/RMG-Py
# create testing environment:
export testing_env='testing_env_'${testing_py_sha:0:8}'_'${testing_db_sha:0:8}
sed -i -e "s/rmg_env/${testing_env}/g" environment_${CURRENT_OS}.yml
conda env create -f environment_${CURRENT_OS}.yml
git checkout environment_${CURRENT_OS}.yml

# compile RMG-Py:
source activate ${testing_env}
make
source deactivate
export RMG_TESTING=$testing/RMG-Py
export RMGDB_TESTING=$testing/RMG-database

# go to RMG-tests folder:
cd $DATA_DIR
