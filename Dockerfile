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

FROM centos:6

LABEL org.opencontainers.image.source https://github.com/4paradigm/HybridSQL-docker

RUN rm -r /etc/yum.repos.d/*
COPY --chown=root:root etc/yum.repos.d/CentOs-Base.repo /etc/yum.repos.d/

RUN yum update -y && \
    yum install -y autoconf-2.63 automake-1.11.1 unzip-6.0 bc-1.06.95 expect-5.44.1.15 libtool-2.2.6 && \
    yum clean all

ADD ./install_deps.sh /depends/
RUN cd /depends && source /opt/rh/devtoolset-7/enable && bash install_deps.sh

ADD ./install_doxygen.sh /depends/
RUN /depends/install_doxygen.sh

ADD ./install_gperftools.sh /depends/
RUN cd /depends && source /opt/rh/devtoolset-7/enable && bash /depends/install_gperftools.sh

RUN wget https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.rpm && rpm -i scala-2.12.8.rpm && rm scala-2.12.8.rpm
# RUN yum install -y nodejs npm

ADD ./install_asan_centos6.sh /depends/
RUN cd /depends && bash /depends/install_asan_centos6.sh

# Remove dynamic library files for static link
RUN find /depends/thirdparty/lib/ -name "lib*so*" | grep -v "libRemarks" | grep -v "libLTO" | xargs rm
RUN find /depends/thirdparty/lib64/ -name "lib*so*" | grep -v "libRemarks" | grep -v "libLTO" | xargs rm

ENTRYPOINT [ "/bin/bash" ]

