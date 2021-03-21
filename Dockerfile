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

ARG MIRROR=http://vault.centos.org

FROM centos:6 AS base
ARG MIRROR

LABEL org.opencontainers.image.source https://github.com/4paradigm/HybridSQL-docker

# since centos 6 is dead, replace with a backup mirror
COPY --chown=root:root etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/

RUN yum update -y && yum install -y centos-release-scl epel-release && yum clean all

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e "s|^#\s*baseurl=http://mirror.centos.org/|baseurl=${MIRROR}/|g" \
    -i.bak \
    /etc/yum.repos.d/CentOS-SCLo-*.repo

RUN yum install -y devtoolset-7-7.1 sclo-git212-1.0 devtoolset-7-libasan-devel-7.3.1 flex-2.5.35 \
    autoconf-2.63 automake-1.11.1 unzip-6.0 bc-1.06.95 expect-5.44.1.15 libtool-2.2.6 python27-1.1 \
    java-1.8.0-openjdk-devel-1.8.0.275.b01 lcov-1.10 && \
    yum clean all

COPY --chown=root:root etc/profile.d/enable-rh.sh /etc/profile.d/


FROM base AS builder

RUN yum install -y gettext-0.17 byacc-1.9.20070509 xz-4.999.9 tcl-8.5.7 && \
    yum clean all

WORKDIR /depends

COPY --chown=root:root *.sh ./

RUN bash fetch_resource.sh

RUN bash install_deps.sh

RUN tar cvzf thirdparty.tar.gz thirdparty/

FROM base

COPY etc/profile.d/enable-thirdparty.sh /etc/profile.d/
COPY --from=builder /usr/local/ /usr/

WORKDIR /depends/thirdsrc
COPY --from=builder /depends/thirdsrc/scala-2.12.8.rpm ./
RUN rpm -i scala-2.12.8.rpm && rm ./*.rpm

# use compressed in order to reduce image size
COPY --from=builder /depends/thirdparty.tar.gz /depends/

WORKDIR /root

ENTRYPOINT [ "/bin/bash" ]

