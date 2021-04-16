#!/usr/bin/env bash

cd $RMG_BENCHMARK
conda activate benchmark
make clean
make
conda deactivate

cd $RMG_TESTING
conda activate testing
make clean
make
conda deactivate
