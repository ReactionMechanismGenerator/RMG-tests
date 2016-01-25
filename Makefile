run:
	mkdir -p testing/$(ARGS)
	rm -rf testing/$(ARGS)/*
	cp examples/rmg/$(ARGS)/input.py testing/$(ARGS)/input.py
	@ echo "Running $(ARGS) example"
	python $(RMG)/rmg.py testing/$(ARGS)/input.py
	bash check.sh $(ARGS)
