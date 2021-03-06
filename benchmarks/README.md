This directory privides a build script
for the benchmarks to evaluate our techniques.
The available benchmark list is as follows:
* combine-0.4.0
* diff-3.7 (from diffutils-3.7)
* du-8.32 (from coreutils-8.32)
* enscript-1.6.6
* gawk-5.1.0
* grep-3.4
* ls-8.32 (from coreutils-8.32)
* nano-4.9
* ptx-8.32
* sed-4.8
* trueprint-5.4
* xorriso-1.5.2

## How to Build Benchmarks
*Note that the provided script requires some dependencies. We provide a docker image (`koreaunivpl/dd-klee`) that contains all dependencies, but if you want to test with your local machine see [Requirements](#Requirements).*

The provided script (`build-benchmark.sh`) will help you download and build the benchmarks.
For example, if you want to build `combine-0.4.0` and `grep-3.4`, just use the following command:
```bash
$ ./build-benchmark.sh combine-0.4.0 grep-3.4
```
The script offers `all` options to build all 12 benchmarks.
```bash
$ ./build-benchmark.sh all
```

If you need further infomation use `--help` option:
```bash
$ ./build-benchmark.sh --help
```

### Build Your Own Project
You can build your own project with `configure` and `make` build system with the provided script.
For example, the following command will build `src/binary` executable in `path/to/your-project`:
```bash
$ ./build-benchmark.sh path/to/your-project:src/binary
# see path/to/your-project/obj-llvm and path/to/your-project/obj-gcov
```

## Requirements
Install dependencies with following command:
```bash
$ sudo apt-get update
$ sudo apt-get install -y --no-install-recommends \
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
    zlib1g-dev
$ sudo pip3 install wllvm
```
