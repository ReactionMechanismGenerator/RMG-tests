#!/bin/bash

# Exit immediately on failure
set -e

###################
# BENCHMARK SETUP #
###################

# Prepare temporary directory for benchmark RMG-Py and RMG-db
benchmark=$DATA_DIR/code/benchmark/$(date +%Y-%m-%d:%H:%M:%S)
rm -rf $benchmark
mkdir -p $benchmark
cd $benchmark

# Prepare benchmark RMG-Py
git clone -q https://github.com/ReactionMechanismGenerator/RMG-Py.git
cd RMG-Py
git checkout $RMGPY_BENCHMARK_BRANCH
export benchmark_py_sha=$(git rev-parse HEAD)
cd ..

# Prepare benchmark RMG-database:
git clone -q https://github.com/ReactionMechanismGenerator/RMG-database.git
cd RMG-database
git checkout $RMGDB_BENCHMARK_BRANCH
export benchmark_db_sha=$(git rev-parse HEAD)

# Rename benchmark code folder
cd $DATA_DIR/code/benchmark

export benchmark_tag=py${benchmark_py_sha:0:12}_db${benchmark_db_sha:0:12}

if [ ! -d "${benchmark_tag}" ]; then
    mv $benchmark $benchmark_tag
else
    rm -rf $benchmark
fi

export benchmark=$DATA_DIR/code/benchmark/$benchmark_tag

# Prepare benchmark environment if requested
if [ "$CLEAN_ENV" == true ]; then
    cd $benchmark/RMG-Py
    export benchmark_env="benchmark_env"
    conda remove --name $benchmark_env --all -y 
    conda env create -n $benchmark_env -f environment_${CURRENT_OS}.yml 
else
    export benchmark_env="rmg_env"
fi

# Compile benchmark RMG-Py:
cd $benchmark/RMG-Py
source activate $benchmark_env
make
source deactivate

export RMG_BENCHMARK=$benchmark/RMG-Py
export RMGDB_BENCHMARK=$benchmark/RMG-database

#################
# TESTING SETUP #
#################

# Prepare temporary directory for testing RMG-Py and RMG-db
testing=$DATA_DIR/code/testing/$(date +%Y-%m-%d:%H:%M:%S)
rm -rf $testing
mkdir -p $testing
cd $testing

# Prepare testing RMG-Py:
git clone -q https://github.com/ReactionMechanismGenerator/RMG-Py.git
cd RMG-Py
git checkout ${RMGPY_TESTING_BRANCH}
export testing_py_sha=$(git rev-parse HEAD)
cd ..

# Prepare testing RMG-database
git clone -q https://github.com/ReactionMechanismGenerator/RMG-database.git
cd RMG-database
git checkout ${RMGDB_TESTING_BRANCH}
export testing_db_sha=$(git rev-parse HEAD)

# Rename testing code folder
cd $DATA_DIR/code/testing

export testing_tag=py${testing_py_sha:0:12}_db${testing_db_sha:0:12}

if [ ! -d "${testing_tag}" ]; then
    mv $testing $testing_tag
else
    rm -rf $testing
fi
export testing=$DATA_DIR/code/testing/$testing_tag

# Prepare testing environment if requested
if [ "$SEPARATE_ENV" == true]; then
    cd $testing/RMG-Py
    export testing_env="testing_env"
    conda remove --name $testing_env --all -y 
    conda env create -n $testing_env -f environment_${CURRENT_OS}.yml
else
    export testing_env=$benchmark_env
fi

# Compile RMG-Py:
cd $testing/RMG-Py
source activate $testing_env
make
source deactivate

export RMG_TESTING=$testing/RMG-Py
export RMGDB_TESTING=$testing/RMG-database

# Go to RMG-tests folder:
cd $DATA_DIR

