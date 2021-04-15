#!/bin/bash

export BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "Local tests base dir: "$BASE_DIR

export RMG_TESTING_BRANCH=$1
export RMGDB_TESTING_BRANCH=$2
export JOBS=$3

cd $(dirname $4)
export DATA_DIR=$PWD/$(basename $4)
cd -

echo "Testing RMG-Py Branch: "$RMG_TESTING_BRANCH
echo "Testing RMG-database Branch: "$RMGDB_TESTING_BRANCH
echo "Testing Jobs: "$JOBS
echo "Data directory: "$DATA_DIR

. $BASE_DIR/color_define.sh
. $BASE_DIR/local_tests/install_local.sh
. $BASE_DIR/version_summary.sh

echo "INSTALLATION COMPLETE"

if [ $JOBS == "all" ]; then
	. $BASE_DIR/local_tests/run_local.sh eg1 no
	. $BASE_DIR/local_tests/run_local.sh eg3 no
	. $BASE_DIR/local_tests/run_local.sh eg5 no
	. $BASE_DIR/local_tests/run_local.sh eg6 no
	. $BASE_DIR/local_tests/run_local.sh eg7 no
	. $BASE_DIR/local_tests/run_local.sh NC no
	. $BASE_DIR/local_tests/run_local.sh solvent_hexane no
	. $BASE_DIR/local_tests/run_local.sh methane no
	. $BASE_DIR/local_tests/run_local.sh MCH no
	. $BASE_DIR/local_tests/run_local.sh H2S no
else
	. $BASE_DIR/local_tests/run_local.sh $JOBS no
fi

. $BASE_DIR/local_tests/thermo_val.sh hc_cyclics
. $BASE_DIR/local_tests/thermo_val.sh hco_cyclics
. $BASE_DIR/local_tests/thermo_val.sh n_cyclics
. $BASE_DIR/local_tests/thermo_val.sh rmg_internal_cyclics
. $BASE_DIR/local_tests/thermo_val.sh rmg_internal_hetero

. $BASE_DIR/local_tests/clean_up.sh

