.DEFAULT_GOAL := help
compile: .esphome/build/nous-a5t/.pioenvs/nous-a5t/firmware.bin  ## Read the configuration and compile the binary.

.esphome/build/nous-a5t/.pioenvs/nous-a5t/firmware.bin: .venv/touchfile nous-a5t.yml packages/*.yml
	. .venv/bin/activate; esphome compile nous-a5t.yml

compress: firmware.bin.gz ## Compress the binary.

firmware.bin.gz: .esphome/build/nous-a5t/.pioenvs/nous-a5t/firmware.bin
	gzip -c .esphome/build/nous-a5t/.pioenvs/nous-a5t/firmware.bin > firmware.bin.gz

upload: .esphome/build/nous-a5t/.pioenvs/nous-a5t/firmware.bin ## Validate the configuration, create a binary, upload it, and start logs.
	. .venv/bin/activate; esphome upload nous-a5t.yml; esphome logs nous-a5t.yml

deps: .venv/touchfile ## Create the virtual environment and install the requirements.

.venv/touchfile: requirements.txt
	test -d .venv || python -m venv .venv
	. .venv/bin/activate && pip install -Ur requirements.txt
	touch .venv/touchfile

.PHONY: clean
clean: ## Remove the virtual environment and the esphome build directory
	rm -rf .venv
	rm -rf .esphome

.PHONY: logs
logs: ## Start logs.
	. .venv/bin/activate; esphome logs nous-a5t.yml

.PHONY: help
help: ## Show this help
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
