This git repository tracks changes in RMG model generation by retaining a history of RMG generated models in CHEMKIN format.


## how to run locally

RMG-tests now has the option to run locally, in addition to running on travis. To run locally, follow these steps:

1. add any rmg jobs which you would like to run to `examples/rmg/` with the `input.py` file.
2. modify `local_tests/input.sh` by changing the operating system, the branch of RMG and the branch of RMG-database. Note that these branches must be located on github.com/reactionmechanismgenerator.
3. if you don't have anaconda installed, copy the first five lines of code from `before_install.sh` to `local_tests/before_install.sh`. 
4. run the script with `bash exe.sh`. If you are running on a server, create a submission script with this code in it. 
4. the script will output text as it is running, and this will also be saved to a log file
5. results of the run should appear in the `local_tests` folder. 
