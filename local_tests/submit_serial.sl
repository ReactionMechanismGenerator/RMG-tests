#!/bin/bash
#SBATCH -p debug
#SBATCH -J submit
#SBATCH -n 1
#SBATCH --output=main_log.out

#removes all benchmark_env_... from the conda environments

conda info --envs > all_envs.txt
envs=(`grep 'benchmark_env_' all_envs.txt | cut -d' ' -f 1`)
for i in "${envs[@]}"
do
   echo "$i"
   conda remove -n $i --all -y
done
envs=(`grep 'testing_env_' all_envs.txt | cut -d' ' -f 1`)
for i in "${envs[@]}"
do
   echo "$i"
   conda remove -n $i --all -y
done
rm all_envs.txt
echo 'ALL POSSIBLE CRASHED ENVIRONMENTS HAVE BEEN REMOVED'

py_branch="main"
db_branch="main"
jobs='NC'
data_dir='../data_dir'

bash exe.sh $py_branch $db_branch $jobs $data_dir >> main_log.out

bash post_exe.sh
