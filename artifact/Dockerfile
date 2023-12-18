FROM debian:stable-20231120

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y g++-12 python3 python3-poetry texlive-base

COPY . /artifact/
WORKDIR /artifact/
