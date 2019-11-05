FROM debian:stable
MAINTAINER Akito <akito.kitsune@protonmail.com>
RUN \
  /bin/sh -c "ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime" && \
  apt-get -y update                                                    && \
  echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/mirror-retry      && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade                    && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install sudo pkg-config git   \
    build-essential m4 software-properties-common aspcud unzip curl       \
    dialog nano libx11-dev git sudo unzip                                 \
    libcap-dev ocaml ocaml-native-compilers camlp4-extra rsync opam    && \
  apt-get clean && rm -rf /var/lib/apt/lists/*                         && \
  echo 'opam ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/opam         && \
  chmod 440 /etc/sudoers.d/opam                                        && \
  chown root:root /etc/sudoers.d/opam                                  && \
  adduser --uid 1000 --disabled-password --gecos '' opam               && \
  passwd -l opam                                                       && \
  chown -R opam:opam /home/opam
USER opam
ENV HOME=/home/opam
WORKDIR /home/opam
RUN \
  /bin/sh -c "mkdir .ssh && chmod 700 .ssh"                            && \
  echo 'wrap-build-commands: []' > ~/.opamrc-nosandbox                 && \
  echo 'wrap-install-commands: []' >> ~/.opamrc-nosandbox              && \
  echo 'wrap-remove-commands: []' >> ~/.opamrc-nosandbox               && \
  echo 'required-tools: []' >> ~/.opamrc-nosandbox                     && \
  echo '#!/bin/sh' > /home/opam/opam-sandbox-disable                   && \
  echo 'cp ~/.opamrc-nosandbox ~/.opamrc' >>                              \
    /home/opam/opam-sandbox-disable                                    && \
  echo 'echo --- opam sandboxing disabled' >>                             \
    /home/opam/opam-sandbox-disable                                    && \
  chmod a+x /home/opam/opam-sandbox-disable                            && \
  sudo mv /home/opam/opam-sandbox-disable                                 \
    /usr/bin/opam-sandbox-disable                                      && \
  echo 'wrap-build-commands: ["%{hooks}%/sandbox.sh" "build"]' >          \
    ~/.opamrc-sandbox                                                  && \
  echo 'wrap-install-commands: ["%{hooks}%/sandbox.sh" "install"]'        \
    >> ~/.opamrc-sandbox                                               && \
  echo 'wrap-remove-commands: ["%{hooks}%/sandbox.sh" "remove"]'          \
    >> ~/.opamrc-sandbox                                               && \
  echo '#!/bin/sh' > /home/opam/opam-sandbox-enable                    && \
  echo 'cp ~/.opamrc-sandbox ~/.opamrc'                                   \
    >> /home/opam/opam-sandbox-enable                                  && \
  echo 'echo --- opam sandboxing enabled'                                 \
    >> /home/opam/opam-sandbox-enable                                  && \
  chmod a+x /home/opam/opam-sandbox-enable                             && \
  sudo mv /home/opam/opam-sandbox-enable /usr/bin/opam-sandbox-enable  && \
  opam init --bare -a --disable-sandboxing                             && \
  opam switch create 4.02.2 ocaml-base-compiler.4.02.2                 && \
  opam switch 4.02.2                                                   && \
  /bin/sh -c "opam install -y depext"
COPY docker/opam2 /usr/local/bin/opam
RUN /bin/sh -c "opam install -y batsh.0.0.6"                           && \
 #echo "source /home/opam/.profile" >> /home/opam/.bashrc              && \
  echo "eval $(opam env)" >> /home/opam/.bashrc
ENV OPAMYES=1
CMD ["/bin/sh" "-c" "bash"]