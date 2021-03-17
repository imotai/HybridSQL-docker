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

FROM centos:6 AS base

LABEL org.opencontainers.image.source https://github.com/4paradigm/HybridSQL-docker

# since centos 6 is dead, replace with a backup mirror
COPY --chown=root:root etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/

RUN yum update -y && yum install -y centos-release-scl && yum clean all

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#\s*baseurl=http://mirror.centos.org/|baseurl=http://vault.centos.org/|g' \
    -i.bak \
    /etc/yum.repos.d/CentOS-SCLo-*.repo

RUN yum install -y devtoolset-7 sclo-git212 && yum clean all

COPY --chown=root:root etc/profile.d/enable-rh.sh /etc/profile.d/

FROM base AS builder

RUN yum install -y autoconf-2.63 automake-1.11.1 unzip-6.0 bc-1.06.95 expect-5.44.1.15 libtool-2.2.6 && \
    gettext-0.17 flex-2.5.35 byacc-1.9.20070509 xz-4.999.9 python27-1.1 tcl-8.5.7 && \
    yum clean all

COPY --chown=root:root ./install_deps.sh /depends/
WORKDIR /depends
RUN bash install_deps.sh

COPY --chown=root:root etc/profile.d/enable-thirdparty.sh /etc/profile.d/

FROM base

COPY --from=builder /depends/thirdparty /depends/thirdparty

ENTRYPOINT [ "/bin/bash" ]

