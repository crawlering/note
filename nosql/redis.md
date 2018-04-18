# redis 


* 下载: curl -C -o nerdtree.zip https://www.vim.org/scripts/download_script.php?src_id=23731
* 安装
  unzip nerdtree.zip -d nerdtree.zip
  cd nerdtree
  make && make install
  cp redis.conf /etc/redis.conf
  编辑 /etc/redis.conf //修改以下项
      
      ```bash
      //在后台运行项
      daemonize yes
      logfile "/var/log/redis.log" 
      dir /data/redis_data/
      appendonly yes 
      ```
  mkdir /data/redis_data
  sysctm vm.overcommit_memory=1  //内核设置选项，不设置可能内存不足时会重启
  echo never **>** /sys/kernel/mm/transparent_hugepage/enabled
  redis-server /etc/redis.conf
    
  
## redis 介绍

redis 两种持久化方式(内部才能数据写入磁盘):
RDB(redis database): 在不同的时间点，将redis存储的数据生成快照并存储到磁盘等介质上
AOF(append only file):讲redis执行过得所有写指令记录下来，在下一次redis重新启动时，只要把
                      这些写指令重新执行一遍，就可以实现数据恢复了

其实RDB和AOF两种方式也可以同时使用，在这种情况下，如果redis重启的话，则会优先采用AOF方式来进行数据恢复，
这是因为AOF方式的数据恢复完整度更高。

如果你没有数据持久化的需求，也完全可以关闭RDB和AOF方式，这样的话，redis将变成一个纯内存数据库，
就像memcache一样。

AOF：
  appendonly yes  #如果是yes，则开启aof持久化
  appendfilename “appendonly.aof” # 指定aof文件名字

  appendfsync everysec #指定fsync()调用模式，有三种
  no(不调用fsync),
  always(每次写都会调用fsync),
  everysec(每秒钟调用一次fsync)。
 第一种最快，第二种数据最安全，但性能会差一些，第三种为这种方案，默认为第三种

RDB:
  save 900 1 #表示每15分钟且至少有1个key改变，就触发一次持久化 
  save 300 10 #表示每5分钟且至少有10个key改变，就触发一次持久化
  save 60 10000 #表示每60秒至少有10000个key改变，就触发一次持久
  上述只要满足一项就会执行一次把数据写到磁盘
  
  save “”  #这样可以禁用rdb持久化

## redis 数据类型

string 
list
set
sort set
hash

redis-cli: 登入redis
以下为部分命令:

string: 最为简单的类型，和memcached 一样，key value型
* 设置值: set mykey "test123"; 设置多组值mset key1 a key2 b key3 c
* 查看值: get mykey          ; 查看多个值mget key1 key2 key3
* 删除值: DEL mykey

list:是一个链表结构.有序,但是分从左从右寻找和插入
    主要功能是push pop 获取一个范围的所有值等,操作中key理解为链表的名字
**list放值进去可以从左边放和从右边放,也有从左边取和右边取**
* 设置值: LPUSH mykeys 1 2 3 a //left push
* 查看值:LRANGE mykeys 1 3 位置重0开始，--> 3 2 1  //left range 从左边开始查看所以 第一个查看的是
  最后一个插入的
* 取值:LPOP mykeys -> a ;LPOP mykeys ->3 ...，而且LPOP是取值，取出来就没了
* 删除值: 删除整个list变量也是del
 *set可以重新设置LPUSH定义的值，但是LPUSH 不能重新设置set设置的值，需要del删除*

set:是一个无序集合，可以求并集 交集 差集 对集合还有添加 删除操作,不可以有重复的成员
* 设置值:SADD keys 1 可以一个一个设置，也可以多个设置 SADD keys 2 3,且设置的值是无序的，没有顺序而言
* 查看值:SMEMBERS keys1；增加值后查看顺序会被打乱
* 删除值:SREM keys 1 ;删除空置也会打破排列,删除1这个值，del是删除整个变量
* 交集:SINTER keys keys1 
* 并集:SUNION keys keys1
* 差集:SDIFF keys keys1
* 获取成员数: SCARD
sort set:有序集合,比set多了个权重参数score,这个是用来排序的，并且score这个参数可以重复的,但是成员不可以重复
          成员如果再次被定义则 后一次定义的score有效,前面的score被覆盖

* 设置值,添加值: ZADD key score value score2 value2...
* 查看值: ZRANGE key 0 -1 //start end；    
          ZREVRANGE key 0 -1 //反向排序
* 删除值:SREM key value 
* 获取成员个数: ZCARD value

hash: Redis hash 是一个string类型的field和value的映射表，hash特别适合用于存储对象。
      Redis 中每个 hash 可以存储 232 - 1 键值对（40多亿）。相当于字典的东西
      一个字符串映射到一串其他的内容，和有序集合sort set一样，只是他是有序的(且socre只能是数值)，
      hash表是有自己的算法寻找到自己的值
* 设置值:HMSET key field1 value1 [field2 value2 ] //同时将多个 field-value (域-值)对设置到哈希表 key 中
* 查看值: HGET key field //获取存储在哈希表中指定字段的值。
          HGETALL key //获取在哈希表中指定 key 的所有字段和值
          HEXISTS key field  //查看该字段是否在表中存在
* 删除值: HDEL key field1 [field2] //删除一个或多个哈希表字段
* 获取成员个数:HLEN key // 获取哈希表中字段的数量


redis 其他常用指令(键值):

 keys *    //取出所有key
 keys my* //模糊匹配
 exists name  //有name键 返回1 ，否则返回0；
 del  key1 // 删除一个key    //成功返回1 ，否则返回0；
 EXPIRE key1 100  //设置key1 100s后过期
 ttl key // 查看键 还有多长时间过期，单位是s,当 key 不存在时，返回 -2 。
         // 当 key 存在但没有设置剩余生存时间时，返回 -1 。 否则，返回 key 的剩余生存时间。
 select  0  //代表选择当前数据库，默认进入0 数据库
 move age 1  // 把age 移动到1 数据库
 persist key1   //取消key1的过期时间
 randomkey //随机返回一个key
 rename oldname newname //重命名key
 type key1 //返回键的类型

redis 常用操作(服务)
 dbsize  //返回当前数据库中key的数目
 info  //返回redis数据库状态信息
 flushdb //清空当前数据库中所有的键
 flushall    //清空所有数据库中的所有的key
 bgsave //保存数据到 rdb文件中，在后台运行
 save //作用同上，但是在前台运行
 config get * //获取所有配置参数
 config get dir  //获取配置参数
 config set dir  //更改配置参数
 数据恢复： 首先定义或者确定dir目录和dbfilename
            ，然后把	备份的rdb文件放到dir目录下面，重启redis服务即可恢复数据


## redis 安全

更改配置文件: /etc/redis.conf
* 设置监听ip，不把监听ip设置到公网ip上: bind 127.0.0.1  2.2.2.2//可以是多个ip，用空格分隔
* 设置监听端口: port 16000 //默认6379
* 设置密码: requirepass 123456； 
  登入redis: redis-cli -a "123456"
*  将config命令改名: rename-command CONFIG CFG
   或者将config命令禁用掉:rename-command CONFIG “”


## redis 慢查询日志

编辑配置文件 /etc/redis.conf

针对慢查询日志，可以设置两个参数，
一个是执行时长，单位是微秒，
另一个是慢查询日志的长度。当一个新的命令被写入日志时，最老的一条会从命令日志队列中被移除。 
* slowlog-log-slower-than 1000 //单位ms，表示慢于1000ms则记录日志
* slowlog-max-len 128  //定义日志长度，表示最多存128条
* slowlog get //列出所有的慢查询日志
* slowlog get 2 //只列出2条
 slowlog len //查看慢查询日志条数

##redis 安装php扩展

* wget http://pecl.php.net/get/redis-3.1.6.tgz //进入pecl官网(php扩展官网) 搜索数据库-redis
* tar -zxvf redis-3.1.6.tgz;cd redis-3.1.6
* /usr/local/php-fpm/bin/phpize
  ./configure --with-php-config=/usr/local/php-fpm/bin/php-config
   make 
   make install
   vim /usr/local/php.ini//增加extension=redis.so
   /usr/local/php-fpm/bin/php -m|grep redis//看是否有redis模块
   重启php-fpm服务

## redis php中使用 redis存储 session

* vim /usr/local/php-fpm/etc/php.ini//更改或增加
  session.save_handler = "redis" 
  session.save_path = "tcp://127.0.0.1:6379" 

  或者apache虚拟主机配置文件中也可以这样配置：
  php_value session.save_handler " redis" hp_value session.save_path " tcp://127.0.0.1:6379" 
 
  或者php-fpm配置文件对应的pool中增加：
  php_value[session.save_handler] = redis
  php_value[session.save_path] = " tcp://127.0.0.1:6379 "

测试php session
* wget -O session.php http://study.lishiming.net/.mem_se.txt
*  curl localhost/session.php 
   //结果类似于1443702394<br><br>1443702394<br><br>i44nunao0g3o7vf2su0hnc5440
   redis-cli命令行连接redis，也可以查看到该key以及对应的值

## redis 主从

为了节省资源，我们可以在一台机器上启动两个redis服务
* cp /etc/redis.conf  /etc/redis2.conf
* vim /etc/redis2.conf //需要修改port,dir,pidfile,logfile
   还要增加一行
   slaveof 127.0.0.1 6379
    如果主上设置了密码，还需要增加 //主设置了:requirepass 123456
    从需要添加:  masterauth 123456 //设置主的密码
* 启动之前不要忘记创建新的dir目录
* redis-server /etc/redis2.conf
  测试：在主上创建新的key，在从上查看
  注意：redis主从和mysql主从不一样，redis主从不用事先同步数据，它会自动同步过去

 
## redis cluster 集群
redis cluster,需要使用predis扩展


* 多个redis节点网络互联，数据共享
* 所有的节点都是一主一从（可以是多个从），其中从不提供服务，仅作为备用
* 不支持同时处理多个键（如mset/mget），因为redis需要把键均匀分布在各个节点上，
   并发量很高的情况下同时创建键值会降低性能并导致不可预测的行为。
* 支持在线增加、删除节点
* 客户端可以连任何一个主节点进行读写


场景设置：
 两台机器，分别开启三个Redis服务(端口)
 A机器上三个端口7000,7002,7004，全部为主
 B机器上三个端口7001,7003,7005，全部为从
 两台机器上都要编译安装redis,然后编辑并复制3个不同的redis.conf，分别设置不同的端口号、dir等参数，
 还需要增加cluster相关参数，然后分别启动6个redis服务
  
```BASH
port 7000
bind 192.168.30.20
daemonize yes
pidfile /var/run/redis_7000.pid
dir /data/redis_data/7000
cluster-enabled yes
cluster-config-file nodes_7000.conf
cluster-node-timeout 10100
appendonly yes

```

* 或者编辑自动化脚本生成相应文件:

```BASH
#!/bin/bash
read -p "please input ip:" ipname
echo $ipname
read -p "please input start 0 or 1(7000 or 7001):" start_file
 
for i in `seq $start_file 2 5`
do
 
touch "700$i.conf"
mkdir -p /data/redis_data/700$i
echo "port 700$i
bind $ipname
daemonize yes
pidfile /var/run/redis_700$i.pid
dir /data/redis_data/700$i
cluster-enabled yes
cluster-config-file nodes_700$i.conf
cluster-node-timeout 10100
appendonly yes
" > 700$i.conf
 
 
done

```

* 在同一目录下执行 开启服务脚本:

```BASH
#!/bin/bash
 
DIR=/root/redis_cluster/
CONF=`ls $dir|grep -E "*.conf"`
for i in $CONF
do
    /usr/local/bin/redis-server $i
done

```

* ps -ef |grep redis
  root      8866     1  0 15:44 ?        00:00:00 /usr/local/bin/redis-server 192.168.31.20:7000 [cluster]
  root      8868     1  0 15:44 ?        00:00:00 /usr/local/bin/redis-server 192.168.31.20:7002 [cluster]
  root      8873     1  0 15:44 ?        00:00:00 /usr/local/bin/redis-server 192.168.31.20:7004 [cluster]

* 然后在另外台机器做同样操作


* 安装ruby环境
 yum -y groupinstall "Development Tools"
 yum -y install gdbm-devel libdb4-devel libffi-devel libyaml libyaml-devel ncurses-devel openssl-devel readline-devel tcl-deve
 
  cd /root/
 mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
 wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz -P rpmbuild/SOURCES
 wget https://raw.githubusercontent.com/tjinjin/automate-ruby-rpm/master/ruby22x.spec -P rpmbuild/SPECS
 rpmbuild -bb rpmbuild/SPECS/ruby22x.spec
 yum -y localinstall rpmbuild/RPMS/x86_64/ruby-2.2.3-1.el7.centos.x86_64.rpm
 gem install redis


## redis 集群配置和操作


* cp /usr/local/src/redis-4.0.1/src/redis-trib.rb  /usr/bin/
* redis-trib.rb create --replicas 1 192.168.31.20:7000 192.168.31.20:7002 192.168.31.20:7004 192.168.31.21:7001 192.168.31.21:7003 192.168.31.21:7005
 redis-cli -c -h 192.168.31.20 -p 7000//-c说明以集群的方式登录
 任意一个节点都可以创建key，或者查看key（演示）
 redis-trib.rb check  192.168.31.20:7000//检测集群状态
 cluster nodes//列出节点
 cluster info//查看集群信息
 cluster meet ip port //添加节点
 cluster forget node_id //移除某个节点
 cluster replicate node_id//将当前节点设置为指定节点的从
 cluster saveconfig//保存配置文件


* 安装predis
* 配置各个主机的redis服务
* 安装ruby环境
* 使用redis-trib.rc 创建redis集群
