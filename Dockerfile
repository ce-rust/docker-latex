FROM debian:stretch-slim AS build

ARG USERNAME=latex
ARG USERHOME=/home/latex
ARG USERID=1000
ARG USERGECOS=LaTEX

RUN adduser \
  --home "$USERHOME" \
  --uid $USERID \
  --gecos "$USERGECOS" \
  --disabled-password \
  "$USERNAME"

ARG WGET=wget
ARG GIT=git
ARG MAKE=make
ARG PANDOC=pandoc
ARG PYGMENTS=python-pygments

RUN apt-get update && apt-get install -y \
  texlive-full \
  # some auxiliary tools
  "$WGET" \
  "$GIT" \
  "$MAKE" \
  # markup format conversion tool
  "$PANDOC" \
  # Required for syntax highlighting using minted.
  "$PYGMENTS" && \
  # Removing documentation packages *after* installing them is kind of hacky,
  # but it only adds some overhead while building the image.
  apt-get --purge remove -y .\*-doc$ && \
  # Remove more unnecessary stuff
  apt-get clean -y

FROM build AS helpers

RUN apt-get install -y \
  ssh-client

ENV GIT_SSH_COMMAND="ssh"

# fonts
RUN git clone --depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git /usr/share/fonts/opentype/scp
RUN fc-cache -f -v /usr/share/fonts/opentype/scp

FROM helpers AS publish

WORKDIR /
