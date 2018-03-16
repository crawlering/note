# 内核调优参数 

http://blog.csdn.net/largetalk/article/details/16863689

所有 tcp/ip 调优参数都位于 /proc/sys/net


sysctl
sysctl配置与显示在/proc/sys目录中的内核参数．可以用sysctl来设置或重新设置联网功能，
如IP转发、IP碎片去除以及源路由检查等
 命令格式：

    sysctl [-n] [-e] -w variable=value

    sysctl [-n] [-e] -p <filename> (default /etc/sysctl.conf)

    sysctl [-n] [-e] -a

    常用参数的意义：

    -w   临时改变某个指定参数的值，如

         sysctl -w net.ipv4.ip_forward=1

    -a   显示所有的系统参数

    -p   从指定的文件加载系统参数，如不指定即从/etc/sysctl.conf中加载

linue 内核参数

* net.ipv4.tcp_syncookies = 1
  当SYN 队列 等待队列溢出时(不同的源地址发送来的SYN都会被分配一个特定的数据区)，开启cookies来处理
  可以防止少量的SYN 攻击(SYN FLOOD)
* net.ipv4.tcp_tw_reuse = 1
  表示开启重用， 表示将 TIME_WAIT sockets 重新用于新的tcp 连接，默认为0，表示关闭
* net.ipv4.tcp_tw_recycle = 1
  表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭。
  tcp 四次挥手的时候 先申请断开连接方最后需要等待 2MSL 时间，超过2MSL(4分钟)时间后没收到数据就断开连接
  而 net.ipv4.tcp_tw_recycle 就可以使这个连接快速挥手，这个有效于服务器端和客户端(线上不建议开启此参数)
  而 net.ipv4.tcp_tw_reuse 只是在客户端起作用
  以上需要起作用就必须在服务端和客户端开启timestamps(时间戳)，她们是由这个来判断的
  net.ipv4.tcp_timestamps = 1
* net.ipv4.tcp_max_tw_buckets = 819200
  表示系统同时保持TIME_WAIT套接字的最大数量，如果超过这个数字，TIME_WAIT套接字将立刻被清除并打印警告信息。
  默认为180000。设为较小数值此项参数可以控制TIME_WAIT套接字的最大数量，避免服务器被大量的TIME_WAIT套接字拖死。

* net.ipv4.tcp_fin_timeout = 30 //表示如果套接字由本端要求关闭，这个参数决定了它保持在FIN-WAIT-2状态的时间。
  决定 FIN-WAIT-2的时间 此状态是在收到ack 后的状态，收到对方的fin信号就会进入timeout，这个参数如果正常访问的
  情况下设置应该是没有效果的，因为这个设置的是超时时间，就会释放没有发出fin的对应的socket，默认值60


* net.ipv4.tcp_keepalive_time = 1200
  net.ipv4.tcp_keepalive_probes = 5
  net.ipv4.tcp_keepalive_intvl = 15
  keepalive_time:
  在TCP保活打开的情况下，最后一次数据交换到TCP发送第一个保活探测包的间隔，
  即允许的持续空闲时长，或者说每次正常发送心跳的周期，默认值为7200s（2h）
  keepalive_probes:
  没有接收到对方确认，继续发送保活探测包次数，默认值为9（次）
  keepalive_intvl:
  没有接收到对方确认，继续发送保活探测包的发送频率，默认值为75s

  TCP Keepalive不是TCP规范的一部分，有三点需要注意：
  1、在短暂的故障期间，它们可能引起一个良好连接（good connection）被释放（dropped）
  2、它们消费了不必要的宽带
  3、在以数据包计费的互联网消费（额外）花费金钱
  解决问题: 在客户端出现异常中断的时候可以释放相应资源

* net.ipv4.ip_local_port_range = 1024 65000
  //表示用于向外连接的端口范围。缺省情况下很小：32768到61000，改为1024到65000。
  net.ipv4.tcp_max_syn_backlog = 8192 
  //表示SYN队列的长度，默认为1024，加大队列长度为8192，可以容纳更多等待连接的网络连接数
  
  net.ipv4.ip_conntrack_max = 655360 
  在内核内存中netfilter可以同时处理的“任务”（连接跟踪条目）another voice-
  不要盲目增加ip_conntrack_max: http://blog.csdn.net/dog250/article/details/7107537 
  net.ipv4.netfilter.ip_conntrack_tcp_timeout_established = 180
  跟踪的连接超时结束时间

* net.core.somaxconn = 262144
  //定义了系统中每一个端口最大的监听队列的长度, 对于一个经常处理新连接的高负载 web服务环境来说，
    默认的 128 太小了;服务进程会自己限制侦听队列的大小(例如 sendmail(8) 或者 Apache)，
    常常在它们的配置文件中有设置队列大小的选项。大的侦听队列对防止拒绝服务 DoS 攻击也会有所帮助。

* net.core.netdev_max_backlog = 262144
  //该参数决定了, 每个网络接口接收数据包的速率比内核处理这些包的速率快时，
   允许送到队列的数据包的最大数目, 不要设的过大
   默认1000

* net.ipv4.tcp_max_orphans = 262144
  //系统所能处理不属于任何进程的TCP sockets最大数量。假如超过这个数量，
   那么不属于任何进程的连接会被立即reset，并同时显示警告信息。之所以要设定这个限制﹐
   纯粹为了抵御那些简单的 DoS 攻击﹐千万不要依赖这个或是人为的降低这个限制，
   更应该增加这个值(如果增加了内存之后)。每个孤儿套接字最多能够吃掉你64K不可交换的内存。
   默认值 4096
* net.ipv4.tcp_orphan_retries = 3
  本端试图关闭TCP连接之前重试多少次。缺省值是7，相当于50秒~16分钟(取决于RTO)。
  如果你的机器是一个重载的WEB服务器，你应该考虑减低这个值，
  因为这样的套接字会消耗很多重要的资源。参见tcp_max_orphans.
* net.ipv4.tcp_timestamps = 0
  时间戳,0关闭， 1开启，在(请参考RFC 1323)TCP的包头增加12个字节, 
  关于该配置对TIME_WAIT的影响及可能引起的问题: http://huoding.com/2012/01/19/142 ,
  Timestamps 用在其它一些东西中﹐可以防范那些伪造的 sequence 号码。一条1G的宽带线路或许会重遇到带
  out-of-line数值的旧sequence 号码(假如它是由于上次产生的)。Timestamp 会让它知道这是个 ‘旧封包’。
  (该文件表示是否启用以一种比超时重发更精确的方法（RFC 1323）来启用对 RTT 的计算；
  为了实现更好的性能应该启用这个选项。) 上面 启用sockets快速回收 recycle和rereuse需要该打开该参数

* net.ipv4.tcp_synack_retries = 1
  tcp_synack_retries 显示或设定 Linux 核心在回应 SYN 要求时会尝试多少次重新发送初始 SYN,ACK 封包后才决定放弃。这是所谓的三段交握 (threeway handshake) 的第二个步骤。即是说系统会尝试多少次去建立由远端启始的 TCP 连线。tcp_synack_retries 的值必须为正整数，并不能超过 255。因为每一次重新发送封包都会耗费约 30 至 40 秒去等待才决定尝试下一次重新发送或决定放弃。tcp_synack_retries 的缺省值为 5，即每一个连线要在约 180 秒 (3 分钟) 后才确定逾时.

* net.ipv4.tcp_syn_retries = 1
  对于一个新建连接，内核要发送多少个 SYN 连接请求才决定放弃。不应该大于255，默认值是5，对应于180秒左右时间。(对于大负载而物理通信良好的网络而言,这个值偏高,可修改为2.这个值仅仅是针对对外的连接,对进来的连接,是由tcp_retries1 决定的)

* net.ipv4.tcp_retries1 = 3
  放弃回应一个TCP连接请求前﹐需要进行多少次重试。RFC 规定最低的数值是3﹐这也是默认值﹐根据RTO的值大约在3秒 - 8分钟之间。(注意:这个值同时还决定进入的syn连接)

* net.ipv4.tcp_sack = 1
  使 用 Selective ACK﹐它可以用来查找特定的遗失的数据报— 因此有助于快速恢复状态。该文件表示是否启用有选择的应答（Selective Acknowledgment），这可以通过有选择地应答乱序接收到的报文来提高性能（这样可以让发送者只发送丢失的报文段）。(对于广域网通信来说这个选项应该启用，但是这会增加对 CPU 的占用。)

* net.ipv4.tcp_fack = 1
  打开FACK拥塞避免和快速重传功能。(注意，当tcp_sack设置为0的时候，这个值即使设置为1也无效)
  启用转发应答，可以进行有选择应答（SACK）从而减少拥塞情况的发生，这个选项也应该启用。

* net.ipv4.tcp_dsack = 1
  允许TCP发送”两个完全相同”的SACK。

* net.ipv4.conf.default.rp_filter = 1
  net.ipv4.conf.all.rp_filter = 1
  通过反向路径进行源验证
  设置0 则不进行源验证，开启源验证，使用缓慢的 RIP 协议 或者复杂的静态路由可能 回引起网路问题

* net.ipv6.conf.all.disable_ipv6 = 1
  net.ipv6.conf.default.disable_ipv6 = 1
  停用 ipv6 模块

* vm.swappiness=5
  默认60，控制交换空间的使用，值越大，就劲量及时的把内存的数据搬到此处，越小，就劲量把数据放在内存中

* net.ipv4.tcp_rmem = 4096 87380 8388608
  net.ipv4.tcp_wmem = 4096 87380 8388608
  net.ipv4.tcp_mem = 196608       262144  393216
  rmem和wmen:为每个TCP连接分配的读、写缓冲区内存大小，单位是Byte
  第一个数字表示，为TCP连接分配的最小内存
  第二个数字表示，为TCP连接分配的缺省内存
  第三个数字表示，为TCP连接分配的最大内存
  一般按照缺省值分配，上面的例子就是读写均为86KB，共172KB
  1.72G内存 能容纳的 连接数为: 1720M/172kb=10x1000=1w个连接
  tcp_mem:
  第一个数字表示，当 tcp 使用的 page 少于 196608 时，kernel 不对其进行任何的干预
  第二个数字表示，当 tcp 使用了超过 262144 的 pages 时，kernel 会进入 “memory pressure” 压力模式
  第三个数字表示，当 tcp 使用的 pages 超过 393216 时（相当于1.6GB内存），就会报：Out of socket memory

* 套接字 缓存设置
  net.core.rmem_max = 8388608
  net.core.wmem_max = 8388608
  /proc/sys/net/core/rmem_default  
  /proc/sys/net/core/rmem_max  

  若没有调用setsockopt设置系统接收缓存,则接收缓存的大小为rmem_default.  
  若程序调用setsockopt设置系统接收缓存,设置值不能超过rmem_max.  
  系统会为每个 socket申请一份缓存空间,而不是共用同一份缓存(2倍的rmem_default，因为有读写).  
  即每个 socket都会有一个rmem_default大小的缓存空间(假设没有setsockopt设置) 上面tcp_rmem设置的是自动调优参数
  /proc/sys/net/core/optmem_max ? 不知道和rmem_max有何异同
  该文件表示每个套接字所允许的最大缓冲区的大小。
   
* net.ipv4.tcp_window_scaling = 1  
  0关闭tcp_window_scaling
  1启用 RFC 1323 定义的 window scaling；要支持超过 64KB 的窗口，必须启用该值。


## 文件数限数

* file-max：该参数表示文件句柄的最大数量。文件句柄设置表示在linux系统中可以打开的文件数量。
  /proc/sys/fs/file-nr： 928	0	98542  
  它有三个值：
  已分配文件句柄的数目
  已使用文件句柄的数目
  文件句柄的最大数目
  该参数只读，不修改
 /etc/security/limits.conf 是 Linux 资源使用配置文件，用来限制用户对系统资源的使用
 语法：<domain>  <type>  <item>  <value>

```BASH
root soft nproc 65535      # 警告设定root用户最大打开进程数为65535
root hard nproc 65535      # 严格设定root用户最大打开进程数为65535
* soft nofile 65535     # 警告设定所有用户最大打开文件数为65535
* hard nofile 65535     # 严格设定所有用户最大打开文件数为65535	
//<domain> 表示要限制的用户，可以是：

         ① 用户名
         ② 组名（组名前面加'@'以区别用户名）
         ③ *（表示所有用户）

<type> 有两个值：

         ① soft 表示警告的设定，可以超过这个设定值，但是超过会有警告信息
         ② hard 表示严格的设定，必定不能超过这个设定的值

<item> 表示可选的资源，如下：

         ① core：限制内核文件的大小
         ② data：最大数据大小
         ③ fsize：最大文件大小
         ④ memlock：最大锁定内存地址空间
         ⑤ nofile：打开文件的最大数目
         ⑥ rss：最大持久设置大小
         ⑦ stack：最大栈大小
         ⑧ cpu：以分钟为单位的最多CPU时间
         ⑨ nproc：进程的最大数目
         ⑩ as：地址空间限制

<value> 表示要限制的值
```



## Nginx配置优化

 介绍nginx变量和配置很好的文档： http://openresty.org/download/agentzh-nginx-tutorials-zhcn.html

* nginx.conf

```BASH
#运行用户
user www-data;

#nginx进程数，建议和CPU总核心数相同
worker_processes 4;

pid /run/nginx.pid;

#一个nginx进程打开的最多文件描述符数目，理论值应该是最多打开文件数（系统的值ulimit -n）与nginx进程数相除，但是nginx分配请求并不均匀，所以建议与ulimit -n的值保持一致。
worker_rlimit_nofile 65535;

#工作模式与连接数上限
events {
    #单个进程最大连接数（最大连接数=连接数*进程数）
    worker_connections 65535;

    #参考事件模型，use [ kqueue | rtsig | epoll | /dev/poll | select | poll ]; epoll模型是Linux 2.6以上版本内核中的高性能网络I/O模型
    use epoll;

    #是否允许Nginx在已经得到一个新连接的通知时，接收尽可能更多的连接。缺省：off
    # multi_accept on;
}

http {

    ##
    # Basic Settings
    ##

    #开启高效文件传输模式，sendfile指令指定nginx是否调用sendfile函数来输出文件，对于普通应用设为 on，
    #如果用来进行下载等应用磁盘IO重负载应用，可设置为off，以平衡磁盘与网络I/O处理速度，降低系统的负载。
    sendfile on;
    #当使用sendfile函数时，tcp_nopush才起作用，它和指令tcp_nodelay是互斥的。
    tcp_nopush on;
    #设置套接字的TCP_NODELAY = on 选项来完成，这样就禁用了Nagle 算法
    tcp_nodelay on;
    #客户端超时时间，这里不是指整个传输过程的时间， 而是指客户端两个读操作之间的时间，即如果客户端超过这么长时间没有读任何数据，nginx关闭该连接
    send_timeout 60;
    #设置http头中的Keep-Alive
    keepalive_timeout 65;
    #set the maximum size of the types hash tables
    types_hash_max_size 2048;
    #隐藏nginx服务器系统版本等信息
    # server_tokens off;

    #指定一个request可接受的body大小,即请求头里的Content-Length. 如果请求body超过该值，nginx返回413("Request Entity Too Large")
    client_max_body_size 10M;
    #客户端请求头部的缓冲区大小，这个可以根据你的系统分页大小来设置，一般一个请求头的大小不会超过1k
    client_header_buffer_size 4k;
    #指定允许为客户端请求头最大分配buffer个数和大小.
    large_client_header_buffers 8 128k;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;


    #文件扩展名与文件类型映射表
    include /etc/nginx/mime.types;
    #默认文件类型
    default_type application/octet-stream;

    ##
    # Logging Settings
    ##

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    #开启gzip压缩输出
    gzip on;
    #最小压缩文件大小
    gzip_min_length 1k;
    #压缩缓冲区
    gzip_buffers 16 8k;
    #压缩版本
    gzip_http_version 1.1;
    #压缩等级
    gzip_comp_level 6;
    #ie6 不压缩
    gzip_disable "msie6";
    #Enables response header of "Vary: Accept-Encoding".
    gzip_vary on;
    #Nginx作为反向代理时，启用或关闭压缩上游服务器返回内容的选项
    # gzip_proxied any;
    #压缩类型
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    ##
    # Proxy Global Settings
    ##

    #是否开启buffer， 为on时，尽可能从后端读数据存如buffer， 为off时，收到后端数据立即转发给客户端, 对于long-polling应用，需要关闭proxy_buffering
    proxy_buffering on;
    #存放后端服务器返回结果的buffer大小
    proxy_buffer_size 4k;
    #存放后端服务器返回结果的buffer 个数和大小, buffer满时会写到临时文件
    proxy_buffers 8 4k;
    #可以处于busy状态的buffer总和，它控制了同时传输到客户端的buffer数量
    proxy_busy_buffers_size 16k;
    #定义了跟代理服务器连接的超时时间,必须留意这个time out时间不能超过75秒
    proxy_connect_timeout 60s;
    #headers hash table bucket大小，如果headers名称大于64字符，需要增加此值
    proxy_headers_hash_bucket_size 64;
    #headers hash table大小
    proxy_headers_hash_max_size 512;
    proxy_http_version 1.0;
    #指定nginx等待后端返回数据最长时间，该timeout并不是指整个response时间，而是指两次读之间的时间
    proxy_read_timeout 60s;
    #nginx传送请求到后端最大时间，该timeout并不是指整个传输时间，而是指两次写之间的时间
    proxy_send_timeout 30s;

    ##
    # open file optimize
    ##

    #max指定缓存最大文件数，inactive指定缓存失效时间，如在这段时间文件没被下载，移除缓存
    open_file_cache max=102400 inactive=20s;
    #指定多长时间检查一下open_file_cache中文件的有效性
    open_file_cache_valid    60s;
    #指定了在open_file_cache指令无效的参数中一定的时间范围内可以使用的最小文件数， 如果使用更大的值，文件描述符在cache中总是打开状态
    open_file_cache_min_uses 1;
    #是否cache搜索文件的错误
    open_file_cache_errors   on;


    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

