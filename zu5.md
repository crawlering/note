

mysql安装

1、下载mysql源码包

```
# yum -y install wget
# cd /usr/local/src
# wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz

```

2、解压缩包,移动目录到/usr/local/下并改名为mysql。

```
# tar zxvf mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
# mv mysql-5.6.35-linux-glibc2.5-x86_64 /usr/local/mysql
# cd /usr/local/mysql

```

3、创建mysql用户及目录，用来存放mysql数据

```
# useradd mysql
# mkdir -p /data/mysql
# chown -R mysql:mysql /data/mysql

```

4、初始化mysql

```
安装缺少的包：

yum install -y perl-Data-Dumper
yum install -y libaio
yum install -y numactl
yum install -y libaio-devel
yum install -y openssl-devel
yum install -y perl perl-devel

# ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
# echo $?

```

5、修改配置文件 

```
# vim /etc/my.cnf

```
修改如下图：
![](https://i.imgur.com/PQdIzO1.png)


6、复制启动脚本到/etc/init.d目录下并改名mysqld

```
# cp support-files/mysql.server /etc/init.d/mysqld
# vi /etc/init.d/mysqld   //编辑启动脚本

定义：basedir和datadir 

basedir=/usr/local/mysql  
datadir=/data/mysql

```

7、添加mysql开机自动启动

```
# chkconfig --add mysqld  //添加开机启动
# chkconfig --add mysqld  //查看已添加开机

```

8、启动mysql，查看mysql启动服务

```
# /etc/init.d/mysqld start 或者 service mysqld start
# ps aux |grep mysql //查看进程
# netstat -lntp  //查看监听端口3306

```


搭建双主双从


配置：

192.168.200.169    db-master1     server-id = 101
192.168.200.170    db-master2     server-id = 102
192.168.200.171    db-slave1      server-id = 103
192.168.200.172    db-slave2      server-id = 104


master：

1、修改my.cnf配置文件

```
# vi /etc/my.cnf

增加如下配置内容：

server-id=101
log-bin=master1


# /etc/init.d/mysqld restart   //重启mysql


[root@localhost mysql]# cd /data/mysql/
[root@localhost mysql]# ls -lt
总用量 110636
-rw-rw----. 1 mysql mysql 50331648 3月   7 09:09 ib_logfile0
-rw-rw----. 1 mysql mysql 12582912 3月   7 09:09 ibdata1
-rw-rw----. 1 mysql mysql    14978 3月   7 09:09 localhost.localdomain.err
-rw-rw----. 1 mysql mysql        6 3月   7 09:09 localhost.localdomain.pid
-rw-rw----. 1 mysql mysql      120 3月   7 09:09 master1.000002
-rw-rw----. 1 mysql mysql       34 3月   7 09:09 master1.index
-rw-rw----. 1 mysql mysql      285 3月   7 09:09 master1.000001
drwx------. 2 mysql mysql     4096 3月   6 13:45 mysql
drwx------. 2 mysql mysql     4096 3月   6 13:45 performance_schema
drwx------. 2 mysql mysql        6 3月   6 13:45 test
-rw-rw----. 1 mysql mysql       56 3月   6 13:44 auto.cnf
-rw-rw----. 1 mysql mysql 50331648 3月   6 13:44 ib_logfile1

```

2、创建用作主从相互同步数据的用户

```

#centos7默认不能使用mysql，需要把/usr/local/mysql/bin添加到环境变量里。

#export PATH=$PATH:/usr/local/mysql/bin/  //加入PATH,但重启后会失效

[root@localhost ~]# vi /etc/profile  //添加后重启会开机加载

把以下命令增加到最后一行：

export PATH=$PATH:/usr/local/mysql/bin/

#设置mysql的root密码
[root@localhost ~]# mysqladmin -uroot password 'qaz123456'


#登录mysql
[root@localhost ~]# mysql -uroot -pqaz123456

#给服务器建立授权并设备同步账户
mysql> grant replication slave on *.* to 'repl'@'192.168.200.171' identified by 'qaz123';
Query OK, 0 rows affected (0.01 sec)

mysql> start master;    #启动Master

mysql> show master status;
+----------------+----------+--------------+------------------+-------------------+
| File           | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+----------------+----------+--------------+------------------+-------------------+
| master1.000002 |      332 |              |                  |                   |
+----------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

```

slave:

1、修改my.cnf配置文件

```
[root@localhost ~]# vi /etc/my.cnf

增加配置如下内容：

server-id=103   //设置成和master（主）不一样的数字，若一样会导致后面的操作不成功

#重启mysql
[root@localhost ~]# /etc/init.d/mysqld restart


#设置mysql密码
[root@localhost ~]# mysqladmin -uroot password 'qaz123456'

````

2、实现主从

```
#登录mysql
[root@localhost ~]# mysql -uroot -pqaz123456

#实现主从配置
mysql> change master to master_host='192.168.200.169', master_user='repl', master_password='qaz123', master_log_file='master1.000002', master_log_pos=332;
Query OK, 0 rows affected, 2 warnings (0.01 sec)

#启动从服务器复制功能
mysql> start slave;
Query OK, 0 rows affected (0.00 sec)

#查看启动状态
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.200.169
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master1.000002
          Read_Master_Log_Pos: 332
               Relay_Log_File: localhost-relay-bin.000002
                Relay_Log_Pos: 281
        Relay_Master_Log_File: master1.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes     这两个状态必须Yes

```

![](https://i.imgur.com/reLijmQ.png)


备注：主从搭建好了，192.168.200.170和192.168.200.172搭建过程省略。



开始搭建双主 192.168.200.169和192.168.200.170 （Master>Master）


1、打开服务器修改my.cnf配置文件


（192.168.200.169）

增加如下内容：
```
auto_increment_offset= 1
auto_increment_increment= 2     #奇数ID
log-slave-updates=true         #将复制事件写入binlog,一台服务器既做主库又做从库此选项必须要开启
replicate-ignore-db=mysql      #忽略不同步主从的数据库
replicate-ignore-db=information_schema
replicate-ignore-db=performance_schema

```

（192.168.200.170）


增加如下内容：
```
auto_increment_offset = 2
auto_increment_increment = 2   #偶数ID
log-slave-updates=true
replicate-ignore-db=mysql
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema

```


2、添加授权用户（两台都得添加）

192.168.200.169

```
mysql> grant replication slave on *.* to 'repl'@'192.168.200.169' identified by 'qaz123';
Query OK, 0 rows affected (0.01 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.02 sec)

```


192.168.200.170

```
mysql> grant replication slave on *.* to 'repl'@'192.168.200.170' identified by 'qaz123';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

```

3、查看两台主库的状态

192.168.200.169

```
mysql> show master status;
+----------------+----------+--------------+------------------+-------------------+
| File           | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+----------------+----------+--------------+------------------+-------------------+
| master1.000002 |      914 |              |                  |                   |
+----------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

```

192.168.200.170

```
mysql> show master status;
+----------------+----------+--------------+------------------+-------------------+
| File           | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+----------------+----------+--------------+------------------+-------------------+
| master2.000001 |     1056 |              |                  |                   |
+----------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

```

4、配置同步信息

```
#创建同步用户
mysql> grant replication slave on *.* to 'repl'@'%' identified by 'qaz123';
Query OK, 0 rows affected (0.00 sec)


mysql> change master to master_host='192.168.200.170', master_port=3306, master_user='repl', master_password='qaz123', master_log_file='master2.000001', master_log_pos=1056;
Query OK, 0 rows affected, 2 warnings (0.01 sec)

mysql> start slave;
Query OK, 0 rows affected (0.01 sec)


mysql> stop slave;      #如果change master报错，重新操作时需要关闭slave再操作
Query OK, 0 rows affected (0.00 sec)

mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.200.170
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master2.000001
          Read_Master_Log_Pos: 1268
               Relay_Log_File: localhost-relay-bin.000002
                Relay_Log_Pos: 493
        Relay_Master_Log_File: master2.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes


```

```
mysql> change master to master_host='192.168.200.169',master_port=3306,master_user='repl',master_password='qaz123',master_log_file='master1.000002',master_log_pos=914;
Query OK, 0 rows affected, 2 warnings (0.01 sec)

mysql> start slave;
Query OK, 0 rows affected (0.00 sec)

mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.200.169
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: master1.000003
          Read_Master_Log_Pos: 535
               Relay_Log_File: localhost-relay-bin.000003
                Relay_Log_Pos: 484
        Relay_Master_Log_File: master1.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes

```

5、测试创建一个数据库  4个数据库同步则完成


#创建库
mysql> create database test1;
Query OK, 1 row affected (0.00 sec)

#查看库
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
| test1              |
+--------------------+
5 rows in set (0.00 sec)

#创建表
mysql> use test1; create table t1(`id` int(4)), `name` char(40));
Database changed
Query OK, 0 rows affected (0.02 sec)

#查询表
mysql> show create table t1\G; 
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(4) DEFAULT NULL,
  `name` char(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1
1 row in set (0.00 sec)

ERROR: 
No query specified

