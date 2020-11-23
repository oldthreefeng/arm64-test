#!/bin/bash

## 创建新加坡2核4g的鲲鹏服务器. 初始镜像为 centos7.6
mycli hw create -c 1 --eip --keyName release >  InstanceId.json

cat InstanceId.json

ID=$(jq -r '.serverIds[0]' < InstanceId.json)
## wait to bind fip and ssh start
echo "wait to bind fip and ssh start"
sleep 180s
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
           wget https://download.docker.com/linux/static/stable/aarch64/docker-19.03.12.tgz && \
           cp  docker-19.03.12.tgz kube/docker/docker.tgz && \
           tar zxvf kubernetes-server-linux-arm64.tar.gz && \
           cd kube && \
           cp ../kubernetes/server/bin/kubectl bin/ && \
           cp ../kubernetes/server/bin/kubelet bin/ && \
           cp ../kubernetes/server/bin/kubeadm bin/ && \
           sed s/k8s_version/$1/g -i conf/kubeadm.yaml && \
           cd shell && sh init.sh && \
           rm -rf /etc/docker/daemon.json && systemctl restart docker && \
           sh master.sh && \
           docker pull fanux/lvscare && \
           cp /usr/sbin/conntrack ../bin/ && \
           cd ../.. && sleep 360 && docker images && \
           sh save.sh && \
           tar zcvf kube$1-arm64.tar.gz kube && mv kube$1-arm64.tar.gz /tmp/kube$1-arm64.tar.gz"

# run init test
sh huawei/test.sh $1  $FIP


echo "release package, need remote server passwd, WARN will pending"
remotecmd "cd /tmp/ && wget http://gosspublic.alicdn.com/ossutil/1.6.19/ossutilarm64  && chmod 755 ossutilarm64 && \
           mv ossutilarm64 /usr/sbin/ossutil64 && \
           echo ${OSS_CONFIG} | base64 -d >  /tmp/oss-config "
remotecmd "cd /root/arm64-test/ && sh huawei/oss.sh $1 $2"

#mycli --passwd $2 --host store.lameleg.com --cmd "sh release-k8s.sh $1 $FIP"

#echo "release instance"
#sleep 20
mycli hw delete --id $ID --eip
echo "mycli hw delete --id $ID --eip"
