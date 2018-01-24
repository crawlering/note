# FTP 介绍

FTP是File Transfer Protocol（文件传输协议，简称文传协议）的英文简称，用于在Internet上控制文件的双向传输。
FTP的主要作用就是让用户连接一个远程计算机（这些计算机上运行着FTP服务器程序），并查看远程计算机中的文件，然后把文件从远程计算机复制到本地计算机，或把本地计算机的文件传送到远程计算机。
小公司用的多，大企业不用FTP，因为不安全


# vsftpd 搭建 ftp 服务

* yum install -y vsftpd
* useradd -s /sbin/nologin virftp

## 生成密码文件，以及创建配置 用户配置文件 目录

* vim /etc/vsftpd/vsftpd_login //内容如下,奇数行为用户名，偶数行为密码，多个用户就写多行
    testuser1
    aminglinux
* chmod 600 /etc/vsftpd/vsftpd_login
* db_load -T -t hash -f /etc/vsftpd/vsftpd_login /etc/vsftpd/vsftpd_login.db
* mkdir /etc/vsftpd/vsftpd_user_conf   #后面服务定义该文件为 用户配置文件
* cd /etc/vsftpd/vsftpd_user_conf  

* vim testuser1 //加入如下内容

```BASH
local_root=/home/virftp/testuser1  #定义用户文件
anonymous_enable=NO
write_enable=YES
local_umask=022
anon_upload_enable=NO
anon_mkdir_write_enable=NO
idle_session_timeout=600
data_connection_timeout=120
max_clients=10
```

## 创建家目录 

* mkdir /home/virftp/testuser1
* touch /home/virftp/testuser1/test.txt
* chown -R virftp:virftp /home/virftp
* vim /etc/pam.d/vsftpd //在最前面加上
    auth sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_login
    account sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/vsftpd_login

## vsftpd 配置文件

* vim /etc/vsftpd/vsftpd.conf

```BASH 
将anonymous_enable=YES 改为 anonymous_enable=NO
 将#anon_upload_enable=YES 改为 anon_upload_enable=NO 
 将#anon_mkdir_write_enable=YES 改为 anon_mkdir_write_enable=NO
  再增加如下内容
chroot_local_user=YES
guest_enable=YES
guest_username=virftp
virtual_use_local_privs=YES
user_config_dir=/etc/vsftpd/vsftpd_user_conf  #定义用户配置文件
allow_writeable_chroot=YES
 systemctl start vsftpd //启动vsftpd服务
```

## 测试FTP 

* yum install -y lftp
* lftp testuser1@192.168.31.20
  执行命令ls，看是否正常输出
  若不正常查看日志/var/log/messages和/var/log/secure 
  windows下安装filezilla客户端软件，进行测试

* 第一次在linux上测试 lftp上显示不能打开文件目录
* 然后在windows cmd中 ftp 192.168.31.20 后 ls 显示:

```BASH
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
226 Transfer done (but failed to open directory).
```
* 可以看到 用户登入正常，文件打不开是权限的问题，然后看文件权限也对，但是在创建用户virftp 的时候是先创建
   用户文件夹然后执行创建用户生成目录的， 所以删除用户 和 目录，重新添加用户和目录，后正常


# xshell 实现ftp

* 选择窗口-传输新建文件 弹出对话框 选择下载xftp 是windows 视图型传输文件
   选择取消，xshell 也会进入 命令行 ftp模式，两种模式 不依赖 linux系统安装 vsftpd等与否，
   是xshell 自身带的，操作目录是 命令模式进入的目录


# pure-ftpd 搭建 ftp服务

* yum install -y epel-release
* yum install -y pure-ftpd
* vim /etc/pure-ftpd/pure-ftpd.conf//找到pureftpd.pdb这行，把行首的#删除
* systemctl stop vsftpd
* systemctl start pure-ftpd
* mkdir /data/ftp
* useradd -u 1010 pure-ftp  #创建 服务用户
* chown -R pure-ftp:pure-ftp /data/ftp
* pure-pw useradd ftp_usera -u pure-ftp  -d /data/ftp #创建登入用户 和 共享目录 *密码文件加密在/etc/pure-ftpd/pureftpd.passwd*
* pure-pw mkdb
* pure-pw list[userdel][usermod][passwd]


