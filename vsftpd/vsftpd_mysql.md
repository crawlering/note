vsftp 利用mysql 验证虚拟账户

回复收藏
 分享 
账户 验证 虚拟 vsftp mysql 资料分享
1  安装vsftpd

（1） yum install -y  vsftpd

（2）编辑vsftpd.conf

内容如下

listen=YES

connect_from_port_20=YES

pasv_enable=YES

tcp_wrappers=YES

local_enable=YES

chroot_local_user=yes

anonymous_enable=NO

guest_enable=YES

guest_username=vsftpdguest

user_config_dir=/etc/vsftpd/vsftpd_user_conf

pam_service_name=/etc/pam.d/vsftpd

dirmessage_enable=YES

idle_session_timeout=600

check_shell=NO

（3）创建一个虚拟用户映射系统用户    

useradd –s /sbin/nologin vsftpdguest

2 安装 mysql

具体步骤参考 http://www.lishiming.net/thread-7-1-2.html

3 安装 pam-mysql

wget  https://nchc.dl.sourceforge.net/project/pam-mysql/pam-mysql/0.7RC1/pam_mysql-0.7RC1.tar.gz

tar zxvf  pam_mysql-0.7RC1.tar.gz

cd pam_mysql-0.7RC1

./configure --with-mysql=/usr/local/mysql --with-pam=/usr --with-pam-mods-dir=/usr/lib

make && make install

4 创建vsftp 库和相关的表并授权

>create database vsftp;

>use vsftp ;

>create table users ( name char(16) binary ,passwd char(125) binary ) ;

>insert into users (name,passwd) values ('test001',password('123456'));

>insert into users (name,passwd) values ('test002',password('234567'));

>grant select on vsftp.users to vsftpdguest@localhost identified by 'vsftpdguest';

5 创建虚拟账户的配置文件

mkdir /etc/vsftpd/vsftpd_user_conf 

cd  /etc/vsftpd/vsftpd_user_conf

vim test001

内容如下

local_root=/ftp/        

write_enable=YES

virtual_use_local_privs=YES

chmod_enable=YES

6  编辑验证文件

vim  /etc/pam.d/vsftpd

内容如下

#%PAM-1.0

auth required /usr/lib/pam_mysql.so user=vsftpdguest passwd=vsftpdguest host=localhost db=vsftp table=users usercolumn=name passwdcolumn=passwd crypt=2

account required /usr/lib/pam_mysql.so user=vsftpdguest passwd=vsftpdguest host=localhost db=vsftp table=users usercolumn=name passwdcolumn=passwd crypt=2

如果不想使用mysql也可以使用文件的形式来搞虚拟账号，请参考  Centos5.5 配置vsftpd 虚拟账号



**最后功能没有实现 一直显示  pam_mysql - MySQL error (Can't connect to MySQL server on 'xujb01' (13))， 密码是正确的**

