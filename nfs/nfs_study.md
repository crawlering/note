
十三周三次课（1月16日）
14.1 NFS介绍
14.2 NFS服务端安装配置
14.3 NFS配置选项

-------------------------------

# NFS 介绍

NFS 是Network File System 的缩写
NFS 最早有Sun 公司开发 有 2 3 4三个版本，2、3由 Sun 起草开发， 4.0 开始由 Netapp 公司参与并主导开发，最新为 4.1 版本呢
NFS 数据传输协议 基于 RPC 协议(Remote Procedure Call)

NFS 为文件共享，与samba的区别:
* 速度稍快于 samba
* 用于 linux-linux 文件共享 而samba 可以基于 windows-linux 或者 linux-linux

NFS 通过RPC服务来进行通信(centos7是rpcbind 之前叫做 portmap ) 
client -->RPC服务(rpcbind) ----(RPC服务)-NFS服务-->NFS服务端
 
# NFS 服务端安装配置

* yum install -y nfs-utils rpcbind #安装 nfs-utils 会自动安装 rpcbind
* vim /etc/exports //加入如下内容
>  /home/nfstestdir 192.168.133.0/24(rw,sync,all_squash,anonuid=1000,anongid=1000)

* 保存配置文件后，执行如下准备操作
  mkdir /home/nfstestdir
  chmod 777 /home/nfstestdir
  systemctl start rpcbind 
  systemctl start nfs
  systemctl enable rpcbind 
  systemctl enable nfs

  

## NFS 配置 选项

* rw 读写
* ro 只读
* sync 同步模式, 内存数据实时写入磁盘
* async 非同步模式
* no_root_squash 客户端挂载NFS 共享目录后，ROOT 用户不受约束，权限很大
* root_squash 与上面选项相对，客户端上的ROOT 用户受到约束，被限定成某个普通用户
* all_squash 客户端上所有用户在使用NFS共享目录时都被限定为一个普通用户
* anonuid/anongid 和上面几个选项搭配使用，定义被限定用户的uid和gid


# NFS 客户端挂载

* yum install -y nfs-utils
* showmount -e 192.168.133.130 //该ip为NFS服务端ip
* mount -t nfs 192.168.133.130:/home/nfstestdir /mnt
* df -h
* touch /mnt/aminglinux.txt
* ls -l /mnt/aminglinux.txt //可以看到文件的属主和属组都为1000


# NFS exportfs 命令

常用选项:

* -a 全部挂载或者全部卸载
* -r 重新挂载
* -u 卸载某一个目录
* -v 显示共享目录

以下操作在服务端上

* vim /etc/exports //增加
* /tmp/ 192.168.133.0/24(rw,sync,no_root_squash)
* exportfs -arv //不用重启nfs服务，配置文件就会生效


# 客户端文件属主 数组 nobody

* NFS 4版本会有该问题
* 客户端挂载共享目录后，不管是root用户还是普通用户，创建新文件时属主、属组为nobody
* 客户端挂载时加上 -o nfsvers=3
* 客户端和服务端都需要
* vim /etc/idmapd.conf //
* 把“#Domain = local.domain.edu” 改为 “Domain = xxx.com” （这里的xxx.com,随意定义吧），然后再重启rpcidmapd服务

