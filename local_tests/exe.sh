#!/bin/bash

. ./input.sh
. ./before_install.sh
. ./install.sh
. ../version_summary.sh

if [ $JOBS == "all" ]; then
	. ./run.sh eg1 no
	. ./run.sh eg3 no
	. ./run.sh eg5 no
	. ./run.sh eg6 no
	. ./run.sh eg7 no
	. ./run.sh NC no
	. ./run.sh MCH  yes
	. ./run.sh solvent_hexane no
	. ./run.sh methane no
else
	. ./run.sh $JOBS no
fi

. ./clean_up.sh