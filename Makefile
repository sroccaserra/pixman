
include .env
export

.PHONY: start
start:
	$(PICO8) -home $(shell pwd)
