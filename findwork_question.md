2018-04-18 18:47:57
1、内核优化 tcp syn 连接数 内存 队列 设定
2、nginx 
   cache(proxy_cache 设定cache)
   cache生存时间设定
   502错误怎么解决
3、iptables 端口转发
4、memcache 连接 nginx
5、100台服务器怎么更新里面的文件
6、stacksalt
7、如果有人爬网站怎么解决
8、正在使用的文件被删除了怎么恢复。


2、nginx 
   1. proxy_cache ：指定使用哪个共享内存区域存储缓存键和相关信息； 
   2. proxy_cache_key ：设置缓存使用的key，默认为访问的完整URL，根据实际情况设置缓存key； 
   3. proxy_cache_valid ：为不同的响应状态码设置缓存时间；如果是proxy_cache_valid 5s 则200、301、302响应将被缓存；

   proxy_cache_valid 
   proxy_cache_valid不是唯一设置缓存时间的，还可以通过如下方式（优先级从上到下）： 
   以秒为单位的“X-Accel-Expires”响应头来设置响应缓存时间
   如果没有“X-Accel-Expires”，可以根据“Cache-Control”、“Expires”来设置响应缓存时间
   否则使用proxy_cache_valid设置的缓存时间

   502 一般查看php pool连接池数量限制或者php是否停止运行
3、iptables 端口转发:
   echo  1 > /proc/sys/net/ipv4/ip_forward  
   iptables -t nat  -A PREROUTING  -d   172.168.100.7 -p tcp --dport 80  -j  DNAT --to-destination 192.168.100.9
   iptables -t nat  -A POSTROUTING   -d 192.168.100.9 -p tcp --dport 80 -j  SNAT --to-source  172.168.100.7 
   或者 iptables -t nat  -A POSTROUTING   -d 192.168.100.9 -p tcp --dport 80 -j  MASQUERADE 

  端口转发:重定向:iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

  举例:从192.168.0.132:21521(新端口)访问192.168.0.211:1521端口
   

   a.同一端口转发(192.168.0.132上开通1521端口访问 iptables -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 1521 -j ACCEPT)
   iptables -t nat -I PREROUTING -p tcp --dport 1521 -j DNAT --to 192.168.0.211
   iptables -t nat -I POSTROUTING -p tcp --dport 1521 -j MASQUERADE

   b.不同端口转发(192.168.0.132上开通21521端口访问 iptables -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 21521 -j ACCEPT)
   iptables -t nat -A PREROUTING -p tcp -m tcp --dport 21521 -j DNAT --to-destination 192.168.0.211:1521
   iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -d 192.168.0.211 -p tcp -m tcp --dport 1521 -j SNAT --to-source 192.168.0.132

 iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 9999 -j DNAT --to 47.75.74.16:22

4、memcahce连接通过php中memcache.so模块
5、6、 stacksalt使用
7、如果有人爬网站怎么解决(https://blog.csdn.net/u012164361/article/details/69817630)
   爬虫修改请求头 去实现仿照浏览器爬取
   普通的禁止就是禁止爬虫的非法头部,使用http_user_agent 禁止一些agent访问 
   if ($http_user_agent ~* (Scrapy|Curl|HttpClient)) {  
        return 403;  
	} 
   if ($http_user_agent ~* Spider/3.0|YoudaoBot)
   {
       return 403;
   }
   #禁止非GET|HEAD|POST方式的抓取  
   if ($request_method !~ ^(GET|HEAD|POST)$) {  
       return 403;  
       }  

   使用iptables限制 同一个ip 5S 之内20个连接，在服务器性能之内，超过了就丢包
   再就是禁止ip
   tcp_max_syn_backlog 最大连接数增大
   net.ipv4.tcp_max_syn_backlog = 1024

   net.ipv4.tcp_syncookies = 1

   net.ipv4.tcp_synack_retries = 5

   net.ipv4.tcp_syn_retries = 5
   http://netsecurity.51cto.com/art/201406/442756.htm
   减轻DDOS攻击工具 deflate 可以设置检测时间默认1分分钟
   最大连接数 白名单 禁用ip时间

8、正在使用的文件被删除了怎么恢复。(比如/var/log/messages)
   lsof  | grep /var/log/messages  查处该文件调用进程 和 对应的文件描述符
   rsyslogd    464          root    4w      REG              253,1     80853     262321 /var/log/messages
   in:imjour   464   472    root    4w      REG              253,1     80853     262321 /var/log/messages
   rs:main     464   492    root    4w      REG              253,1     80853     262321 /var/log/messages

   pid:464 文件描述符:4
   文件恢复: cat /proc/464/fd/4 > /var/log/messages
   然后修改下权限。


9、 pv 物理卷 vg 卷组 lv 逻辑卷
   创建物理卷 卷组 逻辑卷 pvcreate vgcreate lvcreate
   lvresize -L 2000M /dev/vg1/lv1 扩容逻辑卷
   resize2fs /dev/vg1/lv1 更新逻辑卷信息
   缩减需要卸载逻辑卷组
   扩展卷组:
   分区	磁盘 fdisk /dev/sdb
   pvcreate /dev/sdb5
   vgextend vg1 /dev/sdb5 把物理卷加入卷组 
   扩容LVM:首先 把磁盘分区，把分区创建到物理卷，然后把物理卷加入到卷组，卷组相当于一个lv逻辑卷池，分配逻辑卷大小
   通过lvresize

 10、nfs : nfs-util rpcbind(portmap) 服务端 nfs-util 客户端
     配置文件 /etc/exports
     启动服务: start rpcbind 和 nfs
     showmount -e ip
     mount -t nfs ip:dir /tmp
     exports -arv //修改配置文件不用重启服务生效
