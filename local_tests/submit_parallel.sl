#!/bin/bash
#SBATCH -p debug
#SBATCH -J submit
#SBATCH -n 1
#SBATCH --output=main_log.out

# usage: sbatch submit_parallel.sl

export BASE_DIR="$( cd $PWD/../ && pwd)"
echo "Local tests base dir: "$BASE_DIR

# [USER INPUT] please specify the three
# inputs below
export RMG_TESTING_BRANCH="main"
export RMGDB_TESTING_BRANCH="main"
export JOBS="all"

cd $(dirname "../data_dir")
export DATA_DIR=$PWD/$(basename data_dir)
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
	for i in eg1 eg3 eg5 eg6 eg7 NC solvent_hexane methane H2S
	do
		sbatch $BASE_DIR/local_tests/run.sl $i no
	done

	sbatch $BASE_DIR/local_tests/run.sl MCH yes
else
	sbatch $BASE_DIR/local_tests/run.sl $JOBS no
fi

#. $BASE_DIR/local_tests/clean_up.sh
