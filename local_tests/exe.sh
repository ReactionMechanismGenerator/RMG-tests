#!/bin/bash

export BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "Local tests base dir: "$BASE_DIR

. $BASE_DIR/local_tests/input.sh
. $BASE_DIR/color_define.sh
. $BASE_DIR/install.sh
. $BASE_DIR/version_summary.sh

if [ $JOBS == "all" ]; then
	. $BASE_DIR/run.sh eg1 no
	. $BASE_DIR/run.sh eg3 no
	. $BASE_DIR/run.sh eg5 no
	. $BASE_DIR/run.sh eg6 no
	. $BASE_DIR/run.sh eg7 no
	. $BASE_DIR/run.sh NC no
	. $BASE_DIR/run.sh MCH  yes
	. $BASE_DIR/run.sh solvent_hexane no
	. $BASE_DIR/run.sh methane no
else
	. $BASE_DIR/run.sh $JOBS no
fi

. $BASE_DIR/local_tests/clean_up.sh