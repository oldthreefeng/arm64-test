# cloud-kernel
kubernetes kernel offline packages, not linux kernal

# 理念
Dockerfile给进程打包，描述一个进程应该如何运行，而sealstore中的app就是用来描述应用在k8s集群中是如何运行的，都是打包的原理，而Dockerfile不会去关心应用副本数，负载均衡配置管理这些东西，而sealstore的app会

使用：
```
git tag 1.14.6
git push --tags
```


# 使用
```
$ export ak=xxxx  
$ export sk=xxxx
$ docker run --rm -e ak=$ak sk=$sk -it louisehong/mycli sh
# sh package.sh 1.15.4
```
