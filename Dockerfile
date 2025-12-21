# syntax=docker/dockerfile:1
FROM ubuntu:24.04
WORKDIR /root

RUN apt -U -y dist-upgrade
RUN apt -y install \
    binutils cmake curl findutils g++ grep libboost-dev libboost-filesystem-dev \
    libcurl4-gnutls-dev libenet-dev libfmt-dev libfreetype-dev libgloox-dev \
    libminiupnpc-dev libogg-dev libopenal-dev libpng-dev libsdl2-dev \
    libsodium-dev libvorbis-dev libwxgtk3.2-dev libxml2-dev llvm m4 make \
    patch pkg-config python3 sed uuid-dev wget xz-utils zlib1g-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain 1.76.0 --profile minimal
RUN /root/.cargo/bin/cargo install --locked cbindgen

