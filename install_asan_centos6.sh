#!/bin/bash

set -x
set -e

wget http://ftp.iij.ad.jp/pub/linux/centos-vault/centos/6.9/sclo/x86_64/rh/devtoolset-7/libasan4-7.2.1-1.el6.x86_64.rpm
wget http://ftp.iij.ad.jp/pub/linux/centos-vault/centos/6.9/sclo/x86_64/rh/devtoolset-7/devtoolset-7-libasan-devel-7.2.1-1.el6.x86_64.rpm
yum install -y devtoolset-7-libasan-devel-7.2.1-1.el6.x86_64.rpm libasan4-7.2.1-1.el6.x86_64.rpm
