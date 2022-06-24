FROM ubuntu:20.04

USER root

# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bison \
        build-essential \
        clang-11 \
        cmake \
        curl \
        doxygen \
        file \
        flex \
        g++-multilib \
        gcc-multilib \
        git \
        graphviz \
        language-pack-en \
        libboost-all-dev \
        libcap-dev \
        libgoogle-perftools-dev \
        libncurses5-dev \
        libsqlite3-dev \
        libtcmalloc-minimal4 \
        llvm-11 \
        llvm-11-dev \
        llvm-11-tools \
        locales \
        minisat2 \
        perl \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        ssh-client \
        sudo \
        unzip \
        zlib1g-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir \
        tabulate \
        wllvm
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PATH=/usr/lib/llvm-11/bin:$PATH

# Install DD-KLEE

ENV STP_VERSION=2.3.3
RUN git clone -b ${STP_VERSION} --depth 1 https://github.com/stp/stp.git /opt/stp
WORKDIR /opt/stp/build
RUN cmake -DBUILD-SHARED_LIBS:BOOL=OFF -DENABLE_PYTHON_INTERFACE:BOOL=OFF .. && \
    make && \
    make install

ENV KLEE_UCLIBC_VERSION=klee_uclibc_v1.3
RUN git clone -b ${KLEE_UCLIBC_VERSION} --depth 1 https://github.com/klee/klee-uclibc.git /opt/klee-uclibc
WORKDIR /opt/klee-uclibc
RUN ./configure --make-llvm-lib && make

COPY klee /opt/klee-src
WORKDIR /opt/klee-src
RUN LLVM_VERSION=11 BASE=/opt/klee-libcxx ./scripts/build/build.sh libcxx

WORKDIR /opt/klee-bin
RUN cmake \
        -DENABLE_SOLVER_STP=ON \
        -DENABLE_POSIX_RUNTIME=ON \
        -DENABLE_KLEE_UCLIBC=ON \
        -DKLEE_UCLIBC_PATH=/opt/klee-uclibc \
        -DENABLE_KLEE_LIBCXX=ON \
        -DKLEE_LIBCXX_DIR=/opt/klee-libcxx/libc++-install-110 \
        -DKLEE_LIBCXX_INCLUDE_DIR=/opt/klee-libcxx/libc++-install-110/include/c++/v1 \
        -DENABLE_UNIT_TESTS=OFF \
        -DENABLE_SYSTEM_TESTS=OFF \
        /opt/klee-src \
    && make
ENV PATH=/opt/klee-bin/bin:$PATH

# Make non-root user
ARG USERNAME=ddklee
RUN useradd \
        --shell $(which bash) \
        -G sudo \
        -m -d /home/${USERNAME} -k /etc/skel \
        ${USERNAME} \
    && sed -i -e 's/%sudo.*/%sudo\tALL=(ALL:ALL)\tNOPASSWD:ALL/g' /etc/sudoers \
    && touch /home/${USERNAME}/.sudo_as_admin_successful

RUN mkdir -m 777 /workspace

# ParaDySE
COPY --chown=${USERNAME}:${USERNAME} paradyse /workspace/paradyse

# SymTuner
COPY symtuner/symtuner /opt/symtuner/symtuner
COPY symtuner/setup.py /opt/symtuner/setup.py
RUN pip3 install /opt/symtuner
COPY --chown=${USERNAME}:${USERNAME} symtuner/README.md /workspace/symtuner/README.md

# Benchmarks
COPY --chown=${USERNAME}:${USERNAME} benchmarks/build-benchmark.sh benchmarks/README.md /workspace/benchmarks/
WORKDIR /workspace/benchmarks
USER ${USERNAME}
RUN ./build-benchmark.sh all

# Entry point
WORKDIR /workspace
