FROM ubuntu:16.04
MAINTAINER "Marcelo Brandalero" <marcelo.brandalero@b-tu.de>

RUN apt-get update -y
RUN apt-get install -y apt-utils

RUN mkdir -p /llvm
WORKDIR /llvm
COPY required_packages.txt .
RUN apt-get install -y $(cat required_packages.txt)

RUN mkdir scripts
COPY scripts/build_compiler.sh ./scripts
COPY llvm-3.7.1.src.fgpu /llvm/llvm-3.7.1.src.fgpu

RUN bash ./scripts/build_compiler.sh

WORKDIR /
