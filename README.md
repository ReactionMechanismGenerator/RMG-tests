This git repository tracks changes in RMG model generation by retaining a history of RMG generated models in CHEMKIN format.

Normally RMG-tests run automatically all the examples registered in `examples` folder on Travis platform. For convenience of debugging and running customized jobs (which sometimes violate Travis's restricted rule of memory usage and CPU time), we added the functionality of running RMG-tests locally. To run locally, please follow the instruction below.


## Instructions for Running RMG-tests Locally

1. Clone the repo down to your local machine: run `git clone https://github.com/ReactionMechanismGenerator/RMG-tests.git`

2. Make sure your have installed `anaconda` (please skip this step if you have already installed). If you are going to use it on a server, you probably are using the global anaconda which means you usually don't have have permission to write into `/path/to/anaconda/envs`. In this case, you need to install your own local anaconda, so follow the commands below:

	```bash
	# Set up anaconda
	wget http://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O miniconda.sh
	chmod +x miniconda.sh
	./miniconda.sh -b -p $HOME/miniconda
	export PATH=$HOME/miniconda/bin:$PATH

	# Update conda itself
	conda update --yes conda
	```

3. Modify `local_tests/input.sh` by specifying the operating system of your local machine (only linux and mac are supported, the branch name of RMG-Py and RMG-database). Note that these branches must be already pushed and located on github.com/reactionmechanismgenerator. Also change the job name to the one you want to run. If you need to test customized jobs, add a new folder with RMG input file which you want to run to `examples/rmg/`.

4. Run RMG-tests by 
	```bash
	cd local_tests
	bash exe.sh
	```
If you are running on a server, we've provided two example submission scripts (serial and parallel). 
For serial mode of testing:
	```bash
	sbatch submit_serial.sl
	``` 
For parallel mode of testing:
	```bash
	sbatch submit_parallel.sl $(pwd)
	```

5. You'll find the test log in folder `RMG-tests/tests/check/${you job name}`, and two versions of RMG-generated CHEMKIN models in folder `RMG-tests/tests/benchmark/${you job name}` and `RMG-tests/tests/testmodel/${you job name}` for detailed analysis.
