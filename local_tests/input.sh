#!/bin/bash

export CURRENT_OS="mac" # only supports "mac" and "linux"
export RMG_TESTING_BRANCH="master"
export RMGDB_TESTING_BRANCH="master"
export JOBS="NC"

export BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Local tests base dir: "$BASE_DIR
