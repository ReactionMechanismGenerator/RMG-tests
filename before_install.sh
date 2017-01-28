#!/bin/bash

# Set up anaconda
wget http://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O miniconda.sh
chmod +x miniconda.sh
./miniconda.sh -b -p $HOME/miniconda
export PATH=$HOME/miniconda/bin:$PATH

# Update conda itself
conda update --yes conda

# Standardize dirs
export BASE_DIR=$TRAVIS_BUILD_DIR
export CURRENT_OS="linux"

# Parse message for travis build
# commit message of current head of RMG-tests = SHA1-ID of RMG-Py/database commit to be tested.
MESSAGE=$(git log --format=%B -n 1 HEAD)
echo "Message: "$MESSAGE

export BRANCH=$TRAVIS_BRANCH
echo "Branch: "$BRANCH

# split the message on the '-' delimiter
IFS='-' read -a msg_pieces <<< "$MESSAGE"
IFS='-' read -a branch_pieces <<< "$BRANCH"

if [ "${branch_pieces[0]}" == "rmgdb" ]; then
	export RMG_TESTING_BRANCH="master"
	export RMGDB_TESTING_BRANCH="${branch_pieces[1]}"

elif [ "${branch_pieces[0]}" == "rmgpy" ]; then
	export RMG_TESTING_BRANCH="${branch_pieces[1]}"
	export RMGDB_TESTING_BRANCH="master"

elif [ "${branch_pieces[0]}" == "rmgpydb" ]; then
	export RMG_TESTING_BRANCH="${branch_pieces[1]}"
	export RMGDB_TESTING_BRANCH="${msg_pieces[2]}"
fi

echo "RMG_TESTING_BRANCH: "$RMG_TESTING_BRANCH
echo "RMGDB_TESTING_BRANCH: "$RMGDB_TESTING_BRANCH


