#!/bin/bash
set -o verbose  # echo commands before executing.
# create a folder with benchmark version of RMG-Py and RMG-database:
# go to parent-folder of the RMG-tests repo:
cd ..
# prepare benchmark RMG-Py and RMG-db


echo "base dir: "
echo "${BASE_DIR}"

echo "GITHUB_WORKSPACE: "
echo "${GITHUB_WORKSPACE}"
echo "$GITHUB_WORKSPACE"

export benchmark=$BASE_DIR/code/benchmark
echo "benchmark dir :"$benchmark
mkdir -p $benchmark
cd $benchmark


# clone benchmark RMG-Py
if [ ! -d "RMG-Py" ]; then
  # the directory was not cached, so clone it
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git
  cd RMG-Py
else
  # the directory was cached, make sure that it's up to date
  cd RMG-Py
  git pull --ff-only origin main
fi

travis_wait conda env create -q -n benchmark -f environment.yml
conda list -n benchmark

export RMG_BENCHMARK=`pwd`
cd ..

# clone benchmark RMG-database:
if [ ! -d "RMG-database" ]; then
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  cd RMG-database
else
  cd RMG-database
  git pull --ff-only origin main
fi

export RMGDB_BENCHMARK=`pwd`
cd ..

# prepare testing RMG-Py and RMG-db
export testing=$BASE_DIR/code/testing
mkdir -p $testing
cd $testing

if [ $RMG_TESTING_BRANCH == "main" ]; then
  # set the RMG directory variable
  export RMG_TESTING=$RMG_BENCHMARK
  # copy the conda environment
  conda create --name testing --clone benchmark

else
  # clone entire RMG-Py
  if [ ! -d "RMG-Py" ]; then
    git clone -b ${RMG_TESTING_BRANCH} https://github.com/ReactionMechanismGenerator/RMG-Py.git
    cd RMG-Py
  else
    cd RMG-Py
    git fetch origin ${RMG_TESTING_BRANCH}
    git checkout ${RMG_TESTING_BRANCH}
    git reset --hard origin/${RMG_TESTING_BRANCH}
  fi

  travis_wait conda env create -q -n testing -f environment.yml

  export RMG_TESTING=`pwd`
  cd ..
fi

if [ $RMGDB_TESTING_BRANCH == "main" ]; then
  # set the RMG database directory
  export RMGDB_TESTING=$RMGDB_BENCHMARK

else
  # clone RMG-database
  if [ ! -d "RMG-database" ]; then
    git clone -b ${RMGDB_TESTING_BRANCH} https://github.com/ReactionMechanismGenerator/RMG-database.git
    cd RMG-database
  else
    cd RMG-database
    git fetch origin ${RMGDB_TESTING_BRANCH}
    git checkout ${RMGDB_TESTING_BRANCH}
    git reset --hard origin/${RMGDB_TESTING_BRANCH}
  fi

  export RMGDB_TESTING=`pwd`
  cd ..
fi

# setup MOPAC for both environments
conda activate benchmark
yes 'Yes' | $HOME/miniconda/envs/benchmark/bin/mopac $MOPACKEY > /dev/null
conda deactivate

conda activate testing
yes 'Yes' | $HOME/miniconda/envs/testing/bin/mopac $MOPACKEY > /dev/null
conda deactivate

# go to RMG-tests folder
cd $BASE_DIR
