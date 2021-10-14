#!/bin/bash

job=$1
scoop_test=$2

set -e

if [ -z ${RMG_BENCHMARK+x} ]; then 
    echo "RMG variable is unset. Exiting..."
    exit 0
fi

export ORIGIN_PYTHONPATH=$PYTHONPATH
echo "Running Job: $1"

#############
# BENCHMARK #
#############

# Make folder for models generated by the benchmark version of RMG-Py/RMG-database:
export benchmark_tests=$DATA_DIR/tests/benchmark/$benchmark_tag
mkdir -p $benchmark_tests/rmg_jobs/$job
rm -rf $benchmark_tests/rmg_jobs/$job/*
cp $BASE_DIR/examples/rmg/$job/input.py $benchmark_tests/rmg_jobs/$job/input.py

source activate ${benchmark_env}

echo "Benchmark Version of RMG: "$RMG_BENCHMARK
export PYTHONPATH=$RMG_BENCHMARK:$ORIGIN_PYTHONPATH 

python $RMG_BENCHMARK/rmg.py $benchmark_tests/rmg_jobs/$job/input.py > /dev/null

source deactivate
export PYTHONPATH=$ORIGIN_PYTHONPATH

###########
# TESTING #
###########

# Make folder for models generated by the test version of RMG-Py and RMG-database:
export testing_tests=$DATA_DIR/tests/testing/$testing_tag
mkdir -p $testing_tests/rmg_jobs/$job
rm -rf $testing_tests/rmg_jobs/$job/*
cp $BASE_DIR/examples/rmg/$job/input.py $testing_tests/rmg_jobs/$job/input.py

source activate ${testing_env}

echo "Test Version of RMG: "$RMG_TESTING
export PYTHONPATH=$RMG_TESTING:$ORIGIN_PYTHONPATH 

python $RMG_TESTING/rmg.py $testing_tests/rmg_jobs/$job/input.py > /dev/null

export PYTHONPATH=$ORIGIN_PYTHONPATH
source deactivate

###########
# COMPARE #
###########

export check_tests=$DATA_DIR/tests/check/$testing_tag
mkdir -p $check_tests/rmg_jobs/$job
rm -rf $check_tests/rmg_jobs/$job/*
cd $check_tests/rmg_jobs/$job

source activate ${benchmark_env}
export PYTHONPATH=$RMG_BENCHMARK:$ORIGIN_PYTHONPATH 

bash $BASE_DIR/check.sh $job $benchmark_tests/rmg_jobs/$job $testing_tests/rmg_jobs/$job

export PYTHONPATH=$ORIGIN_PYTHONPATH
source deactivate

if [ $scoop_test == "yes" ]; then
    # Make folder for models generated by the test version of RMG-Py and RMG-database, with scoop enabled:
    mkdir -p $testing_tests/rmg_jobs/$job/scoop
    rm -rf $testing_tests/rmg_jobs/$job/scoop/*
    cp $BASE_DIR/examples/rmg/$job/input.py $testing_tests/rmg_jobs/$job/scoop/input.py
    echo "Version of RMG running with SCOOP: $RMG"
    source activate ${testing_env}
    export PYTHONPATH=$RMG_TESTING:$ORIGIN_PYTHONPATH

    python -m scoop -n 1 $RMG_TESTING/rmg.py $testing_tests/rmg_jobs/$job/scoop/input.py > /dev/null

    export PYTHONPATH=$ORIGIN_PYTHONPATH
    source deactivate

    # compare both generated models
    mkdir -p $check_tests/rmg_jobs/$job/scoop
    cd $check_tests/rmg_jobs/$job/scoop
    source activate ${benchmark_env}
    export PYTHONPATH=$RMG_BENCHMARK:$ORIGIN_PYTHONPATH 

    bash $BASE_DIR/check.sh $job $benchmark_tests/rmg_jobs/$job $testing_tests/rmg_jobs/$job/scoop

    export PYTHONPATH=$ORIGIN_PYTHONPATH
    source deactivate
fi

echo "$job: TEST JOB COMPLETE"

