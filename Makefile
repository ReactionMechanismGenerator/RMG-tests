eg1:
	mkdir -p testing/minimal
	rm -rf testing/minimal/*
	cp examples/rmg/minimal/input.py testing/minimal/input.py
	@ echo "Running minimal example"
	python $(RMG)/rmg.py testing/minimal/input.py
