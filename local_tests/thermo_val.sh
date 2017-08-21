#!/bin/bash
export ORIGIN_PYTHONPATH=$PYTHONPATH

###########
#BENCHMARK#
###########
source activate ${benchmark_env}
echo "benchmark version of RMG: "$RMG_BENCHMARK
export PYTHONPATH=$RMG_BENCHMARK:$ORIGIN_PYTHONPATH 

python $BASE_DIR/thermo_val/evaluate.py -d $BASE_DIR/examples/thermo_val/hc_cyclics/dataset.txt

python $BASE_DIR/thermo_val/evaluate.py -d $BASE_DIR/examples/thermo_val/hco_cyclics/dataset.txt

source deactivate
export PYTHONPATH=$ORIGIN_PYTHONPATH

#########
#TESTING#
#########
source activate ${testing_env}
echo "testing version of RMG: "$RMG_TESTING
export PYTHONPATH=$RMG_TESTING:$ORIGIN_PYTHONPATH 

python $BASE_DIR/thermo_val/evaluate.py -d $BASE_DIR/examples/thermo_val/hc_cyclics/dataset.txt

python $BASE_DIR/thermo_val/evaluate.py -d $BASE_DIR/examples/thermo_val/hco_cyclics/dataset.txt

source deactivate
export PYTHONPATH=$ORIGIN_PYTHONPAT
