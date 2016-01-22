eg1:
	mkdir -p testing/eg1
	rm -rf testing/eg1/*
	cp examples/rmg/eg1/input.py testing/eg1/input.py
	@ echo "Running eg1 example"
	python $(RMG)/rmg.py testing/eg1/input.py
