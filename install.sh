#!/bin/bash
set -o verbose  # echo commands before executing.
# create a folder with benchmark version of RMG-Py and RMG-database:
# go to parent-folder of the RMG-tests repo:
cd ..
# prepare benchmark RMG-Py and RMG-db
export benchmark=$BASE_DIR/code/benchmark
echo "benchmark=$benchmark" >> $GITHUB_ENV
mkdir -p $benchmark
cd $benchmark

# clone benchmark RMG-Py
if [ ! -d "RMG-Py" ]; then
  # the directory was not cached, so clone it
  git clone https://github.com/ReactionMechanismGenerator/RMG-Py.git
  cd RMG-Py
else
  # the directory was cached, make sure that it's up to date
  cd RMG-Py
  git pull --ff-only origin main
fi

conda env create -q -n benchmark -f environment.yml
conda list -n benchmark

export RMG_BENCHMARK=`pwd`
echo "RMG_BENCHMARK=$RMG_BENCHMARK" >> $GITHUB_ENV
cd ..

# clone benchmark RMG-database:
if [ ! -d "RMG-database" ]; then
  git clone https://github.com/ReactionMechanismGenerator/RMG-database.git
  cd RMG-database
else
  cd RMG-database
  git pull --ff-only origin main
fi

export RMGDB_BENCHMARK=`pwd`
echo "RMGDB_BENCHMARK=$RMGDB_BENCHMARK" >> $GITHUB_ENV
cd ..

# prepare testing RMG-Py and RMG-db
export testing=$BASE_DIR/code/testing
echo "testing=$testing" >> $GITHUB_ENV
mkdir -p $testing
cd $testing

if [ $RMG_TESTING_BRANCH == "main" ]; then
  # set the RMG directory variable
  export RMG_TESTING=$RMG_BENCHMARK
  echo "RMG_TESTING=$RMG_TESTING" >> $GITHUB_ENV
  # copy the conda environment
  conda create --name testing --clone benchmark
else
  # clone entire RMG-Py
  if [ ! -d "RMG-Py" ]; then
    git clone -b ${RMG_TESTING_BRANCH} https://github.com/ReactionMechanismGenerator/RMG-Py.git
    cd RMG-Py
  else
    cd RMG-Py
    git fetch origin ${RMG_TESTING_BRANCH}
    git checkout ${RMG_TESTING_BRANCH}
    git reset --hard origin/${RMG_TESTING_BRANCH}
  fi

  conda env create -q -n testing -f environment.yml

  export RMG_TESTING=`pwd`
  echo "RMG_TESTING=$RMG_TESTING" >> $GITHUB_ENV
  cd ..
fi

if [ $RMGDB_TESTING_BRANCH == "main" ]; then
  # set the RMG database directory
  export RMGDB_TESTING=$RMGDB_BENCHMARK
  echo "RMGDB_TESTING=$RMGDB_TESTING" >> $GITHUB_ENV

else
  # clone RMG-database
  if [ ! -d "RMG-database" ]; then
    git clone -b ${RMGDB_TESTING_BRANCH} https://github.com/ReactionMechanismGenerator/RMG-database.git
    cd RMG-database
  else
    cd RMG-database
    git fetch origin ${RMGDB_TESTING_BRANCH}
    git checkout ${RMGDB_TESTING_BRANCH}
    git reset --hard origin/${RMGDB_TESTING_BRANCH}
  fi

  export RMGDB_TESTING=`pwd`
  echo "RMGDB_TESTING=$RMGDB_TESTING" >> $GITHUB_ENV
  cd ..
fi


source "$BASE_DIR/.bash_profile"
conda env list

# Get the conda environments from conda env list
# pick the last column of the row with keyword 'testing' or 'benchmark'
TESTING_CONDA_ENV=$(conda env list | awk '{print $NF}' | grep testing)
BENCHMARK_CONDA_ENV=$(conda env list | awk '{print $NF}' | grep benchmark)
echo "TESTING_CONDA_ENV=$TESTING_CONDA_ENV" >> $GITHUB_ENV
echo "BENCHMARK_CONDA_ENV=$BENCHMARK_CONDA_ENV" >> $GITHUB_ENV

# Install and link Julia dependencies
echo "Installing and linking Julia dependencies"
conda activate $BENCHMARK_CONDA_ENV
python -c "import julia; julia.install(); import diffeqpy; diffeqpy.install()"
julia -e 'using Pkg; Pkg.add(PackageSpec(name="StochasticDiffEq",version="6.36.0")); Pkg.add(PackageSpec(name="ReactionMechanismSimulator",version="0.4")); using ReactionMechanismSimulator;'
ln -sfn $(which python-jl) $(which python)
conda deactivate

conda activate $TESTING_CONDA_ENV
python -c "import julia; julia.install(); import diffeqpy; diffeqpy.install()"
julia -e 'using Pkg; Pkg.add(PackageSpec(name="StochasticDiffEq",version="6.36.0")); Pkg.add(PackageSpec(name="ReactionMechanismSimulator",version="0.4")); using ReactionMechanismSimulator;'
ln -sfn $(which python-jl) $(which python)
conda deactivate


# # setup MOPAC for both environments
# conda activate $BENCHMARK_CONDA_ENV
# yes 'Yes' | $BASE_DIR/miniconda/envs/benchmark/bin/mopac $MOPACKEY > /dev/null
# conda deactivate

# conda activate $TESTING_CONDA_ENV
# yes 'Yes' | $BASE_DIR/miniconda/envs/testing/bin/mopac $MOPACKEY > /dev/null
# conda deactivate

# go to RMG-tests folder
cd $BASE_DIR
