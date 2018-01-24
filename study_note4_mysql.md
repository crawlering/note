# mysql
十三周二次课（1月15日）
13.4 mysql用户管理
13.5 常用sql语句
13.6 mysql数据库备份恢复

扩展
SQL语句教程  http://blog.51cto.com/zt/206 

 
什么是事务？事务的特性有哪些？  http://blog.csdn.net/yenange/article/details/7556094 

根据binlog恢复指定时间段的数据   http://www.centoscn.com/mysql/2015/0204/4630.html 

mysql字符集调整  http://xjsunjie.blog.51cto.com/999372/1355013 

使用xtrabackup备份innodb引擎的数据库  innobackupex 备份 Xtrabackup 增量备份 http://zhangguangzhi.top/2017/08/23/innobackex%E5%B7%A5%E5%85%B7%E5%A4%87%E4%BB%BDmysql%E6%95%B0%E6%8D%AE/#%E4%B8%89%E3%80%81%E5%BC%80%E5%A7%8B%E6%81%A2%E5%A4%8Dmysql 

相关视频  
链接：http://pan.baidu.com/s/1miFpS9M 

 密码：86dx   
链接：http://pan.baidu.com/s/1o7GXBBW 

 密码：ue2f
-----------------------------------------------------------



===========================================================
十三周一次课（1月12日）
13.1 设置更改root密码
13.2 连接mysql
13.3 mysql常用命令
扩展 
mysql5.7 root密码更改   http://www.apelearn.com/bbs/thread-7289-1-1.html 

myisam 和innodb引擎对比  http://www.pureweber.com/article/myisam-vs-innodb/ 

mysql 配置详解： http://blog.linuxeye.com/379.html 

mysql调优： http://www.aminglinux.com/bbs/thread-5758-1-1.html 

同学分享的亲身mysql调优经历：  http://www.apelearn.com/bbs/thread-11281-1-1.html 

---------------------------------------------------------------------
## 更改root 密码
*  /usr/local/mysql/bin/mysql -uroot
  更改环境变量PATH，增加mysql绝对路径
  mysqladmin -uroot password '123456'
  mysql -uroot -p123456
  密码重置
* vi /etc/my.cnf//增加skip-grant
* 重启mysql服务 /etc/init.d/mysqld restart
*  mysql -uroot
> use mysql;
> update user set password=password('123456') where user='root';

## 连接 mysql


* mysql -uroot -p123456
* mysql -uroot -p123456 -h127.0.0.1 -P3306 #用ip访问
* mysql -uroot -p123456 -S/tmp/mysql.sock #用 sock访问
* mysql -uroot -p123456 -e “show databases” #"-e" 执行 mysql 命令

* mysql -uroot -h192.168.31.20 -P3306 -p #本机乃至远程主机访问数据库显示错误
      "ERROR 1130 (HY000): Host '192.168.31.21' is not allowed to connect to this MySQL server"
      原因:是用户root没有开通远程访问，只开同了本机访问，127.0.0.1 是可以访问的
      解决:
      1、创建test用户:
      GRANT ALL PRIVILEGES ON *.* TO test@localhost IDENTIFIED BY 'test' WITH GRANT OPTION; #开通主机访问
      GRANT ALL PRIVILEGES ON *.* TO test@"%" IDENTIFIED BY 'test' WITH GRANT OPTION; #带"%"为开通远程访问
     2、可能还需要开通 iptables 3306

## mysql 常用命令

* 查询库 show databases;
* 切换库 use mysql;
* 查看库里的表 show tables;
* 查看表里的字段 desc tb_name;
* 查看建表语句 show create table tb_name\G;
* 查看当前用户 select user();
* 查看当前使用的数据库 select databsase();
* 创建库 create database db1;
* 创建表 use db1; create table t1(`id` int(4), `name` char(40));
* 查看当前数据库版本 select version();
* 查看数据库状态 show status;
* 查看各参数 show variables; show variables like 'max_connect%';
* 修改参数 set global max_connect_errors=1000; #可以直接在 my.cnf 中设置
* 查看队列 show processlist; show full processlist;

* grant all on *.* to 'user1' identified by 'passwd';
* grant SELECT,UPDATE,INSERT on db1.* to 'user2'@'192.168.133.1' identified by 'passwd';
* grant all on db1.* to 'user3'@'%' identified by 'passwd';
* show grants;
* show grants for user2@192.168.133.1;


* "\G" 结尾 格式化表输出

## 常用 SQL 语句

* select count(*) from mysql.user; #MyISAM 会自动编号 innodb 不会自动编号所以此命令会消耗很大，不宜常用
* select * from mysql.db;
* select db from mysql.db;
* select db,user from mysql.db;
* select * from mysql.db where host like '192.168.%';
* insert into db1.t1 values (1, 'abc');
* update db1.t1 set name='aaa' where id=1;
* truncate table db1.t1;
* drop table db1.t1;
* drop database db1;

## MYSQL 数据库的备份和恢复

* 备份库  mysqldump -uroot -p123456 mysql > /tmp/mysql.sql
* 恢复库 mysql -uroot -p123456 mysql < /tmp/mysql.sql
* 备份表 mysqldump -uroot -p123456 mysql user > /tmp/user.sql
* 恢复表 mysql -uroot -p123456 mysql < /tmp/user.sql
* 备份所有库 mysqldump -uroot -p -A >/tmp/123.sql
* 只备份表结构 mysqldump -uroot -p123456 -d mysql > /tmp/mysql.sql

