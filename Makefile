eg1:
	mkdir -p testing/$@
	rm -rf testing/$@/*
	cp examples/rmg/$@/input.py testing/$@/input.py
	@ echo "Running $@ example"
	python $(RMG)/rmg.py testing/$@/input.py
	bash check.sh $@
