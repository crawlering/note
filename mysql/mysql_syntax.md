# mysql syntax

*语句用大写可以补全，小写语句可以用但是不会自动补全*

## databases 数据库

### increased

* create database test01 [charset utf8]; #设置数据库编码格式，如果不设置则为默认编码格式

### delete

* drop database test01; #删除数据库

### change

* alter database test01 character set utf8; #更改数据库编码格式为utf8
* 修改数据库默认 编码格式：在 my.cnf 配置文件中修改
   1、[client] 追加 default-character-set=utf8
   2、[mysqld]      character-set-server=utf8
   3、[mysql]       default-character-set=utf8
   4、重启mysqld服务

### check

* use test01;show variables like "character_set_database"; #查看数据库test01默认编码格式
* show databases; #查看所有数据库
* show create database test01; #查看数据库 test01 的 创建语句 可以看到编码格式


## tables 表
 
*表名和字段名用``反点括起来，可以不括*

### increased

* create table `user01` (`id` int(8) not null, `name` varchar(40) not null) ENGINE=MyISAM DEFAULT CHARSET=gb2312;
* alter table user03 ADD address varchar(100)[AFTER name]; # 表user03 name字段后，增加 address 字段

### delete

* drop table user01;
* ALTER TABLE `user03` DROP `address`; #删除字段 address

### change
 
* alter table user02 rename user03; #把表 user02 名改为 user03；
* alter table user03 MODIFY name varchar(30); #更改表结构字符类型
* alter table user03 CHANGE name name03 varchar(30); 更改表结构名和结构字符类型

### check
 
 * show tables; #查看数据库内所有表
 * show create table user01; #查看创建表语句（show create database test01; 查看数据库创建语句）
 * desc user01; #查看表结构


## 表数据

### increase

* insert into `user03` [(`id`, `name`, `address`)] VALUE[S] ('1','小红','南昌'),('2','小刚','上饶'); 
    \\#vaule:插入多行要快 values:插入单行要快 http://blog.csdn.net/qq_26683009/article/details/52526834 ；

* 

### delete

* DELETE FROM user03 WHERE id >= 7; #删除id>=7的数据 AUTO_INCREMENT 接着计算 #不加WHERE 条件将会整个删除 ?是否可以锁定对表的此类操作，
* turncate user03; #删除user03 的数据 auto_increment 重新计算


### change

* UPDATE user03 set address="南昌" [where id=8]; #不指定条件 修改所有?谨慎操作
*  

### check

* select * from user03; # 查询 表 user03 的所有数据
    select * from user03 where id>=4; #指定条件
    select * from user03 where name like 'xiao%'；#搜索关键字 ‘xiao...’
    select * from user03 limit 5; # 查看前面1-5条
    select * from user03 limit 4,5;查看 从第四条开始，5条结果

* select id, name from user03; #查询表 user03 的 id 和 name 列
   select user03.id, user03.name from user03;

* select * from user03 order by id desc; # 根据 id **降序** 显示，默认是 **升序**  ‘asc’。

* select * from user03 a where a.id=2;   指定条件 以 'a' 为 别名
    select * from user03 where user03.id=2;
    select * from user03 where id=2;

* select distinct a.name from user03 a; 显示去掉相同名字的

* select count(*) from user03 where name='xx'; #统计 name=‘xx’ 的行数

* select MAX(id) from user03;
    select MIN(id) from user03; # 查看表中 id 项的最大 最小值
    select AVG(id) from user03; # 查看 user03 的 id项的平均值
    select SUM(id) from user03; # 查看 user03 id 项的 和
    SELECT *,COUNT(*) from user03 GROUP BY name; #显示 user03 所有项和 计数项，并且以 name 计数分组。
    select id,name from user03 union [all] select id,name from user03;  #结合显示 'union' 会去重 'union all' 不会去重
    select * from user01 a, user03 b where a.id=1 and b.id=5; # 表user01 id=1 并且 表 user03 id=5 的显示出来，
    \\#表不一样长，短的 按顺序补充原来的数据
    SELECT * from user03 a where id = (SELECT id from user01 where id=2); # 把一条sql的结果 作为另一条sql的条件

## mysql 数据引擎介绍

### 数据库 引擎

** 数据库引擎 有: MyISAM存储引擎 InnoDB存储引擎 MEMORY存储引擎 MERGE存储引擎 **

常用的有 MyISAM 和 InnoDB 引擎;

#### MyISAM 和 InnoDB 区别

MyISAM:

* 不支持事物，
* 不支持外键，不支持行级锁，访问速度快
* 对事物完整性没有要求， 
* select count(*) from table #执行该操作很块，MyIASM 中已经存储了表的行数

每个MyISAM 在磁盘上存储成3个文件，其中文件名和表明相同，扩展名为:
* .frm (存储表定义)
* MYD (MYData, 存储数据)
* MYI (MYIndex, 存储索引)


MyISAM 还支持3中不同存储格式:

* 静态(固定长度)表 #占用空间较大 存储迅速，容易缓存，出现故障容易恢复
* 动态表 #占用空间小，频繁删除更新记录 会长生碎片
* 压缩表 #由 myisamchk 工具创建，占用空间更小，

InnoDB:

* 提供了 提交, 回滚, 崩溃恢复能力的事物安全
* 提供了 行级锁和外键约束
* 自动增长列 auto_increment
* 外键约束 foreign key


    大尺寸数据趋向于 InnoDB, 因为支持 事物处理和故障 恢复；
大批的INSERT语句(在每个INSERT语句中写入多行，批量插入)在MyISAM下会快一些，
但是UPDATE语句在InnoDB下则会更快一些，尤其是在并发量大的时候。

### mysql 数据介绍

主键:
* 一个表只有一个主键 
* 主键列不能为空 NOT NULL
* 主键不可以有相同的值 UNIQUE
* 主键可以被外键应用，而索引不能作为外键引用
关键字：PRIMARY KEY 

* alter table stu add PRIMARY KEY(id); #增加主键 定义的时候也可以定义
* alter table stu drop PRIMARY KEY; #删除主键 当有auto_increment的时候需要先把auto_increment 使用modify设置没

外键:
* 两个表都是InnoDB 表
* 外键关系的表 数据类型相似，可以相互转换
* 保证数据的完整性和可靠性，2个表用外键组成1个大表
* 表的外键就是另外个表的主键
* 删除一张表要确保其他表在此表没有外键
关键字: FOREIGN KEY

* alter table score ADD CONSTRAINT score_stu FOREIGN KEY(name) REFERENCE stu(name); #CONSTRAINT 定义外键别名 stu为主表
   'name' 是 stu 的主键，不一定是 score的主键,本表创造外键连接其他表的主键
* alter table score DROP foreign key score_stu; #删除外键 后面写别名

外键包括4中方式:

ON DELETE 和 ON UPDATE 定义规则: 


* CASCADE    删除包含与已删除键值有参照关系的所有记录
* SET NULL   修改包含与已删除键值有参照关系的所有记录，使用NULL值替换（只能用于已标记为NOT NULL的字段）
* RESTRICT   拒绝删除要求，直到使用删除键值的辅助表被手工删除，并且没有参照时(这是默认设置，也是最安全的设置)
* NO ACTION  啥也不做

*alter table score add CONSTRAINT stu_score FOREIGN KEY(name) REFERENCES stu(name) ON DELETE RESTRICT;*
* ALTER TABLE SCORE DROP FOREIGN KEY stu_score; 删除外键
* [test03]> CREATE TABLE `testxx` (
    -> `id` int(11) not null,
    -> `name` varchar(40) not null,
    -> PRIMARY KEY(name),
    -> CONSTRAINT `for_key` FOREIGN KEY(name) REFERENCES stu(name));

* RESTRICT关联方式 表存在外键后，(存在外键的表成为子表)，子表添加插入数据外键的字段必须在主表存在
  主表添加数据无影响，主表删除数据，需要先删除对应外键表的相应数据，才可以删除主表数据，子表删除数据无影响。

索引:
* 加快访问速度
* 用来快速寻找那些具有特定值的记录
* ‘唯一性索引’ 这种索引和普通索引的区别就是 所有 值只能出现一次，必须唯一
关键字:INDEX, UNIQUE INDEX

* alter table score add index id_index(`id`);
* alter table score add FULLTEXT id_index(`name`); #fulltext 需要在类型 "varchar" 或者 "text"才能设置
* alter table score drop index id_index; #删除索引
* create index in_index on score(name);

索引总类:

* FULLTEXT
* HASH
* BTREE #默认
* RTREE




## 设置结束语句 delimiter 

* delimiter $$ #设置 '$$' 为结束符
* set autocommit=off #默认开启自动提交，关闭自动提交后可以 rollback；返回数据，需要提交执行 commit;
* show grants; #查看当前 用户 信息 show grants for vsftpdguest@'%'; vsftpdguest用户
 
## log-bin 开启 二进制日志

* my.cnf [mysqld] log-bin=mysql-bin
* /usr/local/mysql/bin/mysqlbinlog --no-defaults  mysql-bin.000004 --start-position=623 --stop-position=724 | mysql -uroot 
  -h127.0.0.1 -p # 重新执行 623 到 724的操作
* show master status; 
* show variables like 'log_bin%';
* /usr/local/mysql/bin/mysqlbinlog --no-defaults  mysql-bin.000004 #查看日志操作
* flush logs; #刷新logs 重新生成一个log文件
* reset master; #清除所有bin_logs

