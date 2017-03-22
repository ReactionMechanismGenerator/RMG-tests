#!/bin/bash
#SBATCH -p debug
#SBATCH -J submit
#SBATCH -n 1
py_branch="master"
db_branch="master"
jobs='NC'

bash exe.sh $py_branch $db_branch $jobs