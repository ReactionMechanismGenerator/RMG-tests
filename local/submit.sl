#!/bin/bash
#SBATCH -p debug
#SBATCH -J RMG-test
#SBATCH -n 1
#SBATCH --nodelist=node03
#SBATCH --output=main_log.out

# Usage: sbatch submit.sl

# Specify testing branches here
RMGPY_TESTING_BRANCH="test_branch"
RMGDB_TESTING_BRANCH="master"

# Specify benchmark branches here
# These should generally be left as master
RMGPY_BENCHMARK_BRANCH="master"
RMGDB_BENCHMARK_BRANCH="master"

# Specify jobs to run
# Current jobs available: eg1, eg3, eg5, eg6, eg7, NC, solvent_hexane, MCH, methane
JOBS="all"

# Specify whether to run thermo validation
THERMOVAL=true

# Specify whether or not to recreate the Anaconda environment
# This is generally not necessary, and can be left as false
CLEAN_ENV=false

# Specify whether or not the testing and benchmark jobs should use separate environments
# This is generally not necessary, and can be left as false
SEPARATE_ENV=false

# Specify whether to run jobs in parallel or serial
PARALLEL=true

# Start the job
. ./run.sh

