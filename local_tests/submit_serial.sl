#!/bin/bash
#SBATCH -p debug
#SBATCH -J submit
#SBATCH -n 1
py_branch="master"
db_branch="master"
jobs='NC'
data_dir='../data_dir'

bash exe.sh $py_branch $db_branch $jobs $data_dir