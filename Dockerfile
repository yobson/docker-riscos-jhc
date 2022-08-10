FROM ubuntu:latest as ubuntu-base

WORKDIR /usr/src/gccsdk

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libtool patch wget help2man autogen m4 gcc g++ bison flex subversion gperf sed make build-essential autoconf2.13 automake cvs doxygen dpkg-dev gettext intltool libglib2.0-dev  libpopt-dev pkg-config policykit-1 rman subversion unzip wget xsltproc texinfo git libx11-dev tcl subversion libffi-dev libffi8ubuntu1 libgmp-dev libgmp10 libncurses-dev libncurses5 libtinfo5 curl

FROM ubuntu-base as gcc-builder

COPY ./gcc4 gcc4
COPY ./gccsdk-params gcc4

ARG NUMPROC=1
ARG MAKEFLAGS

RUN cd gcc4 && ./build-world -j${MUMPROCS}

FROM ubuntu-base as jhc-builder
COPY ./jhc-components jhc

RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_INSTALL_STACK=0 BOOTSTRAP_HASKELL_INSTALL_HLS=0 BOOTSTRAP_HASKELL_ADJUST_BASHRC=P sh
ENV PATH=/root/.ghcup/bin:/root/.cabal/bin:${PATH}
RUN cabal -O2 install cpphs

WORKDIR ./jhc
RUN cabal -O2 build jhc
RUN find -name 'jhc' -type f -exec cp {} /usr/bin/jhc-exec \;

RUN mkdir -p /opt/jhc
WORKDIR /opt/jhc
RUN jhc-exec -L . --build-hl  /usr/src/gccsdk/jhc/lib/jhc-prim/jhc-prim.yaml
RUN jhc-exec -L . --build-hl  /usr/src/gccsdk/jhc/lib/jhc/jhc.yaml
RUN jhc-exec -L . --build-hl  /usr/src/gccsdk/jhc/lib/haskell-extras/haskell-extras.yaml
RUN jhc-exec -L . --build-hl  /usr/src/gccsdk/jhc/lib/haskell2010/haskell2010.yaml
RUN jhc-exec -L . --build-hl  /usr/src/gccsdk/jhc/lib/haskell98/haskell98.yaml
RUN jhc-exec -L . --build-hl  /usr/src/gccsdk/jhc/lib/applicative/applicative.yaml
RUN jhc-exec -L . --build-hl  /usr/src/gccsdk/jhc/lib/flat-foreign/flat-foreign.yaml


FROM ubuntu-base
ENV PATH=/opt/gccsdk/cross/bin:${PATH}


WORKDIR /usr/src

RUN mkdir -p /root/.jhc
COPY --from=gcc-builder /opt/gccsdk /opt/gccsdk
COPY --from=jhc-builder /opt/jhc /opt/jhc
COPY --from=jhc-builder /usr/bin/jhc-exec /usr/bin/jhc-exec
COPY ./gccsdk-params /opt/gccsdk
COPY ./jhc-files/jhc /usr/bin/jhc
COPY ./jhc-files/arm-unknown-riscos-jhc /usr/bin/arm-unknown-riscos-jhc
COPY ./jhc-files/targets.ini /root/.jhc/targets.ini

CMD /bin/bash 
