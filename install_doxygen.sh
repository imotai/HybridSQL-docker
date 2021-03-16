#!/bin/bash

set -x
set -e

DEPS_PREFIX=/depends/thirdparty
export CXXFLAGS=" -O3 -fPIC"
export CFLAGS=" -O3 -fPIC"
source /opt/rh/python27/enable
export PATH=${DEPS_PREFIX}/bin:$PATH:/opt/rh/devtoolset-7/root/usr/bin/

wget -O doxygen-1.8.19.src.tar.gz  http://pkg.4paradigm.com:81/rtidb/dev/doxygen-1.8.19.src.tar.gz

tar xzvf ./doxygen-1.8.19.src.tar.gz

cd ./doxygen-1.8.19/

sed -i '/pedantic/d' ./cmake/CompilerWarnings.cmake
sed -i '/double-promotion/d' ./cmake/CompilerWarnings.cmake

mkdir build

cd build

cmake -G "Unix Makefiles" ..

make

make install
