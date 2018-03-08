# mysql 双主双从搭建

https://www.cnblogs.com/Aiapple/p/5792939.html

主从同步复制原理:

复制分成3步:
1. master将改变记录到二进制日志(binary log)中（这些记录叫做二进制日志事件，binary log events）；
2. slave将master的binary log events拷贝到它的中继日志(relay log)；
3. slave重做中继日志中的事件，将改变反映它自己的数据。

 主从复制会启动3个线程:
 slave端2个: I/O线程  SQL线程
 master端1个: log dump线程

 I/O线程去请求主库 的binlog，并将得到的binlog日志写到relay log（中继日志） 文件中；
 主库会生成一个 log dump 线程，用来给从库 i/o线程传binlog；
 SQL 线程，会读取relay log文件中的日志，并解析成具体操作，来实现主从的操作一致，而最终数据一致； 

主主复制: 其实就是互为主从.

## 主主搭建

M1： 192.168.200.162
M2： 192.168.200.163
设置主主首先设置主从

---------------------------

M1主 M2从

M1：编辑 /etc/my.cnf

```bash
server-id=100
basedir=/usr/local/mysql
datadir=/data/mysql
port=3306
pid-file=/data/mysql/mysql.pid
log-error=/data/mysql/m1.error

log-bin=/data/mysql/m1-bin
//主数据库必须开启这项让从写到从的relay log中
```

M2:编辑 /etc/my.cnf

```bash
server-id=101
basedir=/usr/local/mysql
datadir=/data/mysql 
port=3306
pid-file=/data/mysql/mysql.pid
log-error=/data/mysql/m2.error

//log-bin 从的logbin可以不开启
```
* 设置mysql登入密码:/usr/local/mysql/bin/mysqladmin -uroot password '123456' //之前设置过了就不用设置 
* M1 M2 启动服务 /etc/init.d/mysqld start
* 在M1 服务器内创建一个账户，该账户是给从服务器登入的：
  grant replication slave on *.* to 'repl'@'%' identified by '123456';
 //这里用 %号后面可以给其他从账户登入，如果是生成环境最好做IP限制
  锁表:防止表在配置的时候数据更新造成起始数据不同步的情况； flush tables with read lock;
  查看bin-log信息用于 从服务器配置的参数:  show master status; 

* M2 数据库内: 
  stop slave; 
  //先停止运行从服务器同步 **这个时候停止，主服务器如果没有停止写入数据(read lock)，在恢复start slave前的时候，主服务器操作的动作都会被同步到从服务器**
  change master to master_host='192.168.200.162', master_user='repl', master_password='123456', master_log_file='m1-bin.000001', master_log_pos=460; # 设置从服务器参数 根据M1设置
   start slave;//开启从服务器功能
* M1 去掉锁表:unlock tables;
* 然后 创建表 并M1 查看 show master status; M2 查看 show slave status\G 和两个表 show databases查看是否同步
  //M2中有 数据可以看到连接主是否正常和 logbin同步的位置
  ```bash
   Slave_IO_State: Connecting to master
                  Master_Host: 192.168.200.162
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: m1-bin.000001
          Read_Master_Log_Pos: 460
               Relay_Log_File: mysql-relay-bin.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: m1-bin.000001
             Slave_IO_Running: Connecting
            Slave_SQL_Running: Yes
  ```

* 测试的时候一直同步不了 show slave status\G 显示登入账户error，查出是两台设备的防火墙和iptbales没关闭

同步后再反向做 再次配置

M1: /etc/my.cnf

```bash
server-id=100
basedir=/usr/local/mysql
datadir=/data/mysql
port=3306
pid-file=/data/mysql/mysql.pid
log-error=/data/mysql/m1.error

log-bin=/data/mysql/m1-bin
//增加
auto_increment_offset=1
auto_increment_increment=2
//offset为起始 自增序号和表中的 AUTO_INCREMENT 有关
//M1设置为奇数增长 防止两个表同时写可能造成 自增长ID相同写入失败
log-slave-updates=true
//打开relaylog更新主机的binlog的时候 也把更新的信息跟新到 自己的binlog中，让其他该主机的从机同步正常
replicate-ignore-db=mysql
replicate-ignore-db=information_schema 
//不更新的数据库 此项不填也可以
``` 

M2: my.cnf

```BASH
server-id=101
basedir=/usr/local/mysql
datadir=/data/mysql
port=3306
pid-file=/data/mysql/mysql.pid
log-error=/data/mysql/m2.error
log-bin=/data/mysql/m2-bin

auto_increment_offset=2
auto_increment_increment=2
log-slave-updates=true
//offset设置为2 自动加入的 值都是偶数

```

* 重启服务进入到 数据库内同样的方法在 
  M2中创建M1 slave登入的账户
  grant replication slave on *.* to 'repl1'@'%' identified by '123456';
  锁表:防止表在配置的时候数据更新造成起始数据不同步的情况； flush tables with read lock;
  查看bin-log信息用于 从服务器配置的参数:  show master status;

* M1: 登入账户
  stop slave；
  change master to master_host='192.168.200.163', master_user='repl1', master_password='123456', master_log_file='m2-bin.000001', master_log_pos=324; # 设置从服务器参数 根据M2设置
  start slave;
  M2 关闭锁表: unlock tables;
 
*  在M2 和 M1分别创建数据库 看是否会同步；

正常后 这两个主在分别做从的话 就是设置其他的从机 参数都按第一步配置从一样。

## 两主通过 keepalived 实现高可用

由于连接的原因:使用另外个网段的IP 设置VIP

M1: 192.168.200.162
M2: 192.168.200.163
vip: 192.168.201.164

* 两台机器进行安装keepalived: yum -y install keepalived
* 编辑 M1 上的配置文件: vim /etc/keepalived/keepalived.conf

```BASH 

global_defs {
#定义接收邮件
   notification_email {
     cs@ceshizu5.com
   }
#定义发送邮件
   notification_email_from cs@cszu5.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}
#定义监控ngnix服务的脚本
vrrp_script chk_mysql {
    script "/usr/local/sbin/check_mysql.sh"
    interval 3
}
#自定义master 角色名 监听哇咔 权重 以及密码 VIP 加载上面的定义的监控脚本
vrrp_instance VI_1 {
    state MASTER
    interface ens192
    virtual_router_id 51 
# 此项同一组 高可用配置应该是一样的 取值在0-255之间，用来区分多个instance的VRRP组播
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.201.164
    }
    track_script {
        chk_mysql
    }
}

```

* 编辑M1上的监控脚本: /usr/local/sbin/check_mysql.sh

```BASH
#!/bin/bash
#时间变量，用于记录日志
d=`date --date today +%Y%m%d_%H:%M:%S`
#计算nginx进程数量
n=`ps -C mysqld --no-heading|wc -l`
# -C 用来指定所执行命令的名称 --no-heading不打印所打印的头部
#echo "file is running==========" >> /var/log/messages
#echo $? >> /tmp/messages
#echo `who am i`xxx >> /tmp/messages
#如果还为0，说明mysqld已经关闭异常，此时需要关闭keepalived，返回值1给 keepalived
function test() 
{
    if [ $n -eq "0" ]; then
        n2=`ps -C mysqld --no-heading|wc -l`
        sleep 2
        if [ $n2 -eq "0"  ]; then
#                echo "over" >> /tmp/messages
                echo "$d nginx down,keepalived will stop" >> /tmp/messages
#                systemctl stop keepalived #这些命令都执行不了，执行没有权限
            return 1
        fi
    fi
}

test 

```

* 编辑M2 上的配置文件: vim /etc/keepalived/keepalived.conf

```BASH

global_defs {
   notification_email {
     cs@ceshizu5.com
   }
   notification_email_from cs@ceshizu5.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}
vrrp_script chk_mysql {
    script "/usr/local/sbin/check_mysql.sh"
    interval 3
}
vrrp_instance VI_1 {
    state BACKUP     # 不一样的地方
    interface ens192
    virtual_router_id 51  #不一样的地方设置编号
    priority 90            #设置级别
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.201.164
    }
    track_script {
        chk_mysql
    }
}

```

* M2 上的mysql监控脚本:/usr/local/sbin/check_mysql.sh 和M1的监控脚本一样

* 然后在 M1 M2 添加 201 网段的 网络:
  route add -net 192.168.201.0 netmask 255.255.255.0 dev ens192
* 然后在其他主机上访问 其他主机必须有201网段的IP
* 测试其他主机访问不了: 用户登入不了 修改登入用户的权限或者设置一个测试用户 比如 M1 M2中创建测试用户
 因为有同步的作用，所以在M1中创建 用户test
 创建keepalived 数据库用来登入测试: create database keepalived;
 创建登入该数据库的用户:grant all privileges on keepalived.* to test@"%" identified by '123456';
 然后须要运行刷新权限的命令：flush privileges;
 查看创建的用户:show grants for test;
 然后在其他主机登入。

## 测试高可用

* 两台机器都运行keepalived服务 service keepalived start //开启该服务的时候记得把防火墙关了setenforce 0
* * 先确定好两台机器上nginx差异，比如可以通过curl -I 来查看nginx版本
* * 测试1：关闭master上的nginx服务
* * 测试2：在master上增加iptabls规则 
* * iptables -I OUTPUT -p vrrp -j DROP
* * 测试3：关闭master上的keepalived服务
* * 测试4：启动master上的keepalived服务
* * ip addr 查看 vip:201.164
* 
