#!/bin/bash

set -x
set -e

DEPS_PREFIX=/depends/thirdparty
export PATH=${DEPS_PREFIX}/bin:$PATH:/opt/rh/devtoolset-7/root/usr/bin/

wget -O gperftools-2.8.1.tar.gz https://github.com/gperftools/gperftools/releases/download/gperftools-2.8.1/gperftools-2.8.1.tar.gz

tar xzvf ./gperftools-2.8.1.tar.gz

cd ./gperftools-2.8.1
./configure && make && make install

