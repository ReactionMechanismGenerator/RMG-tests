#!/bin/bash
eg=$1
scoop_test=$2
set -e
if [ -z ${RMG_BENCHMARK+x} ]; then 
	echo "RMG variable is unset. Exiting..."
	exit 0
fi

export ORIGIN_PYTHONPATH=$PYTHONPATH
echo "Running $1 example"

###########
#BENCHMARK#
###########
# make folder for models generated by the benchmark version of RMG-Py/RMG-database:
mkdir -p $BASE_DIR/tests/benchmark/$eg
rm -rf $BASE_DIR/tests/benchmark/$eg/*
cp $BASE_DIR/../examples/rmg/$eg/input.py $BASE_DIR/tests/benchmark/$eg/input.py

source activate benchmark

echo "benchmark version of RMG: "$RMG_BENCHMARK
export PYTHONPATH=$RMG_BENCHMARK:$ORIGIN_PYTHONPATH 

# use the rmgrc file to point to the location of the desired RMG-database:
rmgrc="database.directory : "${RMGDB_BENCHMARK}/input/
rm -rf $HOME/.rmg
mkdir -p $HOME/.rmg
echo $rmgrc >> $HOME/.rmg/rmgrc

python $RMG_BENCHMARK/rmg.py $BASE_DIR/tests/benchmark/$eg/input.py > /dev/null

source deactivate
export PYTHONPATH=$ORIGIN_PYTHONPATH

#########
#TESTING#
#########
# make folder for models generated by the test version of RMG-Py and RMG-database:
mkdir -p $BASE_DIR/tests/testmodel/$eg
rm -rf $BASE_DIR/tests/testmodel/$eg/*
cp $BASE_DIR/../examples/rmg/$eg/input.py $BASE_DIR/tests/testmodel/$eg/input.py
source activate testing
echo "test version of RMG: "$RMG_TESTING

export PYTHONPATH=$RMG_TESTING:$ORIGIN_PYTHONPATH 

# use the rmgrc file to point to the location of the desired RMG-database:
rmgrc="database.directory : "${RMGDB_TESTING}/input/
rm -rf $HOME/.rmg
mkdir -p $HOME/.rmg
echo $rmgrc >> $HOME/.rmg/rmgrc

python $RMG_TESTING/rmg.py $BASE_DIR/tests/testmodel/$eg/input.py > /dev/null
export PYTHONPATH=$ORIGIN_PYTHONPATH
source deactivate


# compare both generated models
source activate benchmark
export PYTHONPATH=$RMG_BENCHMARK:$ORIGIN_PYTHONPATH 

bash check.sh $eg $BASE_DIR/tests/benchmark/$eg $BASE_DIR/tests/testmodel/$eg

export PYTHONPATH=$ORIGIN_PYTHONPATH
source deactivate

if [ $scoop_test == "yes" ]; then
	# make folder for models generated by the test version of RMG-Py and RMG-database, with scoop enabled:
	mkdir -p $BASE_DIR/tests/testmodel/$eg/scoop
	rm -rf $BASE_DIR/tests/testmodel/$eg/scoop/*
	cp $BASE_DIR/../examples/rmg/$eg/input.py $BASE_DIR/tests/testmodel/$eg/scoop/input.py
	echo "Version of RMG running with SCOOP: $RMG"
	source activate testing
	export PYTHONPATH=$RMG_TESTING:$ORIGIN_PYTHONPATH

	python -m scoop -n 1 $RMG_TESTING/rmg.py $BASE_DIR/tests/testmodel/$eg/scoop/input.py > /dev/null

	export PYTHONPATH=$ORIGIN_PYTHONPATH
	source deactivate

	# compare both generated models
	source activate benchmark
	export PYTHONPATH=$RMG_BENCHMARK:$ORIGIN_PYTHONPATH 

	bash check.sh $eg $BASE_DIR/tests/benchmark/$eg $BASE_DIR/tests/testmodel/$eg/scoop

	export PYTHONPATH=$ORIGIN_PYTHONPATH
	source deactivate
fi
