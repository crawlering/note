# mysql 主从配置

*mysql 主从叫做Replication/AB 复制。*

* mysql 主从是 基于binlog，主上必须开启 binlog 才能进行主从


主从实施三个过程：

1、主 将操作记录到binlog 里 #查看/usr/local/mysql/bin/mysqlbinlog --no-defaults  mysql-bin.000004
2、从服务器 同步 主服务器中的binlog 到  relaylog
3、从服务器 根据relaylog里面的sql语句 按顺序执行

## 主服务器配置

* 安装mysql http://www.cnblogs.com/wanderingfish/p/8041145.html
* mysql 初次使用设置密码 mysqladmin -uroot password '123456'
* 备份测试数据库 mysql -uroot -h127.0.0.1 mysql -p> /tmp/mysql.sql
                 mysql -uroot -h127.0.0.1 -e "create database xujb" -p
		 mysql -uroot -h127.0.0.1 xujb < /tmp/mysql.sql
* 创建主从同步 从服务器用户: grant replication slave on *.* to 'repl'@'192.168.31.21' identified by '123456';
* 锁表:防止表在配置的时候数据更新造成起始数据不同步的情况； flush tables with read lock;
* 查看bin-log信息用于 从服务器配置的参数:  show master status;


*Position 相当于 mysqlbinlog mysql-bin.000004 中的 ‘# at 538’ *

## 从服务器配置

* 安装mysql http://www.cnblogs.com/wanderingfish/p/8041145.html
* mysql 初次使用设置密码 mysqladmin -uroot password '123456'
* 创建初始数据库和主服务器相同:mysql -uroot -h127.0.0.1 -e "create database xujb" -p
                               mysql -uroot -h127.0.0.1 xujb < /tmp/mysql.sql

* stop slave; #先停止运行从服务器同步 **这个时候停止，主服务器如果没有停止写入数据(read lock)，在恢复start slave前的时候，主服务器操作的动作都会被同步到从服务器**
* change master to master_host='192.168.31.20', master_user='repl', master_password='123456', master_log_file='mysql-bin.000013', master_log_pos=2682 # 设置从服务器参数
* start slave # 从服务器开始同步主服务

* 打开主服务器的锁表: unlock tables;


### 查看主从同步是否正常

 从上执行mysql -uroot
 show slave stauts\G
 看是否有
 Slave_IO_Running: Yes
 Slave_SQL_Running: Yes
 还需关注
 Seconds_Behind_Master: 0  //为主从延迟的时间
 Last_IO_Errno: 0
 Last_IO_Error:
 Last_SQL_Errno: 0
 Last_SQL_Error:


### 测试主从

主上 mysql -uroot aming  
 select count(*) from db;
 truncate table db;
 到从上 mysql -uroot aming
 select count(*) from db;
 主上继续drop table db;
 从上查看db表

### 主从配置参数

限定主从 数据库 表 

 主服务器上
 binlog-do-db=      //仅同步指定的库
 binlog-ignore-db= //忽略指定库
 从服务器上
 replicate_do_db=
 replicate_ignore_db=
 replicate_do_table=
 replicate_ignore_table=
 replicate_wild_do_table=   //如aming.%, 支持通配符% 
 replicate_wild_ignore_table=

例子: 
从服务器:
my.cnf:
replicate_ignore_table=xujb.test08 # 禁止xujb.test08 表数据同步 其他的都可以同步

replicate_do_table=xujb.test07 # 至同步 xujb.test07
