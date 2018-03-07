# NoSQL

* 非关系数据库是NoSQL，关系型数据库代表MySQL


关系型数据库(RDBMS Relational Database Management System): 
* 需要把数据存储到库 表 行 字段 里，查询的时候根据条件一行一行的去匹配，当 量非常大的时候就很消耗
  时间和资源，尤其是数据是需要从磁盘里去检索

NoSQL 非关系型数据库(NOT ONLY SQL):
* NoSQL 数据库存储原理非常简单(典型的数据类型为K-V)，不存在繁杂的关系链，
  比如mysql 查询的时候，需要找到对应的库 表(通常多个表)以及字段
  NoSQL数据可以存储在内存里，查询速度非常快

* NoSQL 在性能表现上虽然优于关系数据库，但是他并不能完全替代关系数据库
* NoSQL 因为没有复杂的数据结构,扩展容易,支持分布式


常见的NoSQL 数据库

*  **k-v形式的**：memcached、redis 适合储存用户信息，比如会话、配置文件、参数、购物车等等。这些信息一般都和ID（键）挂钩，这种情景下键值数据库是个很好的选择。

*  **文档数据库**：mongodb   将数据以文档的形式储存。每个文档都是一系列数据项的集合。每个数据项都有一个名称与对应的值，值既可以是简单的数据类型，如字符串、数字和日期等；也可以是复杂的类型，如有序列表和关联对象。数据存储的最小单位是文档，同一个表中存储的文档属性可以是不同的，数据可以使用XML、JSON或者JSONB等多种形式存储。

*  **列存储** Hbase

*  **图**  Neo4J、Infinite Graph、OrientDB


## memcached 

参考文献:
https://charlee.li/memcached-001.html 001-005
http://blog.csdn.net/qianshangding0708/article/details/47980697


介绍:
Memcached 由国外社区网站 liveJournal 团队开发，
目的是为了缓存数据库查询结果，减少数据库访问次数,以提高动态Web应用的速度、 提高可扩展性
(应用服务器从中读取数据并在浏览器中显示。 但随着数据量的增大、访问的集中，
就会出现RDBMS的负担加重、数据库响应恶化、 网站显示延迟等重大影响)

官方站点: http://www.memchaed.org

* 数据结构简单(k-v),数据存放在内存里
  多线程
  基于c/s架构，协议简单
  基于libevent 的事件处理
  自主内存存储处理(slab allocator)
  数据过期方式：lazy Expiration 和 LRU(least recently used)
  memcached不互相通信的分布式

mamcheched 采用 slab allocator 机制：
包含三个概念:
* slab: 相同chunk 大小的集合(在同一个slab里的chunk值都一样)，一个slab包含多个page，
  一个page(默认是1M)包含多个chunk,
* page: page默认大小1M，1个page包含多个chunk
* chunk: 默认情况下chunk值为96，随着制定的增长因子变化(-f <factor>)


**Growth Factor(chunk的增长因子)**
* memcached在启动时指定 Growth Factor因子（通过-f选项，默认是1.25
* 将memcached引入产品，或是直接使用默认值进行部署时， 最好是重新计算一下数据的预期平均长度，
  调整growth factor， 以获得最恰当的设置。内存是珍贵的资源，浪费就太可惜了。

**LRU机制**
可以看出启动memcached后slab就分好组了(没有数据slab都是空的)，大小已经确定，数据过来只是去选择合适的slab，然后分配chunk给该slab，然后又有新的数据过来，只有当chunk不够用了才会申请新的slab，
并且一旦分配了内存后，就不会释放，重复利用。

当内存分配完了以后怎么办:
他会在该slab中启用LRU机制，删除(最近最少使用)


**lazy Expiration**
当然数据存储在内存中还要遵循 lazy Expiration机制，该机制
memcached内部不会监视记录是否过期，而是在get时查看记录的时间戳，检查记录是否过期。 这种技术被称为lazy（惰性）expiration。因此，memcached不会在过期监视上耗费CPU时间。
memcached启动时通过“-M”参数可以禁止LRU


slab allocator **存在浪费内存的问题**:优化途径:
1、避免个别的大对象
如果系统上只有及个别几个大对象的话，会浪费内存空间，因为Slab申请了Page是不能释放内存的，
及个别大对象会导致Slab申请了内存资源而得不到充分的利用

2、调整增长因子(growth factor)


## memcached 安装

*  yum install -y memcached libmemcached libevent
*  systemctl start memcached
*  vim /etc/sysconfig/memcached 可以配置参数//比如加上监听的ip，可以把OPTIONS="" 改为OPTIONS="127.0.0.1"

memcached 常用参数:

* -m 指定可以使用的内存大小(默认64M)
* -c 指定连接的最大并发数
* -u 指定运行memcached运行的用户(只能用root启用)
* -d 使用daemon方式启动
* -l 设置监听的IP地址可以使用IP:PORT形式指定port，如果没指定可以用-p port 指定端口
* -M 禁止使用LRU机制算法去删除再用的内存的数据，当内存分配完的时候返回错误
其他参数 memcached -help

## memcached 使用

连接和退出
* telnet 192.168.31.20 11211  //连接
* quit //退出


基本命令:

* set:用于向缓存添加新的键值对。如果键已经存在，则之前的值将被替换。
* add: 仅当缓存中不存在键时，add 命令才会向缓存中添加一个键值对。
  如果缓存中已经存在键，则之前的值将仍然保持相同，并且您将获得响应 NOT_STORED.

* replace: 仅当键已经存在时，replace 命令才会替换缓存中的键。如果缓存中不存在键，
           那么您将从 memcached 服务器接受到一条 NOT_STORED 响应。

* get: 用于检索与之前添加的键值对相关的值。
* delete: 用于删除 memcached 中的任何现有值。您将使用一个键调用delete，
          如果该键存在于缓存中，则删除该值。如果不存在，则返回一条NOT_FOUND 消息。


set add replace 是用于操作存储在 memcached 中 键值对 的标准修改命令：

**语法:**
set/add/replace <key> <flags> <expiration time> <bytes> 
<value>

key: key用于查找缓存值
flags: 可以包括键值对的整型参数，客户机使用它存储关于键值对的额外信息
       是一个16位的无符号的整数(以十进制的方式表示)。标志将和需要存储的数据
       一起存储,并在客户端get数据时返回。户端可以将此标志用做特殊用途，此标志对服务器来说是不透明的。
expiration time:     在缓存中保存键值对的时间长度（以秒为单位，0 表示永远）
bytes:   需要存储的字节数，当用户希望存储空数据时<bytes>可以为0
value:     存储的值（始终位于第二行）

get/delete <key>


```BASH
set userId 0 0 5
12345
STORED
get userId
VALUE userId 0 5
12345
END
get bob
END
```


* gets: gets test01 //多返回一项为键的值得修改次数，相当于版本的记录
* cas:保证上一次gets获得的版本信息，这次设定值期间，没有其他用户更改过键值//版本信息不一样就会返回exists
      设置相当于set，但是多了个版本号(确认版本号，如果和上次gets获得的版本信息不一致就不会成功)

* append: 将数据追加到当前缓存数据的之后，当缓存数据存在时才存储。
* prepend: 将数据追加到当前缓存数据的之前，当缓存数据存在时才存储.

缓存管理命令
* stats:转储所连接的 memcached 实例的当前统计数据
* stats items: 可以看到STAT items行，如果memcached存储内容很多，那么这里也会列出很多的STAT items行。
  stats cachedump slabs_id limit_num
  slabs_id:由stats items返回的结果（STAT items后面的数字）决定的
  limit_num:返回的记录数，0表示返回所有记录
  通过stats items、stats cachedump slab_id limit_num配合get命令可以遍历memcached的记录。
* stats slabs: 显示各个slab的信息，包括chunk的大小、数目、使用情况等
* flush_all:将缓存重置到干净的状态,谨慎使用


查看memcached运行状态:

* memcached-tool 192.168.31.20 stats
 或者 echo stats |nc 127.0.0.1 11211  需要安装nc工具  yum install -y nc
* memstat --servers=127.0.0.1:11211 查看memcached服务状态//需要安装libmemcached,
  此结果和 echo stats | nc 192.168.31.20 11211 结果一样，同样和telnet里输入stats结果相同

 memcached 数据导出和导入: 

* 导出：
   memcached-tool 127.0.0.1:11211 dump > data.txt
   cat data.txt
* 导入：
     nc 127.0.0.1 11211 **<** data.txt
     若nc命令不存在，yum install nc
   注意：导出的数据是带有一个时间戳的，这个时间戳就是该条数据过期的时间点，
   如果当前时间已经超过该时间戳，那么是导入不进去的,
   **而设置过期时间为永久，设定的时间会是之前的时间，所以设置永久的时间是导入不进去的**

## php 连接 memcached

* 下载memcache,php7安装官网的memcache的任意版本都会报错"can not find php_smart_string.h"
* 所以到github上下载:wget https://github.com/websupport-sk/pecl-memcache/archive/php7.zip
  或者: wget  https://github.com/websupport-sk/pecl-memcache/archive/NON_BLOCKING_IO_php7.zip
* 解压安装 unzip php7.zip
  cd pecl-memcache-php7;/usr/local/php-fpm/bin/phpize //生成configure文件
  然后源码编译安装: ./configure --with-php-config=/usr/local/php-fpm/bin/php-config
  make&&make install;
* 配置php.ini 打开memcache模块 //vim /usr/local/php-fpm/etc/php.ini
  搜索关键字extension 在末尾添加extension="memcache.so"
  然后执行 /usr/local/php-fpm/bin/php-fpm -m | grep memcache.so //可以查看到memcache模块被加载


