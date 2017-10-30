#!/usr/bin/env bash

cd $RMG_BENCHMARK
source activate benchmark
make
source deactivate

cd $RMG_TESTING
source activate testing
make
source deactivate
