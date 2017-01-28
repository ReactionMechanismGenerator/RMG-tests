#!/bin/bash

. ./input.sh
. ../color_define.sh
. ./install.sh
. ../version_summary.sh

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

. ./clean_up.sh