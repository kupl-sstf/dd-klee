#!/usr/bin/env bash

#### /vagrant.sh - install system-wide program

# logging
INFO='\033[0;32m[INFO]'
ERR='\033[0;31m[ERR ]'
NC='\033[0;32m'  # default color of vagrant

# exit code to result message
result() {
  tool=$1
  if [[ $2 -eq 0 ]]; then
    echo -e "${INFO} $tool: Install Succeeded ${NC}"
  else
    echo -e "${ERR} $tool: Install Failed ${NC}"
  fi
}

. /vagrant/bash_profile
if klee --version >/dev/null 2>&1; then
  echo -e "${INFO} KLEE is already installed ${NC}"
  exit
fi


LOG_DIR=/home/vagrant/.vagrant.logs
if [[ -d $LOG_DIR ]]; then 
  rm -rf ${LOG_DIR}
fi
mkdir -p ${LOG_DIR}

echo -e "${INFO} ===== Start setup system dependencies ===== ${NC}"
for pkg in "build-essential" "cmake" "python3" "python3-pip" \
	"gcc-multilib" "g++-multilib" "git" "vim" "curl" \
	"libcap-dev" "libncurses5-dev" "python3-minimal" \
	"unzip" "libtcmalloc-minimal4" "libgoogle-perftools-dev" \
	"libsqlite3-dev" "doxygen" "bison" "flex" "libboost-all-dev" \
	"zlib1g-dev" "minisat" "clang-11" "llvm-11"; do
  echo -e "\n\nIntalling $pkg" >>${LOG_DIR}/apt-get.log
  sudo apt-get install -y $pkg >>${LOG_DIR}/apt-get.log 2>&1
  result $pkg $?
done
echo " "


# set environment variables
KLEE_DEPS_DIR=/home/vagrant/klee_deps
LLVM_HOME=/usr/lib/llvm-11

# stp 2.3.3
echo -e "${INFO} ===== Start setup build dependencies of KLEE ===== ${NC}"
git clone https://github.com/stp/stp $KLEE_DEPS_DIR/stp \
  >>${LOG_DIR}/stp.log 2>&1
cd $KLEE_DEPS_DIR/stp
git checkout tags/2.3.3 --quiet
mkdir build
cd build
CC=clang CXX=clang++ cmake .. >>${LOG_DIR}/stp.log 2>&1
make >>${LOG_DIR}/stp.log 2>&1
result stp $?

# z3
#git clone https://github.com/Z3Prover/z3 $KLEE_DEPS_DIR/z3 \
#  >>${LOG_DIR}/z3.log 2>&1
#cd $KLEE_DEPS_DIR/z3
#mkdir build
#cd build
#CC=clang CXX=clang++ cmake -G "Unix Makefiles" .. >>${LOG_DIR}/z3.log 2>&1
#make >>${LOG_DIR}/z3.log 2>&1
#result z3 $?

# klee-uclibc v1.3
git clone https://github.com/klee/klee-uclibc $KLEE_DEPS_DIR/klee-uclibc \
  >>${LOG_DIR}/klee_uclibc.log 2>&1
cd $KLEE_DEPS_DIR/klee-uclibc
git checkout tags/klee_uclibc_v1.3 --quiet
./configure --make-llvm-lib >>${LOG_DIR}/klee_uclibc.log 2>&1
make >>${LOG_DIR}/klee_uclibc.log 2>&1
result klee_uclibc $?
echo " "

# third party python packages
echo -e "${INFO} ===== Start setup third party python packages ===== ${NC}"
for pkg in "tabulate" "wllvm"; do
  pip3 install $pkg >>${LOG_DIR}/pip3.log 2>&1
  echo -e "\n\nIntalling $pkg" >>${LOG_DIR}/pip3.log
  result $pkg $?
done
echo " "


echo -e "${INFO} ===== Start installing KLEE ===== ${NC}"
KLEE_BUILD_DIR=/home/vagrant/klee
LLVM_HOME=/usr/lib/llvm-11

mkdir $KLEE_BUILD_DIR
cd $KLEE_BUILD_DIR


# Configure KLEE 
# 1. with other versions of LLVM
#	  -DLLVM_CONFIG_BINARY=<LLVM_CONFIG_BINARY>
#	  -DLLVMCC=<PATH_TO_CLANG>
#	  -DLLVMCXX=<PATH_TO_CLANG++>
#
# 2. with Z3 backend solver
#  	-DENABLE_SOLVER_Z3=ON \
#   -DZ3_INCLUDE_DIRS=$KLEE_DEPS_DIR/z3/include \
#   -DZ3_LIBRARIES=$KLEE_DEPS_DIR/z3/lib/libz3.so

cmake \
	-DENABLE_SOLVER_STP=ON \
	-DENABLE_POSIX_RUNTIME=ON \
	-DENABLE_KLEE_UCLIBC=ON \
	-DKLEE_UCLIBC_PATH=$KLEE_DEPS_DIR/klee-uclibc \
	-DKLEE_RUNTIME_BUILD_TYPE="Debug+Asserts" \
	-DENABLE_UNIT_TESTS=OFF \
	-DENABLE_SYSTEM_TESTS=OFF \
	/vagrant/klee >>${LOG_DIR}/klee.log 2>&1
make >>${LOG_DIR}/klee.log 2>&1
result klee $?

cat /vagrant/bash_profile >> /home/vagrant/.bashrc
