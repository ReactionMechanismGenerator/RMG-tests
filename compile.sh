#!/usr/bin/env bash
set -o verbose

source "$BASE_DIR/.bash_profile"

cd $RMG_BENCHMARK
conda activate $BENCHMARK_CONDA_ENV
make clean
make
conda deactivate

cd $RMG_TESTING
conda activate $TESTING_CONDA_ENV
make clean
make
conda deactivate

set +o verbose