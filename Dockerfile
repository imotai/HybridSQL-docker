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

RUN yum install -y autoconf automake unzip bc expect libtool \
    && yum clean all

ENTRYPOINT [ "/bin/bash" ]

