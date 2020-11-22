#!/bin/bash
cd /tmp
md5=$(md5sum /tmp/kube$1-arm64.tar.gz | awk  '{print $1}')
echo $md5 && ossutil64 -c /tmp/oss-config cp /tmp/kube$1-arm64.tar.gz oss://fyhy/arm64/$md5-$1/kube$1-arm64.tar.gz
echo "oss://fyhy/arm64/$md5-$1/kube$1-arm64.tar.gz"

sed -i s/VERSION/$1/g production.yml

echo "marketctl create -f production.yml --token $MARKET_API_TOEKN"
