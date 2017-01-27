#!/bin/bash

export CURRENT_OS="mac" # only supports "mac" and "linux"
export RMG_TESTING_BRANCH="master"
export RMGDB_TESTING_BRANCH="master"
export JOBS="NC"

export BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Local tests base dir: "$BASE_DIR

# temp for debug
export RMG_BENCHMARK=$BASE_DIR/code/benchmark/RMG-Py
export RMG_TESTING=$RMG_BENCHMARK
export RMGDB_BENCHMARK=$BASE_DIR/code/benchmark/RMG-database
export RMGDB_TESTING=$BASE_DIR/code/testing/RMG-database