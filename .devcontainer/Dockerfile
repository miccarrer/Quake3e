# Reproducible build/dev environment for Urban Terror Optimized.
# Mirrors the Linux toolchain used in CI (.github/workflows/ci.yml) so a
# contributor can `make`, run the test harness, and the sanitizer/fuzz builds
# without installing anything on the host.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        # toolchain
        build-essential \
        clang \
        clang-format \
        clang-tidy \
        cppcheck \
        make \
        git \
        ca-certificates \
        # dev productivity
        bear \
        ccache \
        # engine build dependencies
        libcurl4-openssl-dev \
        mesa-common-dev \
        libgl1-mesa-dev \
        libxxf86dga-dev \
        libxrandr-dev \
        libxxf86vm-dev \
        libasound2-dev \
        libsdl2-dev \
    && rm -rf /var/lib/apt/lists/*

# ccache on PATH for faster rebuilds.
ENV PATH="/usr/lib/ccache:${PATH}"

WORKDIR /workspace
