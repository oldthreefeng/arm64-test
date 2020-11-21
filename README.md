# cloud-kernel
kubernetes kernel offline packages, not linux kernal

# 理念
Dockerfile给进程打包，描述一个进程应该如何运行，而sealstore中的app就是用来描述应用在k8s集群中是如何运行的，都是打包的原理，而Dockerfile不会去关心应用副本数，负载均衡配置管理这些东西，而sealstore的app会

使用：
```
git tag 1.14.6
git push --tags
```

# 虚拟机申请

把配置好的.aliyun/config.json进行base64加密，设置成drone的secret

# 使用
```
docker run --rm -v /Users/fanux/.aliyun:/root/.aliyun -it fanux/aliyun-cli sh
# sh package.sh 1.15.4 
```
