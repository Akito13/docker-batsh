FROM debian:stable
MAINTAINER Akito <akito.kitsune@protonmail.com>
RUN apt-get -y update                                                  && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade                    && \
  echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/mirror-retry      && \
  apt-get -y update                                                    && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade                    && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install sudo pkg-config git   \
    build-essential m4 software-properties-common aspcud unzip rsync curl \
    dialog nano libx11-dev                                             && \
  apt-get -y update                                                    && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade                    && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install ocaml                 \
    ocaml-native-compilers camlp4-extra rsync                          && \
  apt-get clean
#TODO: Install opam
#TODO: Install BATSH dependencies
#TODO: opam switch 4.02.3
#TODO: Install BATSH