#!/bin/bash
# Author:louisehong4168
# Blog:https://fenghong.tech
# Time:2020-12-08 01:17:29
# Name:kube/shell/containerd.sh
#!/bin/sh

set -x
if ! [ -x /usr/local/bin/ctr ]; then
  tar  xvf ../containerd/cri-containerd-cni-linux-arm64.tar.gz -C /
  [ -f /usr/lib64/libseccomp.so.2 ] || cp ../lib64/lib* /usr/lib64 
  systemctl enable  containerd.service
  systemctl restart containerd.service
fi
# 已经安装了containerd并且运行了, 就不去重启.
ctr version || systemctl restart containerd.service
