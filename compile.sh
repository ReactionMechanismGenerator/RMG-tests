#!/usr/bin/env bash

cd $RMG_BENCHMARK
source activate benchmark
make clean
make
source deactivate

cd $RMG_TESTING
source activate testing
make clean
make
source deactivate
