# HybridSQL-docker

Development Dockerfile for HybridSQL

## Dependency Overview

```
/
├── opt/rh
│   ├── devtoolset-7/           # development toolchain like gcc
│   └── sclo-git212/            # git 2.12.2
├── depends
│   ├── thirdparty/             # third party dependencies, including binary and libs
│   └── thirdsrc/               # optional source of third party dependencies
├── /usr/local/
│   └── bin/                    # build dependencies, e.g cmake
│       └── cmake
```

| name | version | location | home | type | usage |
| ---- | ----    |  ----    | ---- | ---- | ----  |
| cmake | 3.19.7 | /usr/local | cmake.org | build dependency | build system tool |
| devtoolset-7 | 7.1 | /opt/rh/devtoolset-7 | [devtoolset-7](https://www.softwarecollections.org/en/scls/rhscl/devtoolset-7/) | build dependency | toolchain |
| sclo-git212 | 1.0 | /opt/rh/sclo-git212 | [sclo-git212](https://www.softwarecollections.org/en/scls/sclo/sclo-git212/) | - | version control |
| openssl | 1.1.0 | /depends/thirdparty | [openssl](https://github.com/openssl/openssl) | dependency | lib |
| llvm | 9.0.0 | /depends/thirdparty | [llvm](https://llvm.org/) | dependency | lib |
| boost | 1.69.0 | /depends/thirdparty | [boost](https://www.boost.org) | dependency | lib |
| google test | 1.10.0 | /depends/thirdparty | [googletest](https://github.com/google/googletest) | dependency | test lib |
| google log | 0.4.0 | /depends/thirdparty | [glog](https://github.com/google/glog) | dependency | logging lib |
| zlib | 1.12.11 | /depends/thirdparty | [zlib](https://github.com/madler/zlib) | dependency | compression library |
| protobuf | 2.6.1 | /depends/thirdparty |  [protobuf](https://github.com/protocolbuffers/protobuf) | dependency | serialization |
| snappy | 1.1.1 | /depends/thirdparty | [snappy](https://github.com/google/snappy) | dependency | compression |
| gflags | 2.1.1 | /depends/thirdparty | [gflags](https://github.com/gflags/gflags) | dependency | command line lib |
| libunwind | 1.1 | /depends/thirdparty | [libunwind](https://github.com/libunwind/libunwind) | dependency | lib |
| gperftools | 2.5 | /depends/thirdparty | [gperftools](https://github.com/gperftools/gperftools) | dependency | lib |
| leveldb | 1.20 | /depends/thirdparty | [leveldb](https://github.com/google/leveldb) | dependency | lib |
| incubator brpc | | /depends/thirdparty | [incubator-brpc](https://github.com/apache/incubator-brpc) | dependency | lib |
| bison | 3.4 | /depends/thirdparty | [bison](https://www.gnu.org/software/bison/) | dependency | lib |
| flex | 2.5.35 | /usr | [flex](https://github.com/westes/flex) | dependency | tool & lib |
| google benchmark | 1.5.0 | /depends/thirdparty | [benchmark](https://github.com/google/benchmark) | dependency | lib |
| swig | 4.0.1 | /depends/thirdparty | [swig](https://github.com/swig/swig) | dependency | lib |
| yaml cpp | 0.6.3 | /depends/thirdparty | [yaml-cpp](https://github.com/jbeder/yaml-cpp) | dependency | lib |
| sqlite | 3.32.3 | /depends/thirdparty | [sqlite](https://github.com/sqlite/sqlite) | dependency | lib |
| thrift | 0.13.0 | /depends/thirdparty | [thrift](https://thrift.apache.org/) | dependency | lib |
| doxygen | 1.8.19 | /usr/local | [doxygen](https://github.com/doxygen/doxygen) | dependency | document tool |
| maven | 3.6.3 | /depends/thirdparty | [maven](https://maven.apache.org) | build dependency | java build tool |
| jdk | openjdk-1.8.0_275 | /usr | [openjdk](https://openjdk.java.net/) | build&runtime dependency | java compiler |
| scala | 2.12.8 | /usr/ | [scala](https://www.scala-lang.org/) | build dependency | scala compiler |
| zookeeper | 3.4.14 | /depends/thirdparty | [zookeeper](https://zookeeper.apache.org/releases.html) | runtime dependency | |
| lcov | 1.10 | /usr | [lcov](https://github.com/linux-test-project/lcov) | dependency | coverage tool |
