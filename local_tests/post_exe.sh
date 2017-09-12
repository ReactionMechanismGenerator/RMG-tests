#!/bin/bash

conda info --envs > all_envs.txt
envs=(`grep 'rmg_tests_env' all_envs.txt | cut -d' ' -f 1`)
for i in "${envs[@]}"
do
   echo "$i"
   conda remove -n $i --all -y
done
rm all_envs.txt

conda env create -f ../environment.yml
source activate rmg_tests_env
python ../utilities/make_efficiency_table.py >> efficiency_table.out
source deactivate

conda remove -n rmg_tests_env --all -y