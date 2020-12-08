#!/bin/bash
# clientip is where to run sealos server FIP
# sh test.sh 1.15.4 clientip

echo "create 4 vms"
mycli hw create -c 1 --eip >  InstanceId.json
cat InstanceId.json
ID0=$(jq -r '.serverIds[0]' < InstanceId.json)

mycli hw create -c 3  > InstanceId.json

cat InstanceId.json
ID1=$(jq -r '.serverIds[0]' < InstanceId.json)
ID2=$(jq -r '.serverIds[1]' < InstanceId.json)
ID3=$(jq -r '.serverIds[2]' < InstanceId.json)

echo "sleep 140s wait for IP"
sleep 140 # wait for IP

mycli hw list --id $ID0 > info.json
master0=$(jq -r '.addresses."a55545d8-a4cb-436d-a8ec-45c66aff725c"[0].addr'  < info.json)
master0FIP=$(jq -r '.addresses."a55545d8-a4cb-436d-a8ec-45c66aff725c"[1].addr'  < info.json)

mycli hw list --id $ID1 > info.json
master1=$(jq -r '.addresses."a55545d8-a4cb-436d-a8ec-45c66aff725c"[0].addr'  < info.json)

mycli hw list --id $ID2 > info.json
master2=$(jq -r '.addresses."a55545d8-a4cb-436d-a8ec-45c66aff725c"[0].addr'  < info.json)

mycli hw list --id $ID3 > info.json
node=$(jq -r '.addresses."a55545d8-a4cb-436d-a8ec-45c66aff725c"[0].addr'  < info.json)

echo "[CHECK] all nodes IP: $master0 $master1 $master2 $node"

echo "wait for sshd start"
sleep 100 # wait for sshd
# $2 is sealos clientip
alias remotecmd="mycli --pk ./release.pem --host $2 --cmd"

echo "mycli sealos command"
## github sealos assets[1] is arm64
SEALOS_URL=$(curl -LsSf https://api.github.com/repos/fanux/sealos/releases/latest | jq -r ".assets[1].browser_download_url")

remotecmd "wget -c $SEALOS_URL && chmod +x sealos-arm64 && mv sealos-arm64 /usr/bin/sealos "

remotecmd "sealos init --master $master0 --master $master1 --master $master2 \
    --node $node --passwd Louishong4168@123 --version v$1 --pkg-url /tmp/kube$1-arm64.tar.gz"
echo "sealos init --master $master0 --master $master1 --master $master2 \
    --node $node --passwd Louishong4168@123 --version v$1 --pkg-url /tmp/kube$1-arm64.tar.gz"

echo "[CHECK] wait for everything ok"
sleep 200
mycli --passwd "Louishong4168@123" --host $master0FIP --cmd "kubectl get node -owide && kubectl get pod --all-namespaces"

echo "[CHECK] mycli sealos clean command"
#remotecmd "sealos clean --master $master0 --master $master1 --master $master2 \
#    --node $node --passwd Fanux#123"

echo "release instance"

mycli hw delete --id $ID0 --eip
mycli hw delete --id $ID1
mycli hw delete --id $ID2
mycli hw delete --id $ID3
