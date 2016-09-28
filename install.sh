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
tested=$PWD/code/tested
rm -rf $tested
mkdir -p $tested
cd $tested

# create anaconda environment with benchmark versions of RMG-Py and RMG-database:
conda env remove --name benchmark -y
conda create -c rmg --name benchmark rmg=$RMG_VERSION rmgdatabase=$DB_VERSION -y

# split the message on the '-' delimiter
IFS='-' read -a pieces <<< "$MESSAGE"

# check if the first part of the splitted string is the "rmgdb" string:
if [ "${pieces[0]}" == "rmgdb" ]; then
  # pushed commit is of RMG-database
  # message is of form: "rmgdb-SHA1"

  # pushed commit is of RMG-database:
  SHA1=${pieces[1]}
  echo "SHA1: "$SHA1
  
  # clone the benchmark environment and call it "tested":
  conda env remove --name tested -y
  conda create --name tested --clone benchmark

  # clone entire RMG-database:
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git

  # check out the SHA-ID of the RMG-database commit:
  cd RMG-database
  git checkout $SHA1

  # use the rmgrc file to point to the location of the tested RMG-database:
  rmgrc="database.directory : "$tested/RMG-database/input/
  mkdir -p $HOME/.rmg
  echo $rmgrc >> $HOME/.rmg/rmgrc

  # set the RMG environment variable to the path with the rmg.py binary:
  source activate benchmark
  export RMG=$CONDA_ENV_PATH/bin
  echo "RMG: "$RMG

  # return to parent directory:
  cd ..

else
  # message is of form: "SHA1"

  # pushed commit is of RMG-Py:
  SHA1=${pieces[0]}
  echo "SHA1: "$SHA1

  # use $DB_VERSION of RMG-database:
  git clone -b $DB_VERSION --single-branch https://github.com/ReactionMechanismGenerator/RMG-database.git

  # clone entire RMG-Py:
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

  # check out the SHA-ID of the RMG-Py commit:
  cd RMG-Py
  git checkout $SHA1
  conda env remove --name tested -y
  conda env create -f environment_linux.yml # name will set by the name key in the environment yaml.
  conda create --name tested --clone rmg_env

  # set the RMG environment variable and add RMG-Py path to $PYTHONPATH:
  export RMG=`pwd`
  echo "test version of RMG: "$RMG

  # compile RMG-Py:
  source activate tested
  PYTHONPATH=$RMG:$PYTHONPATH make

  # return to parent directory:
  cd ..

fi

# go to RMG-tests folder:
cd $TRAVIS_BUILD_DIR
