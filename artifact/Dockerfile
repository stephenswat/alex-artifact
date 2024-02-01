FROM debian:testing-20231218-slim

ARG DEBIAN_FRONTEND=noninteractive

ENV POETRY_HOME="/opt/poetry/"
WORKDIR /tmp/build

RUN apt-get update && \
    apt-get install --no-install-recommends -y gcc g++ gcc-13 g++-13 python3 \
    python3-dev texlive-base texlive-latex-extra texlive-fonts-extra \
    texlive-plain-generic cm-super clang++-15 llvm-15 curl ca-certificates \
    dvipng
RUN curl -sSL https://install.python-poetry.org > install_poetry.py
RUN python3 install_poetry.py --version 1.7.1

ENV PATH="${PATH}:/opt/poetry/bin"

COPY . /artifact/
WORKDIR /artifact/
