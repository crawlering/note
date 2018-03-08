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


# tomcat 启动卡住

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

2018-03-07 15:43:14
* 后来翻阅资料才知道是因为把2个虚拟主机 一个设置的和1个localhost的主机 appbase都设置在同一个目录下(webappas)
  引起的



# nginx 虚拟主机日志问题

* 当nginx.conf 文件里加 include vhost/*的时候放在log_format前面 则在虚拟主机定义access_log的时候
  会找不到在nginx.conf里定义的log类型
* 解决: include vhost/* 加载定义后面


# nginx 虚拟主机重定向和 代理 负载均衡

* 虚拟机重定向，不可以重定向端口，端口不能变
* 做端口转发可以使用代理，

```BASH
server
{
    listen 80;
    server_name www.ceshizu5.com;
    index index.html index.htm index.php;
    root /data/www;
    charset utf-8;
    
    access_log	logs/access.log	combined_realip;
    
    location ~ "zrlog*" {      

        proxy_pass http://www.ceshizu5.com:8080; 
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 
       } 


    location ~ \.php$
    {
        include fastcgi_params;
        fastcgi_pass unix:/tmp/php-fcgi.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /data/www$fastcgi_script_name;
    }
}
//意思是访问www.ceshizu5.com/zrlog 就会转到8080端口的服务器，需要在/etc/hosts 设置:本机ip www.ceshizu5.com
如果是个可以解析的域名应该就可以不这样做设置 
```
* 使用代理(就是负载均衡只有一台机子) 可以在/etc/hosts 添加代理IP地址信息
* 均衡负载就要设置upsteam信息

```BASH
upstream qq_com
{
    ip_hash;
    server 61.135.157.156:80;
    server 125.39.240.113:80;
}
server
{
    listen 80;
    server_name www.qq.com;
    access_log logs/2.log combined_realip;
    location /
    {
        proxy_pass      http://qq_com;
        proxy_set_header Host   $host;
        proxy_set_header X-Real-IP      $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
//需要加http不然会报错
```

# nginx 内置变量信息

* nginx查看变量信息可以 编译echo有关模块，可以echo查看
* 还可以把变量打到日志里 进行查看(加到定义日志的地方)

```bash
$args                      请求中的参数;
$binary_remote_addr        远程地址的二进制表示
$body_bytes_sent           已发送的消息体字节数
$content_length            HTTP请求信息里的"Content-Length";
$content_type              请求信息里的"Content-Type";
$document_root             针对当前请求的根路径设置值;
$document_uri				与$uri相同;
$host                      请求信息中的"Host"，如果请求中没有Host行，则等于设置的服务器名;
$hostname      
$http_cookie               cookie 信息
$http_post     
$http_referer              引用地址
$http_user_agent           客户端代理信息
$http_via                  最后一个访问服务器的Ip地址。
$http_x_forwarded_for      相当于网络访问路径。
$is_args       
$limit_rate                对连接速率的限制;
$nginx_version     
$pid       
$query_string				与$args相同;
$realpath_root     
$remote_addr               客户端地址;
$remote_port               客户端端口号;
$remote_user               客户端用户名，认证用;
$request                   用户请求
$request_body      
$request_body_file         发往后端的本地文件名称
$request_completion        
$request_filename          当前请求的文件路径名
$request_method            请求的方法，比如"GET"、"POST"等;
$request_uri               请求的URI，带参数;
$scheme						所用的协议，比如http或者是https，
                                               比如rewrite^(.+)$$scheme://example.com$1redirect;
$sent_http_cache_control   1
$sent_http_connection  
$sent_http_content_length  
$sent_http_content_type    
$sent_http_keep_alive      
$sent_http_last_modified       
$sent_http_location        
$sent_http_transfer_encoding       
$server_addr               服务器地址，如果没有用listen指明服务器地址，使用这个变量将发起一次系统调用以取得地址(造成资源浪费);
$server_name               请求到达的服务器名;
$server_port               请求到达的服务器端口号;
$server_protocol           请求的协议版本，"HTTP/1.0"或"HTTP/1.1";
$uri                       请求的URI，可能和最初的值有不同，比如经过重定向之类的。
```



# nginx location 正则匹配

location指令是http模块当中最核心的一项配置，根据预先定义的URL匹配规则来接收用户发送的请求，根据匹配结果，将请求转发到后台服务器、非法的请求直接拒绝并返回403、404、500错误处理等。

2、location指令语法
location [=|~|~*|^~|@] /uri/ { … } 或 location @name { … }

3、URI匹配模式
location指令分为两种匹配模式： 
1> 普通字符串匹配：以=开头或开头无引导字符（～）的规则 (普通匹配又区分为=的精准匹配，和模糊匹配)
2> 正则匹配：以～或～*开头表示正则匹配，~*表示正则不区分大小写

4、location URI匹配规则
当nginx收到一个请求后，会截取请求的URI部份，去搜索所有location指令中定义的URI匹配模式。在server模块中可以定义多个location指令来匹配不同的url请求，多个不同location配置的URI匹配模式，总体的匹配原则是：先匹配普通字符串模式，再匹配正则模式。只识别URI部份，例如请求为：/test/abc/user.do?name=xxxx 

**一个请求过来后，Nginx匹配这个请求的流程如下：**

1> 先查找是否有=开头的精确匹配，如：location = /test/abc/user.do { … } 
2> 再查找普通匹配，以 最大前缀 为原则，如有以下两个location，则会匹配后一项 
* location /test/ { … } 
* * location /test/abc { … } 
* 3> 匹配到一个普通格式后，搜索并未结束，而是暂存当前匹配的结果，并继续搜索正则匹配模式 
* 4> 所有正则匹配模式location中找到第一个匹配项后，就以此项为最终匹配结果 
* 所以正则匹配项匹配规则，受定义的前后顺序影响，但普通匹配模式不会 
* 5> 如果未找到正则匹配项，则以3中缓存的结果为最终匹配结果 
* 6> 如果一个匹配都没搜索到，则返回404
*
* 5、精确匹配与模糊匹配差别
* location =/ { … } 与 location / { … } 的差别： 
* * 前一个是精确匹配，只响应/请求，所有/xxx或/xxx/xxxx类的请求都不会以前缀的形式匹配到它 
* * 后一个是只要以 / 为前缀的请求都会被匹配到。如：/abc ， /test/abc， /test/abc/aaaa


* 6、正则与非正则匹配
* 1> location ~ /test/.+.jsp$ { … } ：正则匹配，支持标准的正则表达式语法。 
* 2> location ^~ / { … } ： ^~意思是关闭正则匹配，当搜索到这个普通匹配模式后，将不再继续搜索正则匹配模式。
