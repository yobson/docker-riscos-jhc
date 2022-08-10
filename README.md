# riscos-gccsdk-jhc

GCC and JHC for RISC OS Crosscompiler

## Container Layout

 * `/opt/gccsdk/bin` contains the compiler binaries.
 * `/usr/bin/jhc` x86 compiler
 * `/usr/bin/arm-unknown-riscos-jhc` risc os jhc compiler

## Building the Container

Run `make build`.

If everything is OK, the container name should be printed at the end.

As the build-world script only ever runs default (one process) builds, the
build is quite slow, even on a fast system.

If you want to upload a variant of the image, change or override 
`CONTAINER_NAME` to reference your desired registry/repository.

## Credit
A big thanks to [Chris Collins](https://github.com/kuroneko) for
building the docker container this is derived from. I never
managed to get gccsdk installed myself!
