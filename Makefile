eg1:
	mkdir -p testing/$@
	rm -rf testing/$@/*
	cp examples/rmg/$@/input.py testing/$@/input.py
	@ echo "Running $@ example"
	python $(RMG)/rmg.py testing/$@/input.py
	bash check.sh $@

eg3:
	mkdir -p testing/$@
	rm -rf testing/$@/*
	cp examples/rmg/$@/input.py testing/$@/input.py
	@ echo "Running $@ example"
	python $(RMG)/testing/$@/input.py
	bash check.sh $@

eg5:
	mkdir -p testing/$@
	rm -rf testing/$@/*
	cp examples/rmg/$@/input.py testing/$@/input.py
	@ echo "Running $@ example."
	python $(RMG)/testing/$@/input.py
	bash check.sh $@

eg6:
	mkdir -p testing/$@
	rm -rf testing/$@/*
	cp examples/rmg/$@/input.py testing/$@/input.py
	@ echo "Running $@ example."
	python $(RMG)/testing/$@/input.py
	bash check.sh $@

eg7:
	mkdir -p testing/$@
	rm -rf testing/$@/*
	cp examples/rmg/$@/input.py testing/$@/input.py
	@ echo "Running $@ example."
	python $(RMG)/testing/$@/input.py
	bash check.sh $@