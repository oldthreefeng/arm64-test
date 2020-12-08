#!/bin/bash

## 创建新加坡2核4g的鲲鹏服务器. 初始镜像为 centos7.6
mycli hw create -c 1 --eip --keyName release >  InstanceId.json

cat InstanceId.json

ID=$(jq -r '.serverIds[0]' < InstanceId.json)
## wait to bind fip and ssh start
echo "wait to bind fip and ssh start"
sleep 140s
mycli hw list --id $ID > info.json

IP=$(jq -r '.addresses."a55545d8-a4cb-436d-a8ec-45c66aff725c"[0].addr' < info.json)
FIP=$(jq -r '.addresses."a55545d8-a4cb-436d-a8ec-45c66aff725c"[1].addr' < info.json)

cat info.json && echo $ID && echo $FIP && echo $IP


alias remotecmd="mycli --pk ./release.pem --host $FIP --cmd"

echo "install git"
remotecmd 'yum install -y git conntrack'

echo "clone cloud kernel"
remotecmd "git clone https://${GH_TOKEN}@github.com/oldthreefeng/arm64-test"

echo "install kubernetes bin"
remotecmd "cd arm64-test && \
           wget https://dl.k8s.io/v$1/kubernetes-server-linux-arm64.tar.gz && \
           wget https://github.com/sealyun-market/containerd/releases/download/v1.4.3/cri-containerd-cni-1.4.3-linux-arm64.tar.gz  && \
           cp  cri-containerd-cni-*-linux-arm64.tar.gz kube/containerd/cri-containerd-cni-linux-arm64.tar.gz && \
           tar zxvf kubernetes-server-linux-arm64.tar.gz && \
           cd kube && \
           cp ../kubernetes/server/bin/kubectl bin/ && \
           cp ../kubernetes/server/bin/kubelet bin/ && \
           cp ../kubernetes/server/bin/kubeadm bin/ && \
           sed s/k8s_version/$1/g -i conf/kubeadm.yaml && \
           cd shell && chmod a+x containerd.sh && sh containerd.sh && \
           systemctl restart containerd && \
           crictl pull fanux/lvscare && \
           sh master.sh && \
           cp /usr/sbin/conntrack ../bin/ && \
           cd ../.. && sleep 120 && crictl images && \
           sh save.sh && \
           tar zcvf kube$1-arm64.tar.gz kube && mv kube$1-arm64.tar.gz /tmp/kube$1-arm64.tar.gz"

# run init test
sh huawei/test.sh $1  $FIP


remotecmd "cd /root/arm64-test/ && sh huawei/oss.sh $1 $2"

mycli hw delete --id $ID --eip
echo "mycli hw delete --id $ID --eip"
