# mysql

? mysql 锁
         表级锁：开销小，加锁快；不会出现死锁；锁定粒度大，发生锁冲突的概率最高,并发度最低。
         行级锁：开销大，加锁慢；会出现死锁；锁定粒度最小，发生锁冲突的概率最低,并发度也最高。
         页面锁：开销和加锁时间界于表锁和行锁之间；会出现死锁；锁定粒度界于表锁和行锁之间，并发度一般。

？mysql 事务:
         原子性（Atomicity）：事务是一个原子操作单元，其对数据的修改，要么全都执行，要么全都不执行。
         一致性（Consistent）：在事务开始和完成时，数据都必须保持一致状态。这意味着所有相关的数据规则都必须应用于事务的修改，
      以保持数据的完整性；事务结束时，所有的内部数据结构（如B树索引或双向链表）也都必须是正确的。
         隔离性（Isolation）：数据库系统提供一定的隔离机制，保证事务在不受外部并发操作影响的“独立”环境执行。这意味着事务处理
     过程中的中间状态对外部是不可见的，反之亦然。
         持久性（Durable）：事务完成之后，它对于数据的修改是永久性的，即使出现系统故障也能够保持。

    * http://blog.csdn.net/xifeijian/article/details/20313977
    ?更新丢失 脏读 不可重复读 幻读



# linux 内核

## linux tcp 连接数限制

连接数受限于:

* 每个进程打开文件数的限制
* 每个用户打开文件数的限制 软限制、硬限制
* linux 系统级的最大打开文件数限制 (硬限制)
* 可以运行的最大并发进程数

* 从tcp连接处理：1、端口数限制
                 2、tcp连接限制


1、 ulimit -n #查看当前进程 打开文件数限制（软限制）
    ulimit -n 10240  #设置当前软限制，退出后不生效
2、永久生效 需要在 /etc/security/limits.conf 中设置
   或者在 /etc/security/limits.d/ 中重新创建.conf 后缀的配置文件
   
   ```BASH
   #* soft nofile 1024
   #*  hard nofile 10240  
   ```
   "*" 星号 指所有用户，可以指定用户 比如test soft nofile 1024
   并且 修改后不用重启，重新登入test用户即生效
   *soft 的值不能大于 hard 不然不能生效*
   可能需要添加:/etc/pam.d/login
   session required /lib/security/pam_limits.so #本人测试环境没有添加可以设置成功
 
3、系统限制打开文件数: /proc/sys/fs/file-max，一般不设置，如果需要设置在 /etc/rc.local中添加 `echo 10000 > /proc/sys/fs/file-max`
   /etc/sys/fs/file-nr #可以查看系统 目前 所有正在使用的 句柄数量
   /etc/sys/fs/nr_open: 单个进程可分配的文件数 默认为百万级别，如果软连接需要超过該值，此文件也需要增大

4、 ulimit -u [limit num]# 可以设置用户最多可以使用的进程数
    /etc/security/limits.d/20-nproc.conf 中 
     \*          soft    nproc     4096
     \*          hard    nproc     4096
     不设置 hard 只设置 soft会导致 到3000多就上不去了

5、 ulimit -i # maximum number of pending signals 等待最大信号 设置参数 sigpending

6、 每个进程 都可以查看limits 参数 example:cat /proc/1872/limits

7、man limits.conf #查看 ulimit用法 nofile nproc 代表的意义



8、 sysctl -a | grep nf_conntrack_max #查看 tcp 跟踪连接数限制net.nf_conntrack_max  **连接跟踪**
    编辑 /etc/sysctl.conf
    net.nf_conntrack_max = 100000 #设置 跟踪数大小 永久生效 sysctl -p 后立即生效
    echo 1000 > /proc/sys/net/netfilter/nf_conntrack_max # 当前有效，重启失效
    **此设置尽量小 会占用内核内存**

   sysctl -a | grep net.ipv4.ip_local_port_range #查看端口有效范围
   编辑 /etc/sysctl.conf
   net.ipv4.ip_local_port_range = 1024 65000 # 永久生效 需要sysctl -p 立即生效
   echo 1024 6000 >  /proc/sys/net/ipv4/ip_local_port_range # 重启失效
   **本地端口范围的最小值必须大于或等于1024；而端口范围的最大值则应小于或等于65535**


# linux java JVM


JVM: Java Virtual Machine 

## Heap(堆) 和 Non-heap(内存)

   按照官方的说法：“Java 虚拟机具有一个堆，堆是运行时数据区域，所有类实例和数组的内存均从此处分配。堆是在 Java 虚拟机启动时创建的。
”“在JVM中堆之外的内存称为非堆内存(Non-heap memory)”。
   可以看出JVM主要管理两种类型的内存：堆和非堆。简单来说堆就是Java代码可及的内存，是留给开发人员使用的；非堆就是JVM留给自己用的，
所以方法区、JVM内部处理或优化所需的内存(如JIT编译后的代码缓存)、每个类结构(如运行时常数池、
字段和方法数据)以及方法和构造方法的代码都在非堆内存中。


堆内存分配：

  JVM 初始分配的堆内存由 -Xms 指定 默认是物理内存的1/64
  JVM 最大分配堆内存由   -Xmx 指定 默认是物理内存的1/4

  默认空余堆内存小于40%时，JVM就会增大堆直到-Xmx的最大限制；
  空余堆内存大于70%时，JVM会减少堆直到-Xms的最小限制。
  因此服务器一般设置-Xms、-Xmx 相等以避免在每次GC 后调整堆的大小。
  *如果-Xmx 不指定或者指定偏小，应用可能会导致java.lang.OutOfMemory错误，此错误来自JVM，不是Throwable的，无法用try...catch捕捉。*

非堆内存分配

  JVM 初始非堆内存由 -XX:PermSize 指定 默认是物理内存的 1/64
  JVM 最大非堆内存由 -XX:MaxPermSize 指定 默认是物理内存的 1/4
  *Java HotSpot(TM) 64-Bit Server VM 取消了 PermSize 和 MaxPermsize*

  设置JAVA_OPTS="-Xms128m -Xmx1024m" 


# ? linux tomcat jconsole

* 按照 docs/monitoring.html 文件所示 搭建 JMX 远程服务
* 始终在windows 端访问不了


方法:
1、 使用无密码 认证 和 使用无密码 并且 使用 JmxRemoteLifecycleListener 进行 端口重置，并复制 catalina-ant.jar(源文件bin目录下载)
    到 ant/lib "Manage Tomcat with JMX remote Ant Tasks" 

2、 开启密码认证 一直开启 服务失败 
" java.lang.IllegalArgumentException: Expected readonly or readwrite: tomcat [controlRole tomcat]" 

以上 两种方式 由于知识不够原因 都得不到解决 ---20180126



# ？ mysql优化

* 硬件 软件 语句 架构优化


# tomcat 启动卡主

* 开启tomcat后，服务器无响应，和系统很卡，输入不了数据，并且
  tail -f /usr/local/tomcat/logs/catalina.2018-03-05.log

  ```BASH
org.apache.catalina.util.SessionIdGeneratorBase.createSecureRandom Creation of SecureRandom instance for session ID generation using [SHA1PRNG] took [192] milliseconds.
 ```

* 有一条上述的警告信息，百度查看搜索上述信息: 是由于 /dev/random 的读操作被阻塞，有2条解决方案:

1、可以通过配置JRE使用非阻塞的Entropy Source： 
在catalina.sh中加入这么一行：-Djava.security.egd=file:/dev/./urandom 即可。 
加入后再启动Tomcat，整个启动耗时下降到Server startup in 20130 ms。 
这种方案是在修改随机数获取方式，那这里urandom是啥呢？

/dev/random的一个副本是/dev/urandom（“unblocked”，非阻塞的随机数发生器[4]），它会重复使用熵池中的数据以产生伪随机数据。这表示对/dev/urandom的读取操作不会产生阻塞，但其输出的熵可能小于/dev/random的。它可以作为生成较低强度密码的伪随机数生成器，不建议用于生成高强度长期密码。 - - - wikipedia

2、在JVM环境中解决 
打开$JAVA_PATH/jre/lib/security/java.security这个文件，找到下面的内容：

securerandom.source=file:/dev/random

替换成

securerandom.source=file:/dev/./urandom

* 按照第二种方法进行修改，问题没有解决有出现下面信息
 "org.apache.catalina.core.AprLifecycleListener.lifecycleEvent The APR based Apache Tomcat Native library which allows optimal performance in production environments was not found on the java.library.path: [/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib]"

* 百度上述信息:
从操作系统级别来解决异步的IO问题,大幅度的提高性能。

必须要安装apr和native，直接启动就支持apr。

安装apr
apr需要APR库和OpenSSL相关库。


* yum install apr-devel openssl-devel  //这个apr包已经安装了所以直接操作了下面的步骤

 安装native
 进入Tomcat的bin目录，比如：

 /opt/soft/tomcat_8180/bin

 解压native源码包

 
  tar -zxvf tomcat-native.tar.gz  
  cd tomcat-native-1.1.32-src/jni/native  
  ./configure--with-apr=/usr/bin/apr-1-config--with-java-home="/opt/soft/jdk1.8.0_60" --with-ssl=yes  
  make  
  make install   
  native 会被安装到/usr/local/apr/lib
  根据信息"[/usr/java/p    ackages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib]"
 我们需要把/usr/local/apr/lib/ libtcnative-1.so.0.1.32指向Tomcat可识别路径(链接上述目录)。
* 然后启动tomcat后就正常了


# nginx 虚拟主机日志问题

* 当nginx.conf 文件里加 include vhost/*的时候放在log_format前面 则在虚拟主机定义access_log的时候
  会找不到在nginx.conf里定义的log类型
* 解决: include vhost/* 加载定义后面
