#!/bin/bash
#SBATCH -p debug
#SBATCH -J run
#SBATCH -n 1

JOB=$1
SCOOP=$2

bash $BASE_DIR/local_tests/run_local.sh $JOB $SCOOP