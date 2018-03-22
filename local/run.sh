#!/bin/bash

# Set RMG-tests base directory
export BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "Local tests base dir: "$BASE_DIR

# Set data directory
export DATA_DIR=$BASE_DIR/data_dir

# Figure out OS
if [[ $MACHTYPE == *"apple"* ]]; then
    export CURRENT_OS="mac"
elif [[ $MACHTYPE == *"linux"* ]]; then
    export CURRENT_OS="linux"
else
    echo "$MACHTYPE not supported. Exiting..."
    exit 0
fi
echo "Current OS: "$CURRENT_OS

# Print input settings
echo "Benchmark Branches:"
echo "    RMG-Py:       "$RMGPY_BENCHMARK_BRANCH
echo "    RMG-database: "$RMGDB_BENCHMARK_BRANCH
echo "Testing Branches:"
echo "    RMG-Py:       "$RMGPY_TESTING_BRANCH
echo "    RMG-database: "$RMGDB_TESTING_BRANCH
echo "Testing Jobs:     "$JOBS
echo "Data Directory:   "$DATA_DIR

. $BASE_DIR/color_define.sh
. $BASE_DIR/local/install_local.sh
. $BASE_DIR/version_summary.sh

echo "INSTALLATION COMPLETE"

cd $BASE_DIR/local

# Run RMG test jobs
if [ $JOBS == "all" ]; then
    for i in eg1 eg3 eg5 eg6 eg7 NC solvent_hexane MCH
    do
        if [ $PARALLEL == "true" ]; then
            export SBATCH_JOB_NAME=run_$i
            sbatch $BASE_DIR/local/submit_job.sl $i no
        else
            . $BASE_DIR/local/run_job.sh $i no
        fi
    done
else
    if [ $PARALLEL == "true" ]; then
        export SBATCH_JOB_NAME=run_$i
        sbatch $BASE_DIR/local/submit_job.sl $JOBS no
    else
        . $BASE_DIR/local/run_job.sh $JOBS no
    fi
fi

# Run thermo validation jobs
if [ $THERMOVAL == "true" ]; then
    for i in hc_cyclics hco_cyclics rmg_internal_cyclics
    do
        . $BASE_DIR/local/thermo_val.sh $i
    done
fi

