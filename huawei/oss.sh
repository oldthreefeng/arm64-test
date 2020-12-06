#!/bin/bash
cd /tmp
md5=$(md5sum /tmp/kube$1-arm64.tar.gz | awk  '{print $1}')
echo $md5
#echo $md5 && ossutil64 -c /tmp/oss-config cp /tmp/kube$1-arm64.tar.gz oss://fyhy/arm64/$md5-$1/kube$1-arm64.tar.gz
#echo "oss://fyhy/arm64/$md5-$1/kube$1-arm64.tar.gz"

wget https://sealyun-market.oss-accelerate.aliyuncs.com/marketctl/v1.0.2/linux_arm64/marketctl
chmod a+x marketctl
cat > marketctl_$1.yaml << EOF
market:
  body:
    spec:
      name: v$1
      price: 100
      product:
        class: cloud_kernel
        productName: kubernetes-arm64
      url: /tmp/kube$1-arm64.tar.gz
    status:
      productVersionStatus: ONLINE
  kind: productVersion
EOF

./marketctl create -f marketctl_$1.yaml --token $2
