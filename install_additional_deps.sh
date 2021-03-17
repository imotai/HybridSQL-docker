#!/bin/bash

# Copyright 2021 4Paradigm
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eE
set -x

pushd /depends/thirdsrc/

echo "installing doxygen ..."
wget -O doxygen-1.8.19.src.tar.gz  https://github.com/doxygen/doxygen/archive/Release_1_8_19.tar.gz
tar xzf doxygen-1.8.19.src.tar.gz
pushd doxygen-Release_1_8_19

sed -i '/pedantic/d' ./cmake/CompilerWarnings.cmake
sed -i '/double-promotion/d' ./cmake/CompilerWarnings.cmake
mkdir build
cd build
cmake -G "Unix Makefiles" ..
make -j"$(nproc)"
make install

echo "installed doxygen"
rm -rf doxygen-1.8.19*
popd

# install maven
wget https://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar xzf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3 "$DEPS_PREFIX/maven"
rm apache-maven-3.6.3-bin.tar.gz

# install scala
wget https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.rpm
rpm -i scala-2.12.8.rpm
rm scala-2.12.8.rpm

popd
