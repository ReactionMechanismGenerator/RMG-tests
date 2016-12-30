#!/bin/bash

set -e

# commit message of current head of RMG-tests = SHA1-ID of RMG-Py/database commit to be tested.
MESSAGE=$(git log --format=%B -n 1 HEAD)
echo "Message: "$MESSAGE

export BRANCH=$TRAVIS_BRANCH
echo "Branch: "$BRANCH

# create a folder with benchmark version of RMG-Py and RMG-database:
# go to parent-folder of the RMG-tests repo:
cd ..
# prepare benchmark RMG-Py and RMG-db
export benchmark=$PWD/code/benchmark
rm -rf $benchmark
mkdir -p $benchmark
cd $benchmark

# clone benchmark RMG-Py
git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

# check out the SHA-ID of the RMG-Py commit:
cd RMG-Py
sed -i -e 's/rmg_env/benchmark/g' environment_linux.yml
conda env create -f environment_linux.yml # name will set by the name key in the environment yaml.
git checkout environment_linux.yml

export RMG_BENCHMARK=`pwd`

# to show benchmark MG-Py HEAD
echo ""
echo "benchmark version of RMG: "$RMG_BENCHMARK
git log --format=%H%n%cd -1
echo ""

# compile RMG-Py:
source activate benchmark
make
source deactivate

cd ..

# clone benchmark RMG-database:
git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
cd RMG-database
export RMGDB_BENCHMARK=`pwd`

# to show benchmark RMG-database HEAD
echo ""
echo "benchmark version of RMG-database: "$RMGDB_BENCHMARK
git log --format=%H%n%cd -1
echo ""
cd ..

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

  # set the RMG environment variable:
  export RMG_TESTING=$RMG_BENCHMARK

  # to show testing RMG-Py HEAD
  echo ""
  echo "testing version of RMG: "$RMG_TESTING
  cd $RMG_TESTING
  git log --format=%H%n%cd -1
  cd -
  echo ""
  conda create --name testing --clone benchmark

  # check out the SHA-ID of the RMG-database commit:
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  cd RMG-database
  git checkout $SHA1
  export RMGDB_TESTING=`pwd`

  # to show testing RMG-database HEAD
  echo ""
  echo "testing version of RMG-database: "$RMGDB_TESTING
  cd $RMG_TESTING
  git log --format=%H%n%cd -1
  cd -
  echo ""
  # return to parent directory:
  cd ..

elif [ "${pieces[0]}" == "rmgpy" ]; then
  # message is of form: "SHA1"

  # pushed commit is of RMG-Py:
  SHA1=${pieces[1]}
  echo "SHA1: "$SHA1

  # clone entire RMG-Py:
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

  # check out the SHA-ID of the RMG-Py commit:
  cd RMG-Py
  git checkout $SHA1
  sed -i -e 's/rmg_env/testing/g' environment_linux.yml
  conda env create -f environment_linux.yml # name will set by the name key in the environment yaml.

  git checkout environment_linux.yml

  # set the RMG environment variable:
  echo ""
  export RMG_TESTING=`pwd`
  echo "testing version of RMG: "$RMG_TESTING
  git log --format=%H%n%cd -1
  echo ""

  # compile RMG-Py:
  source activate testing
  make
  source deactivate

  # return to parent directory:
  cd ..

  echo ""
  export RMGDB_TESTING=$RMGDB_BENCHMARK
  echo "testing version of RMG-database: "$RMGDB_TESTING
  cd $RMGDB_TESTING
  git log --format=%H%n%cd -1
  cd -
  echo ""

elif [ "${pieces[0]}" == "rmgpydb" ]; then
  # message is of form: "SHA1"

  # pushed commit is of RMG-Py:
  SHA1=${pieces[1]}
  echo "SHA1: "$SHA1

  DB_branch=${pieces[2]}
  echo "DB_branch: "${DB_branch}

  # clone entire RMG-Py:
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

  # check out the SHA-ID of the RMG-Py commit:
  cd RMG-Py
  git checkout $SHA1
  sed -i -e 's/rmg_env/testing/g' environment_linux.yml
  conda env create -f environment_linux.yml # name will set by the name key in the environment yaml.

  git checkout environment_linux.yml
  export RMG_TESTING=`pwd`

  # Show the RMG testing version:
  echo ""
  echo "testing version of RMG: "$RMG_TESTING
  git log --format=%H%n%cd -1
  echo ""

  # check out right RMG-database
  cd ..
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  cd RMG-database
  git checkout -b ${DB_branch} origin/${DB_branch}
  export RMGDB_TESTING=`pwd`
  
  # Show the RMG database testing version:
  echo ""
  echo "testing version of RMG database: "$RMGDB_TESTING
  git log --format=%H%n%cd -1
  echo ""

  # go to RMG-Py
  cd ../RMG-Py

  # compile RMG-Py:
  source activate testing
  make
  source deactivate

fi

# go to RMG-tests folder:
cd $TRAVIS_BUILD_DIR
