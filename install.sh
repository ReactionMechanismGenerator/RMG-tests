#!/bin/bash

set -e

# commit message of current head of RMG-tests = SHA1-ID of RMG-Py/database commit to be tested.
MESSAGE=$(git log --format=%B -n 1 HEAD)
echo "Message: "$MESSAGE

export BRANCH=$TRAVIS_BRANCH
echo "Branch: "$BRANCH

# version of RMG-Py/database to use when the SHA1 is of RMG-database/Py respectively:
RMG_VERSION="2.0.0"
DB_VERSION="2.0.0"

# create a folder with benchmark version of RMG-Py and RMG-database:
# go to parent-folder of the RMG-tests repo:
cd ..
# prepare benchmark RMG-Py and RMG-db
export benchmark=$PWD/code/benchmark
rm -rf $benchmark
mkdir -p $benchmark
cd $benchmark

# clone benchmark RMG-Py
git clone -b $RMG_VERSION --single-branch https://github.com/ReactionMechanismGenerator/RMG-Py.git

# check out the SHA-ID of the RMG-Py commit:
cd RMG-Py
conda env create -f environment_linux.yml # name will set by the name key in the environment yaml.
conda create --name benchmark --clone rmg_env
conda remove -n rmg_env --all -y
export RMG_BENCHMARK=`pwd`
echo "benchmark version of RMG: "$RMG_BENCHMARK

# compile RMG-Py:
source activate benchmark
make

cd ..

# clone benchmark RMG-database:
git clone -b $DB_VERSION --single-branch https://github.com/ReactionMechanismGenerator/RMG-database.git

# prepare testing RMG-Py and RMG-db
cd ..
export testing=$PWD/code/testing
rm -rf $testing
mkdir -p $testing
cd $testing

# split the message on the '-' delimiter
IFS='-' read -a pieces <<< "$MESSAGE"

# check if the first part of the splitted string is the "rmgdb" string:
if [ "${pieces[0]}" == "rmgdb" ]; then
  # pushed commit is of RMG-database
  # message is of form: "rmgdb-SHA1"

  # pushed commit is of RMG-database:
  SHA1=${pieces[1]}
  echo "SHA1: "$SHA1

  # check out the SHA-ID of the RMG-database commit:
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  cd RMG-database
  git checkout $SHA1

  # return to parent directory:
  cd ..

else
  # message is of form: "SHA1"

  # pushed commit is of RMG-Py:
  SHA1=${pieces[0]}
  echo "SHA1: "$SHA1

  # clone entire RMG-Py:
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

  # check out the SHA-ID of the RMG-Py commit:
  cd RMG-Py
  git checkout $SHA1
  conda env create -f environment_linux.yml # name will set by the name key in the environment yaml.
  conda create --name testing --clone rmg_env

  # set the RMG environment variable:
  export RMG_TESTING=`pwd`
  echo "test version of RMG: "$RMG_TESTING

  # compile RMG-Py:
  source activate testing
  make

  # return to parent directory:
  cd ..

fi

# go to RMG-tests folder:
cd $TRAVIS_BUILD_DIR
