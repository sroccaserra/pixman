
include .env
export

.PHONY: start-pico8
start-pico8:
	$(PICO8) -home $(shell pwd)

.PHONY: start-tic80
start-tic80:
	tic80 pixman.tic -sprites pixman.gif -code-watch pixman.lua
