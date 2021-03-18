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
| openssl |
| llvm | 9.0.0 | 
| boost | 1.69.0 |
| google test | 1.10.0 | /depends/thirdparty | [googletest](https://github.com/google/googletest) | dependency | test lib |
| google log |
| zlib | 1.12.11 | /depends/thirdparty | [zlib](https://github.com/madler/zlib) | dependency | compression library |
| protobuf | 2.6.1 | /depends/thirdparty |  [protobuf](https://github.com/protocolbuffers/protobuf) | dependency | serialization |
| snappy | 1.1.1 | /depends/thirdparty | [snappy](https://github.com/google/snappy) | dependency | compression |
| gflags | 2.1.1 | /depends/thirdparty | [gflags](https://github.com/gflags/gflags) | dependency | command line lib |
| libunwind | 1.1 | /depends/thirdparty | [libunwind](https://github.com/libunwind/libunwind) | dependency | lib |
| gperf tool | 2.5 |
| leveldb | 
| baidu brpc | 
| abseil | 20200923.3 |
| bison | 3.4 | 
| flex |
| google benchmark |
| swig | 4.0.1 | 
| yaml cpp | 0.6.3 | 
| sqlite |
| thrift | 0.13.0 |
| doxygen | 1.8.19 |
| maven | 3.6.3 |
| scala | 2.12.8 |
