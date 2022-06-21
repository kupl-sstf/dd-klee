This directory privides a build script
for the benchmarks to evaluate our techniques.
The available benchmark list is as follows:
* combine-0.4.0
* diff-3.7 (from diffutils-3.7)
* du-8.32 (from coreutils-8.32)
* enscript-1.6.6
* gawk-5.1.0
* gcal-4.1
* grep-3.4
* ls-8.32 (from coreutils-8.32)
* nano-4.9
* sed-4.8
* trueprint-5.4
* xorriso-1.5.2

## How to Build Benchmarks
*Note that the provided script requires some dependencies. We provide a docker image (`koreaunivpl/dd-klee`) that contains all dependencies, but if you want to test with your local machine see [Requirements](#Requirements).*

The provided script (`build-benchmark.sh`) will help you download and build the benchmarks.
For example, if you want to build `combine-0.4.0` and `gcal-4.1`, just use the following command:
```bash
$ ./build-benchmark.sh combine-0.4.0 gcal-4.1
```
The script offers `all` options to build all 12 benchmarks.
```bash
$ ./build-benchmark.sh all
```

If you need further infomation use `--help` option:
```bash
$ ./build-benchmark.sh --help
```

## Requirements
Install dependencies with following command:
```bash
$ sudo apt-get update
$ sudo apt-get install -y --no-install-recommends \
    bison \
    build-essential \
    cmake \
    clang-11 \
    curl \
    file \
    flex \
    git \
    language-pack-en \
    libboost-all-dev \
    libcap-dev \
    libgoogle-perftools-dev \
    libncurses5-dev \
    libtcmalloc-minimal4 \
    llvm-11 \
    llvm-11-dev \
    llvm-11-tools \
    locales \
    minisat2 \
    perl \
    python \
    python-pip \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    ssh-client \
    sudo \
    unzip \
    zlib1g-dev
$ sudo pip3 install wllvm
```
