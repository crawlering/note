# nfs 挂载

作用:
NFS服务器用作 web端 zrlog discuz dedecms 存储静态文件

以discuz挂载为例:data/attachment

服务器:

* yum install -y nfs-utils rpcbind #安装 nfs-utils 会自动安装 rpcbind
* vim /etc/exports //加入如下内容
    /home/nfsdir 192.168.200.0/24(rw,sync,no_root_squash)


* 保存配置文件后，执行如下准备操作
  mkdir /home/nfsdir
  chmod 777 /home/nfsdir
  systemctl start rpcbind 
  systemctl start nfs 
  systemctl enable rpcbind 
  systemctl enable nfs 
* 拷贝客户端的 data/attachment 到服务 /home/nfsdir/discuz中
 
客户端:

* yum install -y nfs-utils
* showmount -e 192.168.200.165 //该ip为NFS服务端ip
* 编辑/etc/fstab 在末尾加入
  192.168.200.165:/home/nfsdir/  /data/nfsdir	 nfs	defaults 0 0
* mount -t nfs 192.168.200.165:/home/nfsdir
* df -h
* 然后在把nfsdir中的discuz目录做软连接: ln -s /data/nfsdir/discuz /data/www/discuz/attachment

* 创建文件测试，访问discuz发表图片查看

