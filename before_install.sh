#!/bin/bash

# Set up anaconda
wget http://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O miniconda.sh
chmod +x miniconda.sh
./miniconda.sh -b -p $HOME/miniconda
export PATH=$HOME/miniconda/bin:$PATH

# Update conda itself
conda update --yes conda

# Define log colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export Yellow='\033[1;33m'
export NC='\033[0m' # No Color
