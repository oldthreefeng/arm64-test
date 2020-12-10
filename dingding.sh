#!/bin/bash
# Author:louisehong4168
# Blog:https://fenghong.tech
# Time:2020-12-10 12:09:52
# Name:b.sh
# Version:V1.0
# Description:This is a production script.
curl "https://oapi.dingtalk.com/robot/send?access_token=${DD_TOKEN}" \
   -H "Content-Type: application/json" \
   -d "{\"msgtype\":\"link\",\"link\":{\"text\":\"kubernetes-arm64自动发布版本v$1\",\"title\":\"kube$1-arm64 发布成功\",\"picUrl\":\"\",\"messageUrl\":\"https://sealyun.com\"}}"

