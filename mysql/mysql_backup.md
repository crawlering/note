# mysql 备份和恢复
 
--extra-lsndir: 脚本自动备份好用，增量备份的时候会而外备份一份到指定文件，每次如果备份的值不一样就可以更新，
这里的文件可以做--incremental-basedir 的值

* mysqldump
* mysqlbackup
* mysqlhotcopy
* xtrabackup/innobackupex

*首先介绍下锁表的概念*
锁表无非是让表 呈现一致性，假如A在买一个商品x的时候，x商品只有一个了，A买完，付款的时候，如果没有锁表操作，
用户B然后也进行同样的操作，同时付款x商品，x商品库存最后只剩-1件
如果存在锁表，当A拉取连接的时候，准备买x商品，此时进行锁表操作，B用户没有权限，在去付款，这样就不会存在上种情况

锁分为 读锁定和 写锁定

* 读锁定: lock tables table1 read;
          仅允许所有人读，不能写，更新table1 表，所有人分为2种，一个是自己(本线程)，一个是其他线程
	  本线程写的话，会提示"Table 'table1' was locked with a READ lock and can't be updated"
	  其他线程写的话 会被阻塞，等待界面会卡在那无任何输出(等持有线程解锁后就会自动写入)
	  而且解锁只能本线程进行解锁,解锁有两种方式。
	  一种在数据库使用 unlock tables 进行解锁
	  第二种是 exit，退出(结束)该线程，锁自动解开。
* 写锁定: lock tables table1 write;
          持有线程可以进行读写操作，其他线程 读写 都被阻塞，直到持有持有线程解锁
	  解锁: unlock tables 或者 exit 结束该线程


## mysqldump 备份

* 打开general_log: /etc/my.cnf
  general_log=on
  general_log_file=/var/log/mysql/mysqld.log

* mysqldump 的时候 会有 一个读锁操作: 备份的时候可以查看 general_log:
  
mysqldump 主要参数:

    --databases [databasename]: 后面接databasename,如果没接 --tables [table name]则备份整个库
    --tables [tablename] : 备份指定 table，
    --all-databases: 备份整个数据库
    --ignore-table： 指定某个表不备份，前面需要指定数据库: --databases db1或者使用 --all-databases

**备份的文件中有 写锁操作，写锁里面还包含了禁用索引，等数据写入完后在打开索引
ALTER TABLE tbl2 DISABLE KEYS;ALTER TABLE tbl2 ENABLE KEYS;
这些都是是为了快速恢复**

实例:
mysqldump -uroot -p --databases db1 --tables test1 > test1.bak
mysqldump -uroot -p --all-databases > db.bak
mysqldump -uroot -p --databases db1 --ignore-table test1 > notest1.bak

* --single-transaction : 不锁的方法，把备份的操作放在一个事务里

mysqldump的优势是可以查看或者编辑十分方便，它也可以灵活性的恢复之前的数据。它也不关心底层的存储引擎，既适用于支持事务的，也适用于不支持事务的表。不过它不能作为一个快速备份大量的数据或可伸缩的解决方案。如果数据库过大,即使备份步骤需要的时间不算太久,但有可能恢复数据的速度也会非常慢,因为它涉及的SQL语句插入磁盘I/O,创建索引等等。


## xtrabackup/innobackupex

Percona XtraBackup是一款基于MySQL的热备份的开源实用程序，它可以备份5.1到5.7版本上InnoDB,XtraDB,MyISAM存储引擎的表， Xtrabackup有两个主要的工具：xtrabackup、innobackupex 。

* xtrabackup 只能备份 InnoDB 和 XtraDB两种数据表，而不能备份MyISAM 数据表
* innobackupex 则封装了xtrabackup,同时备份处理 InnoDB 和 MyISAM,但是在处理MyISAM 需要加一个读锁

* wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.9/binary/redhat/7/x86_64/Percona-XtraBackup-2.4.9-ra467167cdd4-el7-x86_64-bundle.tar //下载最新支持mysql5.7的xtrabackup
* yum -y install perl-Digest-MD5
* rpm -ivh Percona-XtraBackup-2.4.9-ra467167cdd4-el7-x86_64-bundle.tar //rpm 安装


全备份:
	xtrabackup --backup --user=root --password=12345678 --host=127.0.0.1 --target-dir=/data/test

准备: xtrabackup --prepare --target-dir=/data/backup/base
恢复:    
       xtrabackup --copy-back --target-dir=/data/backup/base --datadir=/data/mysql 
       //并且 /data/mysql文件里需要清空
       或者把整个备份文件夹base的内容全部拷贝到 /data/mysql 里面 最后执行完记得: chown -R mysql:mysql /data/mysql
       或者 rsync -avrP /data/backup/base /var/lib/mysql/

并且参数可以在 my.cnf中配置


单个表恢复:
实验
* 先drop table test1;
* 此时模拟test1数据损坏，然后创建 test1相同格式的空表。
* create table test1(id int(10) not null primary key,xtext varchar(50));
* xtrabackup --prepare --export --target-dir=/data/backup/base/ --datadir=/data/mysql
  //可以看到 /data/backup/base/data3/ 目录下多了.exp .ibd .cfg 文件
* 然后在 mysql里执行:ALTER TABLE data3.test1 DISCARD TABLESPACE;
* 然后把 /data/backup/base/data3/ 所有文件拷贝到 /data/mysql/data3 下(相同文件可以覆盖也可以不覆盖其实只需要.ibd文件)
* 然后执行:ALTER TABLE data3.test1 IMPORT TABLESPACE;
* DESC test1; select * from test1; 可以看到表已经恢复
*表恢复可能库里面多了个.exp文件导致下次不能正常删除库，可以手动删除这个文件，之后可以正常删除库*


增量备份:

* xtrabackup --backup --target-dir=/data/backup/base  #进行一次全备份 // 后面可能需要加
  //--user=root --password=12345678 --host=127.0.0.1
* xtrabackup --backup --target-dir=/data/backup/incl1/ --incremental-basedir=/data/backup/base  #第一次增备份
* xtrabackup --backup --target-dir=/data/backup/incl2/ --incremental-basedir=/data/backup/incl1  #第二次增备份
  //--incremental-basedir 首尾相连

增量恢复:
1、先prepare 备份文件
* xtrabackup --prepare --apply-log-only --target-dir=/data/backup/base  #准备全备份文件
* xtrabackup --prepare --apply-log-only --target-dir=/data/backup/base --incremental-dir=/data/backup/incl1/ #准备第一次备份文件
* xtrabackup --prepare --target-dir=/data/backup/base --incremental-dir=/data/backup/incl2/ #准备增量2 备份文件 最后一次不不需要--apply-log-only参数

  //--apply-log-only参数：rolled back 回滚的需要 ，对未提交数据的回滚

2、备份恢复xtrabackup --copy-back --target-dir=/data/backup/base --datadir=/data/mysql 
   //进行备份恢复, 恢复之前需要把 /data/mysql 删除，

3、恢复之后，需要把/data/mysql文件改属主 chown -R mysql:mysql /data/mysql; 然后重启服务

 
# compress backup 压缩备份

备份:
* xtrabackup --backup --compress --compress-threads=4 --target-dir=/data/compressed/ --user=root --password=12345678 --host=127.0.0.1
* xtrabackup --backup --compress  --target-dir=/data/compressed/ --user=root --password=12345678    --host=127.0.0.1
    --compress: 开启压缩备份 --compress-threads=4: 开启四个线程


恢复:
1、先解压 压缩的备份文件:
* xtrabackup --decompress --target-dir=/data/compressed // --remove-original 加此参数会把压缩源文件删除.qp文件
                                                        //--parallel 加此参数开启多线程解压
  报错:缺少 qpress
  下载: wget http://www.quicklz.com/qpress-11-linux-x64.tar
        tar -xvf qpress-11-linux-x64.tar
	cp qpress /usr/bin
	然后重新解压
2、准备备份文件:
* xtrabackup --prepare --target-dir=/data/compressed/
3、恢复
* xtrabackup --copy-back --target-dir=/data/compressed --datadir=/data/mysql //需要删除datadir中的原先数据
* chown -R mysql:mysql /data/mysql
* /etc/init.d/mysqld restart

增量备份:

1、数据库里创建 数据库data1 表test1:  第一次全备份
   xtrabackup --backup --compress --target-dir=/data/compressed/base --user=root --password=123456 --host=127.0.0.1
2、数据库里创建 数据库data2 表test1:   增量inc1
   xtrabackup --backup --compress --target-dir=/data/compressed/inc1 --incremental-basedir=/data/compressed/base --user=root --password=123456 --host=127.0.0.1
3、数据库里创建 数据库data3 表test1:   增量inc2
   xtrabackup --backup --compress --target-dir=/data/compressed/inc2 --incremental-basedir=/data/compressed/inc1 --user=root --password=123456 --host=127.0.0.1

增量恢复:

* 解压所有压缩文件:
  xtrabackup --decompress --parallel=3  --target-dir=/data/compressed/base --remove-original
  xtrabackup --decompress --parallel=3 --target-dir=/data/compressed/inc1 --remove-original
  xtrabackup --decompress --parallel=3 --target-dir=/data/compressed/inc2 --remove-original
  // --decompress 分别对base inc1 inc2 进行解压 *只会解压指定文件夹下的文件，第二层不会解压*
* 准备备份文件:
  先准备全备份文件-*>* 准备增量1文件 -*>* 准备增量2 文件 -*>* 然后整体 copy-back 恢复
  xtrabackup --prepare --apply-log-only --target-dir=/data/compressed/base 
  xtrabackup --prepare --apply-log-only --target-dir=/data/compressed/base --incremental-dir=/data/compressed/inc1
  xtrabackup --prepare --target-dir=/data/compressed/base --incremental-dir=/data/compressed/inc2
  相当于把所有增量数据一个个叠加在 全备份上 再拿整个去还原数据

然后用被堆积过的 全备份文件 进行 恢复
* xtrabackup --copy-back --target-dir=/data/compressed/base --datadir=/data/mysql
  // 备份前需要把/data/mysql文件清空
* chown -R mysql:mysql /data/mysql
* 重新启动mysql

*在解压的时候最好不使用删除压缩文件，准备文件的时候由于inc1文件没有加压完全，导致最后准备恢复文件有错误，导致
最后不能恢复，而prepare没有后退选项*


# innobackupex 备份恢复

支持 innodb myisam
参数和xtrabackup 差不多: --apply-log-only 和 --redo-only作用一样
                         备份的时候不需要指定 --backup

备份:
* innobackupex --user=root --password=123456 --host=127.0.0.1 /data/backup/base --no-timestamp
  // --no-timestamp: 不创建 时间戳命名文件
恢复:
1、准备:innobackupex --apply-log /data/backup/base
  //innobackupex --apply-log --use-memory=4G /data/backup/base 可以指定内存
2、innobackupex --copy-back /data/backup/base // 在my.cnf中指定 datadir=/data/mysql
3、chown -R mysql:mysql /data/mysql; 然后重启服务

增量备份:
* innobackupex --user=root --password=123456 --host=127.0.0.1 /data/backup/base --no-timestamp
* innobackupex --user=root --password=123456 --host=127.0.0.1 --incremental /data/backup/inc1 --incremental-basedir=/data/backup/base --no-timestamp
* innobackupex --user=root --password=123456 --host=127.0.0.1 --incremental /data/backup/inc2 --incremental-basedir=/data/backup/inc1 --no-timestamp
*指定开始lsn开始备份到现在状态的lsn
innobackupex --user=root --password=123456 --host=127.0.0.1 --incremental /data/backup/lsn --incremental-lsn=11 --no-timestamp //指定from_lsn开始备份到现在，一般在前一个备份文件的节点上备份（to_lsn），不然perpare会失败*

恢复:
* innobackupex --apply-log --redo-only /data/backup/base
* innobackupex --apply-log --redo-only /data/backup/base --incremental-dir=/data/backup/inc1
* innobackupex --apply-log  /data/backup/base --incremental-dir=/data/backup/inc2 // 最后一个不用使用apply-log
* innobackupex --apply-log /data/backup/base //合并回滚
* innobackupex --copy-back /data/backup/base //恢复 恢复之前需要删除datadir,恢复后需要chown /data/mysql

*--rsync 可以加速传输 不可以和--stream 一起使用* 	
流备份:

Incremental Streaming Backups using xbstream and tar:

* innobackupex --user=root --password=123456 --host=127.0.0.1 --incremental  --incremental-lsn=2671732  --stream=xbstream ./ | ssh root@207.246.96.252 "cat - | xbstream -x -C /data/backup"
* innobackupex --user=root --password=123456 --host=127.0.0.1 --incremental --incremental-lsn=2671732  --stream=xbstream ./  |  ssh root@207.246.96.252 "cat -> /data/backup/inc1.xbstream" //不解压
* innobackupex --user=root --password=123456 --host=127.0.0.1 --incremental --incremental-lsn=2671732  --stream=xbstream --compress ./  |  ssh root@207.246.96.252 "cat -> /data/backup/inc1.xbstream"
  // 压缩 stream传输 

使用--extra-lsndir 和 show engine innodb status\G" | grep "Log sequence number" 数据对比进行脚本自动定时增量备份
因为该备份是根据lsn进行备份(Log sequence number)

```BASH
#!/bin/bash
data_time=`date +"%F_%T"`
extra_dir=/data/backup/extra
lsn_start=`mysql -uroot -p123456 -e "show engine innodb status\G" | grep "Log sequence number"| cut -d" " -f4`
lsn_now=`cat extra/xtrabackup_checkpoints | grep	 last_lsn | cut -d= -f2`
echo "$lsn_start: $lsn_now"
if [ $lsn_start -gt $lsn_now ]
then

   innobackupex --user=root --password=123456 --host=127.0.0.1 --incremental --extra-lsndir=${extra_dir}  --incremental-basedir=${extra_dir}  --stream=xbstream ./  |  ssh root@207.246.96.252 "cat -> /data/backup/inc_${data_time}.xbstream"
else
    echo "data do not update!"

fi

```

恢复: 把文件传到本地计算机在进行解压 和还原，或者在远程主机上进行搭建相同环境进行还原

# stream 备份 远程备份 恢复



 
# 事务 行锁 锁表


