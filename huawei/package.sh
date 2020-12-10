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

cat info.json && echo "id: $ID, eip: $FIP , ip:$IP"


alias remotecmd="mycli --pk ./release.pem --host $FIP --cmd"

echo "install git conntrack with quiet"
remotecmd 'yum install -y git conntrack -q'

echo "clone cloud kernel"
remotecmd "git clone https://${GH_TOKEN}@github.com/oldthreefeng/arm64-test"

echo "install kubernetes bin"
remotecmd "cd arm64-test && \
           wget https://dl.k8s.io/v$1/kubernetes-server-linux-arm64.tar.gz && \
           wget https://download.docker.com/linux/static/stable/aarch64/docker-19.03.12.tgz && \
           wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.19.0/crictl-v1.19.0-linux-arm64.tar.gz && \
           cp  docker-19.03.12.tgz kube/docker/docker.tgz && \
           tar zxvf kubernetes-server-linux-arm64.tar.gz && \
		   tar xf crictl-v1.19.0-linux-arm64.tar.gz  && \
           cd kube && \
		   cp ../crictl bin/ && \
           cp ../kubernetes/server/bin/kubectl bin/ && \
           cp ../kubernetes/server/bin/kubelet bin/ && \
           cp ../kubernetes/server/bin/kubeadm bin/ && \
           sed s/k8s_version/$1/g -i conf/kubeadm.yaml && \
           cd shell && sh init.sh && \
           rm -rf /etc/docker/daemon.json && systemctl restart docker && \
           docker pull fanux/lvscare && \
           sh master.sh && \
           cp /usr/sbin/conntrack ../bin/ && \
           cd ../.. && sleep 120 && docker images && \
           sh save.sh  && \
           tar zcvf kube$1-arm64.tar.gz kube && mv kube$1-arm64.tar.gz /tmp/kube$1-arm64.tar.gz"

# run init test
sh huawei/test.sh $1  $FIP


remotecmd "cd /root/arm64-test/ && sh huawei/oss.sh $1 $2"

mycli hw delete --id $ID --eip

echo "mycli hw delete --id $ID --eip"
curl "https://oapi.dingtalk.com/robot/send?access_token=${DD_TOKEN}" \
   -H "Content-Type: application/json" \
   -d "{\"msgtype\":\"link\",\"link\":{\"text\":\"kubernetes-arm64自动发布版本v$1\",\"title\":\"kube$1-arm64 发布成功\",\"picUrl\":\"\",\"messageUrl\":\"https://sealyun.com\"}}"
