#FTP搭建
环境：
centos版本：
```
[root@xujb01 exmple]# cat /proc/version
Linux version 3.10.0-693.5.2.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC) ) #1 SMP Fri Oct 20 20:32:50 UTC 2017
```
linux 版本信息：
```
[root@xujb01 exmple]# lsb_release -a
LSB Version:	:core-4.1-amd64:core-4.1-noarch:cxx-4.1-amd64:cxx-4.1-noarch:desktop-4.1-amd64:desktop-4.1-noarch:languages-4.1-amd64:languages-4.1-noarch:printing-4.1-amd64:printing-4.1-noarch
Distributor ID:	CentOS
Description:	CentOS Linux release 7.4.1708 (Core)
Release:	7.4.1708
Codename:	Core
```
编辑/etc/vsftpd/vsftpd.conf
```
#listen_ipv6=YES

listen=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES



# 用户家目录为FTP目录
#chroot_local_user=YES   *开启这个参数不知道为什么会开启服务失败所以就用下面的指定目录*
#chroot_list_enable=YES

syslog_enable=YES
local_root=/tmp/ftp 指定目录
# anon_root=/tmp/ftp  匿名用户设置目录
anonymous_enable=NO
# 取消匿名登入
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
xferlog_std_format=YES
connect_from_port_20=YES
```
创建用户：useradd -M -s /usr/sbin/nologin ftptest   # `-M` 不创建家目录 `-s` 指定shell
给用户加密码： passwd ftptest
把指定的shell加入到ftp允许shell的文件里/etc/shells	
```

ot@xujb01 exmple]# cat /etc/shells
/bin/sh
/bin/bash
/sbin/nologin
/usr/bin/sh
/usr/bin/bash
/usr/sbin/nologin

```
此时在电脑端连接ftp服务器始终连不上：
* 关闭selnux    getenforce;setenforce 0
* 关闭iptables  iptables -L;iptables -F;iptables -L #暂时清除iptables的规则

此时可以连接服务器
可能此时对服务内的文件不能读写，可以修改下ftp文件夹的属性：chmod 777 ftp

