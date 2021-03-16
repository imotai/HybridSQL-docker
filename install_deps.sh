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

if [ ! -f gtest_succ ]; then
    echo "installing gtest ...."
    wget $PACKAGE_MIRROR/googletest-release-1.10.0.tar.gz
    tar xzvf googletest-release-1.10.0.tar.gz

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
    wget http://pkg.4paradigm.com/rtidb/dev/zlib-1.2.11.tar.gz
    tar zxf zlib-1.2.11.tar.gz
    cd zlib-1.2.11
    sed -i '/CFLAGS="${CFLAGS--O3}"/c\  CFLAGS="${CFLAGS--O3} -fPIC"' configure
    ./configure --static --prefix=${DEPS_PREFIX}
    make -j4
    make install
    cd -
    touch zlib_succ
    echo "install zlib done"
fi

if [ -f "protobuf_succ" ]
then
    echo "protobuf exist"
else
    echo "start install protobuf ..."
    wget $PACKAGE_MIRROR/protobuf-2.6.1.tar.gz
    tar zxf protobuf-2.6.1.tar.gz

    pushd protobuf-2.6.1
    export CPPFLAGS=-I${DEPS_PREFIX}/include
    export LDFLAGS=-L${DEPS_PREFIX}/lib
    ./configure "$DEPS_CONFIG"
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
    wget $PACKAGE_MIRROR/snappy-1.1.1.tar.gz
    tar zxf snappy-1.1.1.tar.gz
    pushd snappy-1.1.1
    ./configure "$DEPS_CONFIG"
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
    wget $PACKAGE_MIRROR/gflags-2.2.0.tar.gz
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
    wget $PACKAGE_MIRROR/libunwind-1.1.tar.gz
    tar -zxvf libunwind-1.1.tar.gz
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
    wget $PACKAGE_MIRROR/gperftools-2.5.tar.gz
    tar -zxvf gperftools-2.5.tar.gz
    pushd gperftools-2.5
    ./configure --enable-cpu-profiler --enable-heap-checker --enable-heap-profiler  --enable-static --prefix="$DEPS_PREFIX"
    make "-j$(nproc)"
    make install
    popd
    touch gperf_tool
fi

if [ -f "rapjson_succ" ]
then
    echo "rapjson exist"
else
    wget $PACKAGE_MIRROR/rapidjson.1.1.0.tar.gz
    tar -zxvf rapidjson.1.1.0.tar.gz
    cp -rf rapidjson-1.1.0/include/rapidjson "$DEPS_PREFIX/include"
    touch rapjson_succ
fi

if [ -f "leveldb_succ" ]
then
    echo "leveldb exist"
else
    wget $PACKAGE_MIRROR/leveldb.tar.gz
    tar -zxvf leveldb.tar.gz
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
    wget -O OpenSSL_1_1_0.zip http://pkg.4paradigm.com/rtidb/dev/OpenSSL_1_1_0.zip
    unzip OpenSSL_1_1_0.zip
    cd openssl-OpenSSL_1_1_0
    ./config --prefix=${DEPS_PREFIX} --openssldir=${DEPS_PREFIX}
    make -j5
    make install
    rm -rf ${DEPS_PREFIX}/lib/libssl.so*
    rm -rf ${DEPS_PREFIX}/lib/libcrypto.so*
    cd -
    touch openssl_succ
    echo "openssl done"
fi

if [ -f "glog_succ" ]
then
    echo "glog exist"
else
    wget $PACKAGE_MIRROR/glogs-v0.4.0.tar.gz
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
    wget $PACKAGE_MIRROR/incubator-brpc.tar.gz
    tar -zxvf incubator-brpc.tar.gz
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
    wget $PACKAGE_MIRROR/apache-zookeeper-3.5.7.tar.gz
    tar -zxvf apache-zookeeper-3.5.7.tar.gz
    pushd apache-zookeeper-3.5.7/zookeeper-client/zookeeper-client-c && mkdir -p build
    cd build && cmake -DCMAKE_INSTALL_PREFIX="$DEPS_PREFIX" -DCMAKE_CXX_FLAGS=-fPIC ..  && make && make install
    popd
    touch zk_succ
fi

if [ -f "abseil_succ" ]
then
    echo "abseil exist"
else
    wget $PACKAGE_MIRROR/abseil-cpp-20200923.3.tar.gz
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
    wget $PACKAGE_MIRROR/bison-3.4.tar.gz
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
    wget --no-check-certificate -O flex-2.6.4.tar.gz http://pkg.4paradigm.com:81/rtidb/dev/flex-2.6.4.tar.gz
    tar zxf flex-2.6.4.tar.gz
    cd flex-2.6.4
    ./autogen.sh && ./configure --prefix=${DEPS_PREFIX} && make install
    cd -
    touch flex_succ
fi

if [ -f "benchmark_succ" ]
then
    echo "benchmark exist"
else
    wget --no-check-certificate -O v1.5.0.tar.gz http://pkg.4paradigm.com:81/rtidb/dev/benchmark-v1.5.0.tar.gz
    tar zxf v1.5.0.tar.gz
    cd benchmark-1.5.0 && mkdir -p build
    cd build && cmake -DCMAKE_INSTALL_PREFIX=${DEPS_PREFIX} -DCMAKE_CXX_FLAGS=-fPIC -DBENCHMARK_ENABLE_GTEST_TESTS=OFF ..
    make -j4 && make install
    cd ${DEPS_SOURCE}
    touch benchmark_succ
fi

if [ -f "xz_succ" ]
then
    echo "zx exist"
else
    wget --no-check-certificate -O xz-5.2.4.tar.gz http://pkg.4paradigm.com/fesql/xz-5.2.4.tar.gz
    tar -zxvf xz-5.2.4.tar.gz
    cd xz-5.2.4 && ./configure --prefix=${DEPS_PREFIX} && make -j4 && make install
    cd -
    touch xz_succ
fi

if [ -f "double-conversion_succ" ]
then
    echo "double-conversion exist"
else
    if [ -f "v3.1.5.tar.gz" ]
    then
        echo "double-conversion pkg exist"
    else
        wget --no-check-certificate -O v3.1.5.tar.gz http://pkg.4paradigm.com:81/rtidb/dev/double-conversion-v3.1.5.tar.gz
    fi
    tar -zxvf v3.1.5.tar.gz
    cd double-conversion-3.1.5 && mkdir -p build
    cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${DEPS_PREFIX} -DCMAKE_CXX_FLAGS=-fPIC ..
    make -j4 && make install
    cd ${DEPS_SOURCE}
    touch double-conversion_succ
fi

if [ -f "brotli_succ" ]
then
    echo "brotli exist"
else
    if [ -f "v1.0.7.tar.gz" ]
    then
        echo "brotli exist"
    else
        wget --no-check-certificate -O v1.0.7.tar.gz http://pkg.4paradigm.com:81/rtidb/dev/brotli-v1.0.7.tar.gz
    fi
    tar -zxvf v1.0.7.tar.gz
    mkdir ./brotli-1.0.7/build/ && cd ./brotli-1.0.7/build/ && ../configure-cmake --prefix=${DEPS_PREFIX} && make && make install
    cd -
    touch brotli_succ
fi

if [ -f "lz4_succ" ]
then
    echo " lz4 exist"
else
    if [ -f "lz4-1.7.5.tar.gz" ]
    then
        echo "lz4 tar exist"
    else
        wget --no-check-certificate -O lz4-1.7.5.tar.gz http://pkg.4paradigm.com/fesql/lz4-1.7.5.tar.gz
    fi
    tar -zxvf lz4-1.7.5.tar.gz
    cd lz4-1.7.5 && make -j4 && make install PREFIX=${DEPS_PREFIX}
    cd ${DEPS_SOURCE}
    touch lz4_succ
fi

if [ -f "bzip2_succ" ]
then
    echo "bzip2 installed"
else
    if [ -f "bzip2-1.0.8.tar.gz" ]
    then
        echo "bzip2-1.0.8.tar.gz  downloaded"
    else
        wget --no-check-certificate -O bzip2-1.0.8.tar.gz http://pkg.4paradigm.com/fesql/bzip2-1.0.8.tar.gz
    fi
    tar -zxvf bzip2-1.0.8.tar.gz
    cd bzip2-1.0.8 && make -j4 && make install PREFIX=${DEPS_PREFIX}
    cd -
    touch bzip2_succ
fi

if [ -f "swig_succ" ]
then
    echo "swig exist"
else
    if [ -f "swig-4.0.1.tar.gz" ]
    then
        echo "swig exist"
    else
        wget --no-check-certificate -O swig-4.0.1.tar.gz http://pkg.4paradigm.com/fesql/swig-4.0.1.tar.gz
    fi
    tar -zxvf swig-4.0.1.tar.gz
    cd swig-4.0.1 && ./autogen.sh && ./configure --without-pcre --prefix=${DEPS_PREFIX} && make -j20 && make install
    cd -
    touch swig_succ
fi

if [ -f "jemalloc_succ" ]
then
    echo "jemalloc installed"
else
    if [ -f "jemalloc-5.2.1.tar.gz" ]
    then
        echo "jemalloc-5.2.1.tar.gz downloaded"
    else
        wget --no-check-certificate -O jemalloc-5.2.1.tar.gz http://pkg.4paradigm.com/fesql/jemalloc-5.2.1.tar.gz
    fi
    tar -zxvf jemalloc-5.2.1.tar.gz
    cd jemalloc-5.2.1 && ./autogen.sh && ./configure --prefix=${DEPS_PREFIX} && make -j4 && make install
    cd -
    touch jemalloc_succ
fi

if [ -f "flatbuffer_succ" ]
then
    echo "flatbuffer installed"
else
    if [ -f "flatbuffers-1.11.0.tar.gz" ]
    then
        echo "flatbuffers-1.11.0.tar.gz downloaded"
    else
        wget --no-check-certificate -O flatbuffers-1.11.0.tar.gz http://pkg.4paradigm.com/fesql/flatbuffers-1.11.0.tar.gz
    fi
    tar -zxvf flatbuffers-1.11.0.tar.gz
    cd flatbuffers-1.11.0 && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${DEPS_PREFIX} -DCMAKE_CXX_FLAGS=-fPIC ..
    make -j4 && make install
    cd ${DEPS_SOURCE}
    touch flatbuffer_succ
fi

if [ -f "zstd_succ" ]
then
    echo "zstd installed"
else
    if [ -f "zstd-1.4.4.tar.gz" ]
    then
        echo "zstd-1.4.4.tar.gz  downloaded"
    else
        wget --no-check-certificate -O zstd-1.4.4.tar.gz http://pkg.4paradigm.com/fesql/zstd-1.4.4.tar.gz
    fi
    tar -zxvf zstd-1.4.4.tar.gz
    cd zstd-1.4.4 && make -j4 && make install PREFIX=${DEPS_PREFIX}
    cd ${DEPS_SOURCE}
    touch zstd_succ
fi

if [ -f "yaml_succ" ]
then
    echo "yaml-cpp installed"
else
    if [ -f "yaml-cpp-0.6.3.tar.gz" ]
    then
        echo "yaml-cpp-0.6.3.tar.gz downloaded"
    else
        wget --no-check-certificate -O yaml-cpp-0.6.3.tar.gz http://pkg.4paradigm.com:81/rtidb/dev/yaml-cpp-0.6.3.tar.gz
    fi
    tar -zxvf yaml-cpp-0.6.3.tar.gz
    cd yaml-cpp-yaml-cpp-0.6.3 && mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=${DEPS_PREFIX} ..
    make && make install
    touch yaml_succ
fi

if [ -f "sqlite_succ" ]
then
    echo "sqlite installed"
else
    wget --no-check-certificate -O sqlite.zip http://pkg.4paradigm.com:81/rtidb/dev/sqlite-3.32.3.zip
    unzip sqlite.zip
    cd sqlite && mkdir -p build && cd build
    ../configure --prefix=${DEPS_PREFIX}
    make && make install
    touch sqlite_succ
fi

if [ -f "llvm_succ" ]
then
    echo "llvm_exist"
else
    if [ ! -d "llvm-9.0.0.src" ]
    then
        wget --no-check-certificate -O llvm-9.0.0.src.tar.xz http://pkg.4paradigm.com/fesql/llvm-9.0.0.src.tar.xz
        tar xf llvm-9.0.0.src.tar.xz
    fi
    cd llvm-9.0.0.src && mkdir -p build
    cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${DEPS_PREFIX} -DCMAKE_CXX_FLAGS=-fPIC ..
    make -j8 && make install
    cd ${DEPS_SOURCE}
    touch llvm_succ
fi

if [ -f "boost_succ" ]
then
    echo "boost exist"
else
    if [ -f "boost_1_69_0.tar.gz" ]
    then
        echo "boost exist"
    else
        wget --no-check-certificate -O boost_1_69_0.tar.gz http://pkg.4paradigm.com/fesql/boost_1_69_0.tar.gz
    fi
    tar -zxvf boost_1_69_0.tar.gz
    cd boost_1_69_0 && ./bootstrap.sh && ./b2 link=static cxxflags=-fPIC cflags=-fPIC release install --prefix=${DEPS_PREFIX}
    cd -
    touch boost_succ
fi

if [ -f "thrift_succ" ]
then
    echo "thrift installed"
else
    if [ -f "thrift-0.13.0.tar.gz" ]
    then
        echo "thrift-0.13.0.tar.gz  downloaded"
    else
        wget --no-check-certificate -O thrift-0.13.0.tar.gz http://pkg.4paradigm.com:81/rtidb/dev/thrift-0.13.0.tar.gz
    fi
    tar -zxvf thrift-0.13.0.tar.gz
    cd thrift-0.13.0 && ./configure --enable-shared=no --enable-tests=no --with-python=no --with-nodejs=no --prefix=${DEPS_PREFIX} --with-boost=${DEPS_PREFIX} && make -j4 && make install
    cd ${DEPS_SOURCE}
    touch thrift_succ
fi

