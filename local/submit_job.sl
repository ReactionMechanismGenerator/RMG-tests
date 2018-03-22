#!/bin/bash
#SBATCH -p debug
#SBATCH -n 1

JOB=$1
SCOOP=$2

. $BASE_DIR/local/run_job.sh $JOB $SCOOP
