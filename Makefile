all:	build

GCC_REV=$(shell svn info --show-item revision gcc4 | sed -e 's/ //g')
CONTAINER_TAG=r$(GCC_REV)
CONTAINER_NAME=yobson/riscos-gccsdk-jhc
MAKE_PID := $(shell echo $$PPID)
JOB_FLAG := $(filter -j%, $(subst -j ,-j,$(shell ps T | grep "^\s*$(MAKE_PID).*$(MAKE)")))
NUMPROC  := $(subst -j,,$(JOB_FLAG))

export NUMPROC

build:	gcc4
	docker build -t ${CONTAINER_NAME}:${CONTAINER_TAG} -t ${CONTAINER_NAME}:latest --build-arg NUMPROC=${NUMPROC} --build-arg MAKEFLAGS="-j${NUMPROC}" .

gcc4:
	svn co svn://svn.riscos.info/gccsdk/trunk/gcc4 gcc4

.PHONY:	update-all
update-all:	gcc4
	cd gcc4 && svn up
