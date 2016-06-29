#!/bin/bash

# Set up anaconda
wget http://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O miniconda.sh
chmod +x miniconda.sh
./miniconda.sh -b -p $HOME/miniconda
export PATH=$HOME/miniconda/bin:$PATH

# Update conda itself
conda update --yes conda
