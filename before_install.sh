#!/bin/bash

# Standardize dirs
export BASE_DIR=$GITHUB_WORKSPACE
echo "BASE_DIR=$BASE_DIR" >> $GITHUB_ENV

# Create .netrc file for GitHub authentication
echo "machine api.github.com
    login RMGdev
    password $GH_TOKEN" > $HOME/.netrc
# Make ok.sh executable
chmod +x ok.sh

# Parse message for travis build
# commit message of current head of RMG-tests = SHA1-ID of RMG-Py/database commit to be tested.
MESSAGE=$(git log --format=%B -n 1 HEAD)
echo "Message: "$MESSAGE

# Remove the refs/heads/ prefix to the branch name
if [[ "$GITHUB_REF" == "refs/heads/"* ]]; 
then 
	export BRANCH=${GITHUB_REF:11}
	echo "BRANCH=${GITHUB_REF:11}" >> $GITHUB_ENV
else
	export BRANCH=$GITHUB_REF
	echo "BRANCH=$GITHUB_REF" >> $GITHUB_ENV
fi
echo "Branch: "$BRANCH

# split the message on the '-' delimiter
IFS='-' read -a msg_pieces <<< "$MESSAGE"
IFS='-' read -a branch_pieces <<< "$BRANCH"

if [ "${branch_pieces[0]}" == "rmgdb" ]; then
	export RMG_TESTING_BRANCH="main"
	export RMGDB_TESTING_BRANCH="${branch_pieces[1]}"
	export GITHUB_STATUS_PATH="/repos/ReactionMechanismGenerator/RMG-database/statuses/${msg_pieces[1]}"

elif [ "${branch_pieces[0]}" == "rmgpy" ]; then
	export RMG_TESTING_BRANCH="${branch_pieces[1]}"
	export RMGDB_TESTING_BRANCH="main"
	export GITHUB_STATUS_PATH="/repos/ReactionMechanismGenerator/RMG-Py/statuses/${msg_pieces[1]}"

elif [ "${branch_pieces[0]}" == "rmgpydb" ]; then
	export RMG_TESTING_BRANCH="${branch_pieces[1]}"
	export RMGDB_TESTING_BRANCH="${msg_pieces[2]}"
	export GITHUB_STATUS_PATH="/repos/ReactionMechanismGenerator/RMG-Py/statuses/${msg_pieces[1]}"

elif [ "${branch_pieces[0]}" == "rmgdbpy" ]; then
	export RMGDB_TESTING_BRANCH="${branch_pieces[1]}"
	export RMG_TESTING_BRANCH="${msg_pieces[2]}"
	export GITHUB_STATUS_PATH="/repos/ReactionMechanismGenerator/RMG-database/statuses/${msg_pieces[1]}"
fi

# write the variables to the environment
echo "RMG_TESTING_BRANCH=$RMG_TESTING_BRANCH" >> $GITHUB_ENV
echo "RMGDB_TESTING_BRANCH=$RMGDB_TESTING_BRANCH" >> $GITHUB_ENV
echo "GITHUB_STATUS_PATH=$GITHUB_STATUS_PATH" >> $GITHUB_ENV

echo "RMG_TESTING_BRANCH: "$RMG_TESTING_BRANCH
echo "RMGDB_TESTING_BRANCH: "$RMGDB_TESTING_BRANCH

# Url of the Github Actions build page
export BUILD_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
echo "BUILD_URL=$BUILD_URL" >> $GITHUB_ENV

echo "GitHub URL: " $GITHUB_STATUS_PATH
echo "Build URL: " $BUILD_URL

# Update GitHub status to pending
./ok.sh _format_json \
    state="pending" \
    context="continuous-integration/rmg-tests" \
    description="The RMG-tests build is running" \
    target_url=$BUILD_URL \
    | ./ok.sh _post $GITHUB_STATUS_PATH > /dev/null

# Set up anaconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash ./miniconda.sh -b -p $HOME/miniconda
source "$HOME/miniconda/etc/profile.d/conda.sh"
export PATH=$HOME/miniconda/bin:$PATH
echo "PATH=$HOME/miniconda/bin:$PATH" >> $GITHUB_ENV

# Update conda itself
conda update --yes conda
