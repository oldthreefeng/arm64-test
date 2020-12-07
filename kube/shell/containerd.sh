#!/bin/bash
# Author:louisehong4168
# Blog:https://fenghong.tech
# Time:2020-12-08 01:17:29
# Name:kube/shell/containerd.sh
#!/bin/sh
command_exists() {
   command -v "$@" > /dev/null 2>&1
}
set -x
if ! command_exists ctr; then
  tar  -xvzf ../containerd/cri-containerd-cni-linux-amd64.tar.gz -C /
  systemctl enable  containerd.service
  systemctl restart containerd.service
fi
# 已经安装了containerd并且运行了, 就不去重启.
ctr version || systemctl restart containerd.service
