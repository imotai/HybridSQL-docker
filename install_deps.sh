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

DEPS_SOURCE=$(pwd)/thirdsrc
DEPS_PREFIX=$(pwd)/thirdparty
DEPS_CONFIG="--prefix=${DEPS_PREFIX} --disable-shared --with-pic"
PACKAGE_MIRROR=https://github.com/imotai/packages/raw/main/

export CXXFLAGS=" -O3 -fPIC"
export CFLAGS=" -O3 -fPIC"

mkdir -p "$DEPS_PREFIX/lib" "$DEPS_PREFIX/include" "$DEPS_SOURCE"
export PATH=${DEPS_PREFIX}/bin:$PATH

if ! command -v nproc ; then
    alias nproc='sysctl -n hw.logicalcpu'
fi

pushd "$DEPS_SOURCE"

if ! command -v cmake ; then
    wget -q https://github.com/Kitware/CMake/releases/download/v3.19.7/cmake-3.19.7-Linux-x86_64.tar.gz
    tar xzf cmake-3.*
    pushd cmake-3.19.7-Linux-x86_64
    find . -type f -exec install -D -m 755 {} /usr/local/{} \; > /dev/null
    popd
    echo "installed cmake"
fi

if [ ! -f gtest_succ ]; then
    echo "installing gtest ...."
    wget -q $PACKAGE_MIRROR/googletest-release-1.10.0.tar.gz
    tar xzf googletest-release-1.10.0.tar.gz

    pushd googletest-release-1.10.0
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC
    make "-j$(nproc)"
    make install
    popd

    touch gtest_succ
    echo "install gtest done"
fi

if [ -f "zlib_succ" ]
then
    echo "zlib exist"
else
    echo "installing zlib..."
    wget -q -O zlib-1.2.11.tar.gz https://github.com/madler/zlib/archive/v1.2.11.tar.gz
    tar xzf zlib-1.2.11.tar.gz
    pushd zlib-1.2.11
    sed -i '/CFLAGS="${CFLAGS--O3}"/c\  CFLAGS="${CFLAGS--O3} -fPIC"' configure
    ./configure --static --prefix="$DEPS_PREFIX"
    make -j"$(nproc)"
    make install
    popd
    touch zlib_succ
    echo "install zlib done"
fi

if [ -f "protobuf_succ" ]
then
    echo "protobuf exist"
else
    echo "start install protobuf ..."
    wget -q $PACKAGE_MIRROR/protobuf-2.6.1.tar.gz
    tar zxf protobuf-2.6.1.tar.gz

    pushd protobuf-2.6.1
    export CPPFLAGS=-I${DEPS_PREFIX}/include
    export LDFLAGS=-L${DEPS_PREFIX}/lib
    ./configure $DEPS_CONFIG
    make -j"$(nproc)"
    make install
    popd

    touch protobuf_succ
    echo "install protobuf done"
fi

if [ -f "snappy_succ" ]
then
    echo "snappy exist"
else
    echo "start install snappy ..."
    wget -q $PACKAGE_MIRROR/snappy-1.1.1.tar.gz
    tar zxf snappy-1.1.1.tar.gz
    pushd snappy-1.1.1
    ./configure $DEPS_CONFIG
    make "-j$(nproc)"
    make install
    popd

    touch snappy_succ
    echo "install snappy done"
fi

if [ -f "gflags_succ" ]
then
    echo "gflags-2.1.1.tar.gz exist"
else
    wget -q $PACKAGE_MIRROR/gflags-2.2.0.tar.gz
    tar zxf gflags-2.2.0.tar.gz
    pushd gflags-2.2.0
    cmake -DCMAKE_INSTALL_PREFIX="${DEPS_PREFIX}" -DGFLAGS_NAMESPACE=google -DCMAKE_CXX_FLAGS=-fPIC
    make "-j$(nproc)"
    make install
    popd

    touch gflags_succ
    echo "install gflags done"
fi

if [ -f "unwind_succ" ]
then
    echo "unwind_exist"
else
    wget -q $PACKAGE_MIRROR/libunwind-1.1.tar.gz
    tar zxf libunwind-1.1.tar.gz
    pushd libunwind-1.1
    autoreconf -i
    ./configure --prefix="$DEPS_PREFIX"
    make -j4 && make install
    popd

    touch unwind_succ
fi

if [ -f "gperf_tool" ]
then
    echo "gperf_tool exist"
else
    wget -q $PACKAGE_MIRROR/gperftools-2.5.tar.gz
    tar zxf gperftools-2.5.tar.gz
    pushd gperftools-2.5
    ./configure --enable-cpu-profiler --enable-heap-checker --enable-heap-profiler  --enable-static --prefix="$DEPS_PREFIX"
    make "-j$(nproc)"
    make install
    popd
    touch gperf_tool
fi

# if [ -f "rapjson_succ" ]
# then
#     echo "rapjson exist"
# else
#     wget $PACKAGE_MIRROR/rapidjson.1.1.0.tar.gz
#     tar -zxvf rapidjson.1.1.0.tar.gz
#     cp -rf rapidjson-1.1.0/include/rapidjson "$DEPS_PREFIX/include"
#     touch rapjson_succ
# fi

if [ -f "leveldb_succ" ]
then
    echo "leveldb exist"
else
    wget -q $PACKAGE_MIRROR/leveldb.tar.gz
    tar zxf leveldb.tar.gz
    pushd leveldb
    sed -i 's/^OPT ?= -O2 -DNDEBUG/OPT ?= -O2 -DNDEBUG -fPIC/' Makefile
    make "-j$(nproc)"
    cp -rf include/* "$DEPS_PREFIX/include"
    cp out-static/libleveldb.a "$DEPS_PREFIX/lib"
    popd
    touch leveldb_succ
fi

if [ -f "openssl_succ" ]
then
    echo "openssl exist"
else
    wget -q -O OpenSSL_1_1_0.zip https://github.com/openssl/openssl/archive/OpenSSL_1_1_0.zip
    unzip OpenSSL_1_1_0.zip
    pushd openssl-OpenSSL_1_1_0
    ./config --prefix="$DEPS_PREFIX" --openssldir="$DEPS_PREFIX"
    make "-j$(nproc)"
    make install
    rm -rf "$DEPS_PREFIX"/lib/libssl.so*
    rm -rf "$DEPS_PREFIX"/lib/libcrypto.so*
    popd
    touch openssl_succ
    echo "openssl done"
fi

if [ -f "glog_succ" ]
then
    echo "glog exist"
else
    wget -q $PACKAGE_MIRROR/glogs-v0.4.0.tar.gz
    tar zxf glogs-v0.4.0.tar.gz
    pushd glog-0.4.0
    ./autogen.sh && CXXFLAGS=-fPIC ./configure --prefix="$DEPS_PREFIX" && make install
    popd
    touch glog_succ
fi

if [ -f "brpc_succ" ]
then
    echo "brpc exist"
else
    wget -q $PACKAGE_MIRROR/incubator-brpc.tar.gz
    tar zxf incubator-brpc.tar.gz
    pushd incubator-brpc
    sh config_brpc.sh --with-glog --headers="$DEPS_PREFIX/include" --libs="$DEPS_PREFIX/lib"
    make "-j$(nproc)" libbrpc.a output/include
    cp -rf output/include/* "$DEPS_PREFIX/include/"
    cp libbrpc.a "$DEPS_PREFIX/lib"
    popd

    touch brpc_succ
    echo "brpc done"
fi

if [ -f "zk_succ" ]
then
    echo "zk exist"
else
    wget -q https://archive.apache.org/dist/zookeeper/zookeeper-3.5.7/apache-zookeeper-3.5.7.tar.gz
    tar -zxf apache-zookeeper-3.5.7.tar.gz
    pushd apache-zookeeper-3.5.7/zookeeper-client/zookeeper-client-c && mkdir -p build
    cd build && cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC ..  && make && make install
    popd
    touch zk_succ
fi

if [ -f "abseil_succ" ]
then
    echo "abseil exist"
else
    wget -q $PACKAGE_MIRROR/abseil-cpp-20200923.3.tar.gz
    tar zxf abseil-cpp-20200923.3.tar.gz
    pushd abseil-cpp-20200923.3
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC ..
    make "-j$(nproc)" && make install
    popd
    touch abseil_succ
fi

if [ -f "bison_succ" ]
then
    echo "bison exist"
else
    wget -q https://ftp.gnu.org/gnu/bison/bison-3.4.tar.gz
    tar zxf bison-3.4.tar.gz
    pushd bison-3.4
    ./configure --prefix="$DEPS_PREFIX"
    make "-j$(nproc)" install
    popd
    touch bison_succ
fi

if [ -f "flex_succ" ]
then
    echo "flex exist"
else
    wget -q https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
    tar zxf flex-2.6.4.tar.gz
    pushd flex-2.6.4
    ./autogen.sh && ./configure --prefix="$DEPS_PREFIX" && make -j"$(nproc)" install
    popd
    touch flex_succ
fi

if [ -f "benchmark_succ" ]
then
    echo "benchmark exist"
else
    wget -q https://github.com/google/benchmark/archive/v1.5.0.tar.gz
    tar zxf v1.5.0.tar.gz
    pushd benchmark-1.5.0
    mkdir -p build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC -DBENCHMARK_ENABLE_GTEST_TESTS=OFF ..
    make -j"$(nproc)"
    make install
    popd
    touch benchmark_succ
fi

# if [ -f "xz_succ" ]
# then
#     echo "zx exist"
# else
#     wget --no-check-certificate -O xz-5.2.4.tar.gz $PACKAGE_MIRROR/xz-5.2.4.tar.gz
#     tar -zxvf xz-5.2.4.tar.gz
#     cd xz-5.2.4 && ./configure --prefix=${DEPS_PREFIX} && make -j4 && make install
#     cd -
#     touch xz_succ
# fi

if [ -f "double-conversion_succ" ]
then
    echo "double-conversion exist"
else
    wget -q https://github.com/google/double-conversion/archive/v3.1.5.tar.gz
    tar -zxf v3.1.5.tar.gz
    pushd double-conversion-3.1.5
    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC ..
    make -j"$(nproc)"
    make install
    popd
    touch double-conversion_succ
fi

# if [ -f "brotli_succ" ]
# then
#     echo "brotli exist"
# else
#     if [ -f "v1.0.7.tar.gz" ]
#     then
#         echo "brotli exist"
#     else
#         wget --no-check-certificate -O v1.0.7.tar.gz $PACKAGE_MIRROR/brotli-v1.0.7.tar.gz
#     fi
#     tar -zxvf v1.0.7.tar.gz
#     mkdir ./brotli-1.0.7/build/ && cd ./brotli-1.0.7/build/ && ../configure-cmake --prefix=${DEPS_PREFIX} && make && make install
#     cd -
#     touch brotli_succ
# fi

if [ -f "lz4_succ" ]
then
    echo " lz4 exist"
else
    wget -q https://github.com/lz4/lz4/archive/v1.7.5.tar.gz
    tar -zxf lz4-1.7.5.tar.gz
    pushd lz4-1.7.5
    make -j"$(nproc)"
    make install PREFIX="$DEPS_PREFIX"
    popd
    touch lz4_succ
fi

if [ -f "bzip2_succ" ]
then
    echo "bzip2 installed"
else
    wget -q https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
    tar -zxf bzip2-1.0.8.tar.gz
    pushd bzip2-1.0.8
    make -j"$(nproc)"
    make install PREFIX="$DEPS_PREFIX"
    popd
    touch bzip2_succ
fi

if [ -f "swig_succ" ]
then
    echo "swig exist"
else
    wget -q https://github.com/swig/swig/archive/v4.0.1.tar.gz
    tar -zxf swig-4.0.1.tar.gz
    pushd swig-4.0.1
    ./autogen.sh
    ./configure --without-pcre --prefix="$DEPS_PREFIX"
    make -j"$(nproc)"
    make install
    popd
    touch swig_succ
fi

if [ -f "jemalloc_succ" ]
then
    echo "jemalloc installed"
else
    wget -q https://github.com/jemalloc/jemalloc/archive/5.2.1.tar.gz
    tar -zxf jemalloc-5.2.1.tar.gz
    pushd jemalloc-5.2.1
    ./autogen.sh
    ./configure --prefix="$DEPS_PREFIX"
    make -j"$(nproc)"
    make install
    popd
    touch jemalloc_succ
fi

if [ -f "flatbuffer_succ" ]
then
    echo "flatbuffer installed"
else
    wget -q https://github.com/google/flatbuffers/archive/v1.11.0.tar.gz
    tar -zxf flatbuffers-1.11.0.tar.gz
    pushd flatbuffers-1.11.0
    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC ..
    make -j"$(nproc)"
    make install
    popd
    touch flatbuffer_succ
fi

if [ -f "zstd_succ" ]
then
    echo "zstd installed"
else
    wget -q https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.gz
    tar -zxf zstd-1.4.4.tar.gz
    pushd zstd-1.4.4
    make -j"$(nproc)"
    make install PREFIX="$DEPS_PREFIX"
    popd
    touch zstd_succ
fi

if [ -f "yaml_succ" ]
then
    echo "yaml-cpp installed"
else
    wget -q $PACKAGE_MIRROR/yaml-cpp-0.6.3.tar.gz
    tar -zxf yaml-cpp-0.6.3.tar.gz
    pushd yaml-cpp-yaml-cpp-0.6.3
    mkdir -p build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" ..
    make -j"$(nproc)"
    make install
    touch yaml_succ
fi

if [ -f "sqlite_succ" ]
then
    echo "sqlite installed"
else
    wget -q https://github.com/sqlite/sqlite/archive/version-3.32.3.zip
    unzip sqlite-*.zip
    pushd sqlite-3.32.3
    mkdir -p build
    cd build
    ../configure --prefix="$DEPS_PREFIX"
    make -j"$(nproc)" && make install
    popd
    touch sqlite_succ
fi

if [ -f "llvm_succ" ]
then
    echo "llvm_exist"
else
    wget -q $PACKAGE_MIRROR/llvm-9.0.0.src.tar.xz
    tar xf llvm-9.0.0.src.tar.xz
    pushd llvm-9.0.0.src
    mkdir -p build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC ..
    make "-j$(nproc)"
    make install
    popd
    touch llvm_succ
fi

if [ -f "boost_succ" ]
then
    echo "boost exist"
else
    wget -q $PACKAGE_MIRROR/boost_1_69_0.tar.gz
    tar -zxf boost_1_69_0.tar.gz
    pushd boost_1_69_0
    ./bootstrap.sh
    ./b2 link=static cxxflags=-fPIC cflags=-fPIC release install --prefix="$DEPS_PREFIX"
    popd
    touch boost_succ
fi

if [ -f "thrift_succ" ]
then
    echo "thrift installed"
else
    wget -q $PACKAGE_MIRROR/thrift-0.13.0.tar.gz
    tar -zxf thrift-0.13.0.tar.gz
    pushd thrift-0.13.0
    ./configure --enable-shared=no --enable-tests=no --with-python=no --with-nodejs=no --prefix="$DEPS_PREFIX" --with-boost="$DEPS_PREFIX"
    make -j"$(nproc)"
    make install
    popd
    touch thrift_succ
fi

wget -q http://ftp.iij.ad.jp/pub/linux/centos-vault/centos/6.9/sclo/x86_64/rh/devtoolset-7/libasan4-7.2.1-1.el6.x86_64.rpm
wget -q http://ftp.iij.ad.jp/pub/linux/centos-vault/centos/6.9/sclo/x86_64/rh/devtoolset-7/devtoolset-7-libasan-devel-7.2.1-1.el6.x86_64.rpm
yum install -y devtoolset-7-libasan-devel-7.2.1-1.el6.x86_64.rpm libasan4-7.2.1-1.el6.x86_64.rpm

wget -q -O doxygen-1.8.19.src.tar.gz  https://github.com/doxygen/doxygen/archive/Release_1_8_19.tar.gz

tar xzf ./doxygen-1.8.19.src.tar.gz

cd ./doxygen-1.8.19/

sed -i '/pedantic/d' ./cmake/CompilerWarnings.cmake
sed -i '/double-promotion/d' ./cmake/CompilerWarnings.cmake

mkdir build

cd build

cmake -G "Unix Makefiles" ..

make -j"$(nproc)"

make install
