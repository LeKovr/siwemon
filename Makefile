
SHELL          = /bin/bash
CFG            = .env
PRG           ?= $(shell basename $$PWD)

# Frontend host, empty value disables nginx
APP_SITE ?=

# URLs to fetch
MON_URLS ?= https://google.ru https://mail.ru

# URL Names
MON_NAMES ?= google,mail.ru

# File to save metrics (%F will be replaced with iteration's date)
DEST ?= data/swm-%F.log

# Sleep seconds before next iteration
SLEEP ?= 2

# Exit when this file removed
FLAG ?= $(PRG).on

# container prefix
PROJECT_NAME ?= hostname_domain

# dcape net connect to
DCAPE_NET    ?= dcape_default

# docker-compose version
DC_VER        = 1.23.2

define CONFIG_DEFAULT
# ------------------------------------------------------------------------------
# siwemon config file, generated by make $(CFG)

# Frontend host, empty value disables nginx
APP_SITE=$(APP_SITE)

# URLs to fetch
MON_URLS=$(MON_URLS)

# URL Names
MON_NAMES=$(MON_NAMES)

# File to save metrics (%F will be replaced with iteration's date)
DEST=$(DEST)

# Sleep seconds before next iteration
SLEEP=$(SLEEP)

# Exit when this file removed
FLAG=$(FLAG)

# container prefix
PROJECT_NAME=$(PROJECT_NAME)

# dcape network connect to, must be set in .env
DCAPE_NET=$(DCAPE_NET)

endef
export CONFIG_DEFAULT

-include $(CFG)
export

.PHONY : debug start stop up down dc help

debug:
	DEBUG=1 bash times.sh


## start mon daemon
start:
	if [ ! -f $(FLAG) ] ; then nohup bash times.sh > /dev/null 2>&1 &  fi

## stop mon daemon
stop:
	if [ -f $(FLAG) ] ; then rm $(FLAG) ; fi

# up daemon & front
up:
up: CMD=up --force-recreate -d
up: start dc

# down daemon & front
down:
down: CMD=rm -f -s
down: stop dc

## run docker-compose
dc: docker-compose.yml
	@if [[ ! "$$APP_SITE" ]] ; then echo "No APP_SITE: Skip dc"; else \
   docker run --rm  -i \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $$PWD:$$PWD \
  -w $$PWD \
  docker/compose:$$DC_VER \
  -p $$PROJECT_NAME \
  $(CMD) \
  ; fi

# create initial config
$(CFG):
	@[ -f $@ ] || { echo "Creating default $@" ; echo "$$CONFIG_DEFAULT" > $@ ; }

## Create default config file
config:
	@true

## List Makefile targets
help:  Makefile
	@grep -A1 "^##" $< | grep -vE '^--$$' | sed -E '/^##/{N;s/^## (.+)\n(.+):(.*)/\t\2:\1/}' | column -t -s ':'
