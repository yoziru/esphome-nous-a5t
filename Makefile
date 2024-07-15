.DEFAULT_GOAL := help
PROJECT := nous-a5t
TARGET := $(PROJECT).yml
HOST_SUFFIX := ""

compile: .esphome/build/$(PROJECT)/.pioenvs/$(PROJECT)/firmware.bin  ## Read the configuration and compile the binary.

.esphome/build/$(PROJECT)/.pioenvs/$(PROJECT)/firmware.bin: .venv/touchfile $(PROJECT).yml packages/*.yml
	. .venv/bin/activate; esphome compile $(PROJECT).yml

compress: firmware.bin.gz ## Compress the binary.

firmware.bin.gz: .esphome/build/$(PROJECT)/.pioenvs/$(PROJECT)/firmware.bin
	gzip -c .esphome/build/$(PROJECT)/.pioenvs/$(PROJECT)/firmware.bin > firmware.bin.gz

upload: .esphome/build/$(PROJECT)/.pioenvs/$(PROJECT)/firmware.bin ## Validate the configuration, create a binary, upload it, and start logs.
	if if [ $(HOST_SUFFIX) = "" ]; then \
		. .venv/bin/activate; esphome upload $(PROJECT).yml; esphome logs $(PROJECT).yml; \
	else \
		. .venv/bin/activate; esphome upload $(PROJECT).yml  --device $(PROJECT)$(HOST_SUFFIX); esphome logs $(PROJECT).yml  --device $(PROJECT)$(HOST_SUFFIX); \
	fi

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
	if [ $(HOST_SUFFIX) = "" ]; then \
		. .venv/bin/activate; esphome logs $(PROJECT).yml; \
	else \
		. .venv/bin/activate; esphome logs $(PROJECT).yml  --device $(PROJECT)$(HOST_SUFFIX); \
	fi

.PHONY: help
help: ## Show this help
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
