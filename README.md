Data-Driven KLEE
=============================

DD-KLEE is a data-driven symbolic execution engine, implemented on top of [KLEE](klee.github.io). We are taking data-driven approaches to deal with path-explosion problem of dynamic symbolic execution. The details of the techniques can be found in our papers, each of which consists of its own strategy. This repository is being maintained to provide all of such strategies with KLEE.

- [Installation](#installation)
  - [From Source](#from-source)
  - [Vagrant Box](#vagrant-box)
  - [Docker Image](#docker-image)
- [Getting Started](#getting-started)
- [Resources](#resources)

## Installation

### From Source

Currently, our tool is implemented on top of KLEE 2.2. The steps you should take are exactly same with the ones described in [Building KLEE with LLVM 9](https://klee.github.io/releases/docs/v2.2/build-llvm9/), official documentation of vanilla KLEE. (except that we build the tool with LLVM 11.)

Thus, here we briefly provide the configuration to setup KLEE and to use approaches described in our papers, which will reproduce the experimental results most closely.

#### Constraint solver

* minisat
* STP (2.3.3)

#### C/C++ library

* klee-uclibc (v1.3): not supported on macOS

  This should be installed to enable the POSIX environment model, which is used in our experiments on GNU benchmarks.

* (optional) libcxx: This sholud be installed to be able to run C++ code.

  You can build with the scripts provided by KLEE, with following command.

```sh
LLVM_VERSION=11 SANITIZER_BUILD= BASE=<LIBCXX_INSTALL_DIR> REQUIRES_RTTI=1 DISABLE_ASSERTIONS=1 ENABLE_DEBUG=0 ENABLE_OPTIMIZED=1 ./klee/scripts/build/build.sh libcxx
```

#### KLEE

After installing dependencies, you can build our extension of KLEE with `cmake`. Below is example configuration.

```sh
git clone https://github.com/kupl/dd-klee.git
mkdir -p ~/build
cd ~/build
cmake \
	-DENABLE_SOLVER_STP=ON \
	-DENABLE_POSIX_RUNTIME=ON \
	-DENABLE_KLEE_UCLIBC=ON \
	-DKLEE_UCLIBC_PATH=<KLEE_UCLIBC_SOURCE_DIR> \ 
	-DENABLE_UNIT_TESTS=OFF \
	-DENABLE_SYSTEM_TESTS=OFF \
	-DLLVM_CONFIG_BINARY=<PATH_TO_llvm-config-11> \
	-DLLVMCC=<PATH_TO_clang-11> \
	-DLLVMCXX=<PATH_TO_clang++-11> \
	-DENABLE_KLEE_LIBCXX=ON \
	-DKLEE_LIBCXX_DIR=<LIBCXX_INSTALL_DIR>/libc++-install-110 \
	-DKLEE_LIBCXX_INCLUDE_DIR=<LIBCXX_INSTALL_DIR>/libc++-install-110/include/c++/v1 \
	<dd-klee_SRC_DIRECTORY>/klee
make
```

### Vagrant Box

We provide a Vagrant Box to easily setup environment for our tool. The `Vagrantfile` is supplied to build a box with Ubuntu 20.04 LTS running on VirtualBox machine. For installation and detailed manual of it, read [Vagrant](https://vagrantup.com).

You can customize virtual machine, depending on your system spec. The following part of `Vagrantfile` can be modified for such purpose.

```ruby
Vagrant.configure("2") do |config|
  # Disksize
  config.disksize.size = "20GB"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8192"
    vb.cpus = "2"
  end
end
```

The following command creates a virtual machine and installs KLEE with its dependencies.

```sh
vagrant up
```

Now you can `ssh` the Ubuntu 20.04 VirtualBox machine and use our tool.

```sh
vagrant ssh

# halt the machine after exitting ssh session
vagrant halt
```

### Docker Image

We provide a `Dockerfile` to build docker image to run KLEE. It also provides several benchmarks referred in our papers. 

```sh
docker build -t kupl/dd-klee .
```

# Getting Started

We provide separate manuals for each approach we've taken on top of KLEE.

Pointers to get you started:

- [ParaDySE(Parametric Dynamic Symbolic Execution)](paradyse)

- [SymTuner(Maximizing the Power of Symbolic Execution by Adaptively Tuning External Parameters)](symtuner)

# Resources

- [KLEE](http://klee.github.io)
- [KLEE Tutorials](http://klee.github.io/tutorials/)
