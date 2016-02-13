#!/bin/bash

# commit message of current head of RMG-tests = SHA1-ID of RMG-Py/database commit to be tested.
MESSAGE=$(git log --format=%B -n 1 HEAD)
echo "Message: "$MESSAGE

# version of RMG-Py/database to use when the SHA1 is of RMG-database/Py respectively:
VERSION="1.0.2"

# split the message on the '-' delimiter
IFS='-' read -a pieces <<< "$MESSAGE"

# check if the first part of the splitted string is the "rmgdb" string:
if [ "${pieces[0]}" == "rmgdb" ]; then
  # pushed commit is of RMG-database
  # message is of form: "rmgdb-SHA1"

  # pushed commit is of RMG-database:
  SHA1=${pieces[1]}
  echo "SHA1: "$SHA1
  
  # use $VERSION of RMG-Py binary:
  conda create -c rmg --name rmg_env rmg=$VERSION -y
  
  # clone entire RMG-database:
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git

  # check out the SHA-ID of the RMG-database commit:
  cd RMG-database
  git checkout $SHA1

  # activate environment:
  source activate rmg_env

  # set the RMG environment variable to the path with the rmg.py binary:
  export RMG=$CONDA_ENV_PATH/bin
  echo "RMG: "$RMG

  # return to parent directory:
  cd ..

else
  # message is of form: "SHA1"

  # pushed commit is of RMG-Py:
  SHA1=${pieces[0]}
  echo "SHA1: "$SHA1

  # use $VERSION of RMG-database:
  git clone -b $VERSION --single-branch https://github.com/ReactionMechanismGenerator/RMG-database.git

  # clone entire RMG-Py:
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git

  # check out the SHA-ID of the RMG-Py commit:
  cd RMG-Py
  git checkout $SHA1

  # create the conda environment based on the RMG-Py environment yaml:
  conda env create

  # activate environment:
  source activate rmg_env

  # set the RMG environment variable and add RMG-Py path to $PYTHONPATH:
  export RMG=`pwd`
  echo "RMG: "$RMG
  
  export PYTHONPATH=$RMG:$PYTHONPATH

  # compile RMG-Py:
  make

  # return to parent directory:
  cd ..

fi

# go to RMG-tests folder:
cd $TRAVIS_BUILD_DIR

# install cantera via conda:
conda install -c bryanwweber cantera -y