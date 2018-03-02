
十五周一次课（1月26日）
18.1 集群介绍
18.2 keepalived介绍
18.3/18.4/18.5 用keepalived配置高可用集群

扩展
heartbeat和keepalived比较http://blog.csdn.net/yunhua_lee/article/details/9788433 

  
DRBD工作原理和配置   http://502245466.blog.51cto.com/7559397/1298945 

 mysql+keepalived http://lizhenliang.blog.51cto.com/7876557/1362313 

------------------------------------------------------------------------
十五周二次课（1月29日）
18.6 负载均衡集群介绍
18.7 LVS介绍
18.8 LVS调度算法
18.9/18.10 LVS NAT模式搭建

扩展
lvs 三种模式详解  http://www.it165.net/admin/html/201401/2248.html 

 
lvs几种算法 http://www.aminglinux.com/bbs/thread-7407-1-1.html 

关于arp_ignore和 arp_announce http://www.cnblogs.com/lgfeng/archive/2012/10/16/2726308.html 

lvs原理相关的   http://blog.csdn.net/pi9nc/article/details/23380589 

-------------------------------------------------------------------------

十五周三次课（1月30日)
18.11 LVS DR模式搭建
18.12 keepalived + LVS

扩展
haproxy+keepalived  http://blog.csdn.net/xrt95050/article/details/40926255 

nginx、lvs、haproxy比较  http://www.csdn.net/article/2014-07-24/2820837 

keepalived中自定义脚本 vrrp_script   http://my.oschina.net/hncscwc/blog/158746 

lvs dr模式只使用一个公网ip的实现方法   http://storysky.blog.51cto.com/628458/338726 

-------------------------------------------------------------------------------------


#linux 集群架构


概述:

* 根据功能划分可分为两大类: 高可用、 负载均衡


高可用集群:

* 高可用集群通常两台服务器，一台工作，另外一台作为冗余，当提供服务的机器宕机，冗余将接替继续提供服务器
* 实现高可用的开源软件有: heartbeat keepalived


负载均衡集群:

* 需要一台服务器作为分发起，他负责把用户的请求分发给后端服务器处理，除了分发器外，就是给用户提供的服务器了，该服务器至少为2台
* 实现负载均衡的开源软件有LVS,keepalived、haproxy、nginx, 商业的有F5、Netscaler


*根据上面介绍，初步认识，可知:1、分发器需要做高可用，2、负载均衡只是提供了负载均衡，可能其中某台服务器出现问题会导致问题，所以可能的话对每个服务器再做高可用，那么资源消耗为2x台服务器，还可以对整体负载均衡服务进行高可用，其中用1到2台设备进行自适应高可用，当设备启动高可用后进行报警*


## 高可用 keepalived

keepalived介绍:

* keepalived 通过 VRRP(Virtual Router Redundancy Protocal) 来实现高可用 *redundancy：冗余*
* 这个协议里会讲多台功能相同的路由其组成一个小组，这个小组里会有1个master 和 N （N>=1） 个 backup 角色
* master 会通过 组播 的形式向各个 buckup 发送 VRRP 协议的数据包， 当 backup 收不到 master 发送来的 VRRP数据包时，就会认为master
  宕机了，此时需要根据各个backup的优先级来决定谁会成为新的master


* keepalived需要三个模块，分别 croe check vrrp ，其中core模块为keepalived 的核心，负责进程的启动，维护以及全局配置文件的加载和
  解析，check模块负责健康检查，有就是master是否宕机，vrrp 模块是来实现VRRP 协议的


## 使用 keepalived 进行实验

1、 准备两台服务器机器master 为A ip为 31.20， buckup 为B ip为 31.21, vip(为整个服务对外的访问的虚拟IP): 31.100
2、 两台机器进行安装keepalived: yum -y install keepalived
3、 两台机器安装nginx，其中A 进行编译安装，B 使用 yum -y install nginx 安装即可
4、 编辑 A 上的配置文件: vim /etc/keepalived/keepalived.conf


```BASH 

global_defs {
#定义接收邮件
   notification_email {
     aming@aminglinux.com
   }
#定义发送邮件
   notification_email_from root@aminglinux.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}
#定义监控ngnix服务的脚本
vrrp_script chk_nginx {
    script "/usr/local/sbin/check_ng.sh"
    interval 3
}
#自定义master 角色名 监听哇咔 权重 以及密码 VIP 加载上面的定义的监控脚本
vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.31.100
    }
    track_script {
        chk_nginx
    }
}

```

5、 监控脚本编辑: 

```BASH

#!/bin/bash
#时间变量，用于记录日志
d=`date --date today +%Y%m%d_%H:%M:%S`
#计算nginx进程数量
n=`ps -C nginx --no-heading|wc -l`
#echo "file is running==========" >> /var/log/messages
#echo $? >> /tmp/messages
#echo `who am i`xxx >> /tmp/messages
#如果进程为0，则启动nginx，并且再次检测nginx进程数量，
#如果还为0，说明nginx无法启动，此时需要关闭keepalived
if [ $n -eq "0" ]; then
#        echo start >> /tmp/messages
#        /etc/init.d/nginx start
#        echo $? >> /tmp/messages
#        echo `who am i`ssssss >> /tmp/messages
        n2=`ps -C nginx --no-heading|wc -l`
        sleep 2
        if [ $n2 -eq "0"  ]; then
#                echo "over" >> /tmp/messages
                echo "$d nginx down,keepalived will stop" >> /tmp/messages
#                systemctl stop keepalived #这些命令都执行不了，执行没有权限
        fi
fi

```

6、 编辑B 上的配置文件: vim /etc/keepalived/keepalived.conf

```bash
global_defs {
   notification_email {
     1193630409@qq.com
   }
   notification_email_from root@aminglinux.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}
vrrp_script chk_nginx {
    script "/usr/local/sbin/check_ng.sh"
    interval 3
}
vrrp_instance VI_1 {
    state BACKUP     # 不一样的地方
    interface ens33
    virtual_router_id 51  #不一样的地方设置编号
    priority 90            #设置级别
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass aminglinux>com
    }
    virtual_ipaddress {
        192.168.31.100
    }
    track_script {
        chk_nginx
    }
}

```

7、 编辑B上的 监控脚本: 内容和A的 一致

## 测试高可用

* 两台机器都运行keepalived服务
* 先确定好两台机器上nginx差异，比如可以通过curl -I 来查看nginx版本
* 测试1：关闭master上的nginx服务
* 测试2：在master上增加iptabls规则 
* iptables -I OUTPUT -p vrrp -j DROP
* 测试3：关闭master上的keepalived服务
* 测试4：启动master上的keepalived服务
* ip addr 查看 vip:31.100


## 负载均衡 集群 介绍
 
* 主流开源软件LVS keepalived(包含LVS) haproxy nginx 等
* LVS 属于4层(网络OSI 7层模型)，nginx 属于7层， haproxy既可以认为是4层，也可以当作7层使用
* keepalived 负载均衡功能 其实就是使用的LVS
* LVS 这种4层的负载均衡可以分发除80端口外的其他端口同性，比如 mysql， 而nginx 仅仅支持http https mail，haproxy也支持mysql
* 相比较来说 LVS这种4层的更稳定，能承受更多的请求，而nginx这种7层的更加灵活，能实现更多的个性化需求

### LVS 介绍

* LVS 是由国人 章文嵩 开发，流行度不亚于apache 的httpd，基于TCP/IP的路由和转发，稳定性和效率很高
* LVS 最新版本呢基于 linux 内核2.6，有好多年不更新了
* LVS 有三种常见的模式: NAT DR IP Tunnel
* LVS 架构中有一个核心的角色 叫做 分发器(Load balance)，他用来分发用户的请求，还有诸多的处理用户请求的服务器(Real Server，简称rs)

 
### LVS NAT 模式

* 这种模式 借助 iptables 的 nat  表来实现
* 用户的请求到分发器后，通过预设的 iptables规则，把请求的数据报转发到后端的 rs上去
* rs 需要设定网关为分发器的内网ip
* 用户请求数据报和返回给用户的数据报全部经过分发器，所以分发器成为瓶颈
* 在nat模式中，只需要分发器有公网ip即可，所以比较节省公网ip资源


### LVS IP Tunnel模式

* 这种模式，需要有一个公共的IP 配置在分发器和所有rs上，我们把他叫做VIP
* 客户端请求到目标vip，分发器接收到请求数据报后，会对数据报做一个加工，会把目标IP改成rs的IP，这样数据报就到了rs上
* rs接收数据报后，会还原原始数据报，这样目标为vip，这样目标为vip，因为所有rs上配置了这个vip，所以他会认为他是自己
？

### LVS DR 模式

* 这种模式，也需要有一个公共的IP 配置在分发器和所有rs上，也就是vip，
* 和IP Tunnel不同的是，他会把数据报的MAC地址修改为rs的MAC地址
* rs接收数据包后，会还原数据报，这样目标IP为vip，因为所有rs上配置了这个vip，所以他会认为是他自己


### LVS调度算法
 
* 轮询 Round-Robin rr
* 加权轮询 Weight Round-Robin wrr
* 最小连接 Least-Connection lc
* 加权最小连接 Weight Least-Connection wlc
* 基于局部性的最小连接 Locality-Based Least Connections lblc
* 带复制的基于局部性最小连接 Locality-Based Least Connections with Replication  lblcr
* 目标地址散列调度 Destination Hashing dh
* 源地址散列调度 Source Hashing  sh


## NAT 模式搭建
 
环境:

* 三台机器
* 分发器（调度器 dir）
* 内网: 31.20 外网:0.20
* rs1 内网: 31.21
* rs2 内网: 31.22

* 三台机器都执行  systemctl stop firewalld; systemc disable firewalld
  systemctl start  iptables-services; iptables -F; 
  service iptables save  关闭防火墙，防止干扰实验


* 在dir 上 安装 ipvsadm: yum -y install ipvsadm
* 在dir上 编写脚本，vim /usr/local/sbin/lvs_nat.sh，给脚本执行权限：chmod 755 /usr/local/sbin/lvs_nat.sh

```bash
#! /bin/bash
# director 服务器上开启路由转发功能
echo 1 > /proc/sys/net/ipv4/ip_forward
# 关闭icmp的重定向
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects #暂时没有发现有什么用
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
# 注意区分网卡名字，两个网卡分别为ens33和ens37
echo 0 > /proc/sys/net/ipv4/conf/ens33/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/ens37/send_redirects
# director 设置nat防火墙
iptables -t nat -F
iptables -t nat -X
iptables -t nat -A POSTROUTING -s 192.168.31.0/24  -j MASQUERADE
# director设置ipvsadm
IPVSADM='/usr/sbin/ipvsadm'
$IPVSADM -C
$IPVSADM -A -t 192.168.0.20:80 -s wlc -p 3
$IPVSADM -a -t 192.168.0.20:80 -r 192.168.31.21:80 -m -w 1
$IPVSADM -a -t 192.168.0.20:80 -r 192.168.31.22:80 -m -w 1
```

* rs1 rs2 装好nginx 并启动 nginx服务
* 设置两台rs的主页，做一个区分，也就是说直接curl两台rs的ip时，得到不同的结果
* 浏览器里访问192.168.0.20，多访问几次看结果差异


问题:
* 在本机访问前面一段时间没有问题，但是在其他机器访问 0.20 后 ipvsadm -lc 可以看到有 SYN_RECV 状态，以后就访问失败
   此情况抓包分析有两种情况:tcpdump -s 0 -nn  -i ens33 host 192.168.0.20
   1、”ARP, Request who-has 192.168.31.22 tell 192.168.0.20, length 46“ rs主机根本没有搜到 访问请求
   2、"IP 192.168.0.20.33196 > 192.168.31.22.80: Flags [S], seq 2606770291, win 43690, options [mss 65495,sackOK,TS val 118504481 ecr 0,nop,wscale 7], length 0" 收到请求但是没有 回复(tcp 握手 没有 seq +ack)
   解决: 设置 rs GATEWAY 为 路由主机的内网IP，或者 手动配置 route add default gw 192.168.31.20 netmask 0.0.0.0 dev ens33

* 当上述情况出现后，感觉ipvsadm lvs 被阻塞了，不能恢复访问正常，需要重启网络服务(后面测试没有阻塞，是因为设置default gw失败的
   原因  执行service NetworkManager stop后添加默认路由) 
* 需要正常运行还需要 rs 服务器中 不能和大网相连 只是和 dir 主机一个网卡相连，不然大网内的访问主机会访问不正常。


**ipvsadm 使用**

1，virtual-service-address:是指虚拟服务器的ip 地址
2，real-service-address:是指真实服务器的ip 地址
3，scheduler：调度方法
ipvsadm 的用法和格式如下：
ipvsadm -A|E -t|u|f virutal-service-address:port [-s scheduler] [-p [timeout]] [-M netmask]
ipvsadm -D -t|u|f virtual-service-address
ipvsadm -C
ipvsadm -R
ipvsadm -S [-n]
ipvsadm -a|e -t|u|f service-address:port -r real-server-address:port
[-g|i|m] [-w weight]
ipvsadm -d -t|u|f service-address -r server-address
ipvsadm -L|l [options]
ipvsadm -Z [-t|u|f service-address]
ipvsadm --set tcp tcpfin udp
ipvsadm --start-daemon state [--mcast-interface interface]
ipvsadm --stop-daemon
ipvsadm -h

命令选项解释：
有两种命令选项格式，长的和短的，具有相同的意思。在实际使用时，两种都可以。
-A --add-service 在内核的虚拟服务器表中添加一条新的虚拟服务器记录。也就是增加一台新的虚拟服务器。
-E --edit-service 编辑内核虚拟服务器表中的一条虚拟服务器记录。
-D --delete-service 删除内核虚拟服务器表中的一条虚拟服务器记录。
-C --clear 清除内核虚拟服务器表中的所有记录。
-R --restore 恢复虚拟服务器规则
-S --save 保存虚拟服务器规则，输出为-R 选项可读的格式
-a --add-server 在内核虚拟服务器表的一条记录里添加一条新的真实服务器记录。也就是在一个虚拟服务器中增加一台新的真实服务器
-e --edit-server 编辑一条虚拟服务器记录中的某条真实服务器记录
-d --delete-server 删除一条虚拟服务器记录中的某条真实服务器记录
 -L|-l --list 显示内核虚拟服务器表
-Z --zero 虚拟服务表计数器清零（清空当前的连接数量等）
--set tcp tcpfin udp 设置连接超时值
--start-daemon 启动同步守护进程。他后面可以是master 或backup，用来说明LVS Router 是aster 或是backup。在这个功能上也可以采用keepalived 的VRRP 功能。
--stop-daemon 停止同步守护进程
-h --help 显示帮助信息

其他的选项:
-t --tcp-service service-address 说明虚拟服务器提供的是tcp 的服务[vip:port] or [real-server-ip:port]
-u --udp-service service-address 说明虚拟服务器提供的是udp 的服务[vip:port] or [real-server-ip:port]
-f --fwmark-service fwmark 说明是经过iptables 标记过的服务类型。
-s --scheduler scheduler 使用的调度算法，有这样几个选项rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq,默认的调度算法是： wlc.
-p --persistent [timeout] 持久稳固的服务。这个选项的意思是来自同一个客户的多次请求，将被同一台真实的服务器处理。timeout 的默认值为300 秒。
-M --netmask netmask persistent granularity mask
-r --real-server server-address 真实的服务器[Real-Server:port]
-g --gatewaying 指定LVS 的工作模式为直接路由模式（也是LVS 默认的模式）
-i --ipip 指定LVS 的工作模式为隧道模式
-m --masquerading 指定LVS 的工作模式为NAT 模式
-w  --weight weight 真实服务器的权值
--mcast-interface interface 指定组播的同步接口
-c --connection 显示LVS 目前的连接 如：ipvsadm -L -c
--timeout 显示tcp tcpfin udp 的timeout 值 如：ipvsadm -L --timeout
--daemon 显示同步守护进程状态
--stats 显示统计信息
--rate 显示速率信息
--sort 对虚拟服务器和真实服务器排序输出
--numeric -n 输出IP 地址和端口的数字形式



## DR 模式搭建

环境搭建:

* 三台机器

*  192.168.31.20 分发器 也叫调度器(dir)
   192.168.31.21 rs1
   192.168.31.22 rs2

* vip 192.168.31.100

* dir 上编写脚本 vim /usr/local/sbin/lvs_dr.sh

```bash

#! /bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward
ipv=/usr/sbin/ipvsadm
vip=192.168.31.100
rs1=192.168.31.21
rs2=192.168.31.22
#注意这里的网卡名字
ifconfig ens33:2 $vip broadcast $vip netmask 255.255.255.255 up
route add -host $vip dev ens33:2
$ipv -C
$ipv -A -t $vip:80 -s wrr
$ipv -a -t $vip:80 -r $rs1:80 -g -w 1
$ipv -a -t $vip:80 -r $rs2:80 -g -w 1


```

* 各个 rs上 编写脚本 vim /usr/local/sbin/lvs_rs.sh 

```bash
#/bin/bash
vip=192.168.31.100
#把vip绑定在lo上，是为了实现rs直接把结果返回给客户端
ifconfig lo:0 $vip broadcast $vip netmask 255.255.255.255 up
route add -host $vip lo:0
#以下操作为更改arp内核参数，目的是为了让rs顺利发送mac地址给客户端
#参考文档www.cnblogs.com/lgfeng/archive/2012/10/16/2726308.html
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
```

* 运行 dir 和rs 脚本(如果rs脚本不运行，客户端访问后，设置的vip rs1 ip rs2 ip的机器ping不通，需要重启vmware虚拟机的网卡才行,
  不知道真实的机器是否有同样的问题)
* dir 主机上不可以测试 访问 192.168.31.100 vip

特点:
1、 当client 访问到rs1后，nginx服务中断，client不会马上切换到rs2服务器 (调度算法:wrr)

DR传输理解:

TCP连接 建立是通过 套接字(IP:PORT) 来达成，tcp的请求连接建立也是如此(不只是传输数据)
环境介绍:
client: ip_C:mac_C 
dir: ip_D:mac_D 
rs1:ip_s1:mac_s1  
rs2: ip_s2:mac_s2 #访问的为http服务 端口号为80 ip_s1 ip_s2 ip_D 都为VIP
* 首先client 访问 dir 的 vip,发送一个tcp(SYN)请求(src: ip_C:mac_C dst: ip_D:mac_D)，dir主机收到后，由软件lvs(ipvsadm) 进行转发
  并把MAC地址修改成 rs1的，修改后的tcp请求发送到rs1服务器(src: ip_C:mac_C dst:ip_s1:mac_s1)，rs1服务器收到请求一看，
  套接字的目的地址和端口号是自己的IP（lo:0） 和端口(dst: ip_s1:80),于是就回应发送(SYN+ACK)应答(dst: ip_C:mac_C src:ip_s1:mac_s1)，
  后面的信息都类似操作

**rs在回环网卡上配置vip就相当于弄了个欺骗回应**

### arp_ignore arp_announce 理解:

arp_ignore:定义对目标地址为本地IP的ARP询问不同的应答模式0 

0 - (默认值): 回应任何网络接口上对任何本地IP地址的arp查询请求 

1 - 只回答目标IP地址是来访网络接口本地地址的ARP查询请求 

2 -只回答目标IP地址是来访网络接口本地地址的ARP查询请求,且来访IP必须在该网络接口的子网段内 

3 - 不回应该网络界面的arp请求，而只对设置的唯一和连接地址做出回应 

4-7 - 保留未使用 

8 -不回应所有（本地地址）的arp查询

arp_announce:对网络接口上，本地IP地址的发出的，ARP回应，作出相应级别的限制: 确定不同程度的限制,宣布对来自本地源IP地址发出Arp请求的接口 

0 - (默认) 在任意网络接口（eth0,eth1，lo）上的任何本地地址 

1 -尽量避免不在该网络接口子网段的本地地址做出arp回应. 当发起ARP请求的源IP地址是被设置应该经由路由达到此网络接口的时候很有用.此时会检查来访IP是否为所有接口上的子网段内ip之一.如果改来访IP不属于各个网络接口上的子网段内,那么将采用级别2的方式来进行处理. 

2 - 对查询目标使用最适当的本地地址.在此模式下将忽略这个IP数据包的源地址并尝试选择与能与该地址通信的本地地址.首要是选择所有的网络接口的子网中外出访问子网中包含该目标IP地址的本地地址. 如果没有合适的地址被发现,将选择当前的发送网络接口或其他的有可能接受到该ARP回应的网络接口来进行发送.

## keepalived LVS DR

* 完整架构需要两台服务器(角色为dir)分别安装keepalived软件，目的是实现高可用，并且keepalived本身也有负载均衡的功能
* keepalived内置了ipvsadm的功能，所以不需要安装ipvsadm，也不用编写和执行那个lvs_dir
* 四台机器分别为:
  dir1(安装keepalived) 31.20
  dir2(安装keepalived) 31.33 #backup
  rs1 31.21
  rs2 31.22
  vip 31.100


* 编辑 dir1 keepalived配置文件 vim /etc/keepalived/keepalived.conf

```bash
global_defs {
   notification_email {
     1193630409@qq.com
   }
   notification_email_from root@aminglinux.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}
vrrp_script chk_nginx {
    script "/usr/local/sbin/check_ng_lvs.sh"

    interval 5
}


vrrp_instance VI_1 {
   #备用服务器上为 BACKUP
    state MASTER
    #绑定vip的网卡为ens33，你的网卡和阿铭的可能不一样，这里需要你改一下
    interface ens33
    virtual_router_id 51
    #备用服务器上为90
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass aminglinux
    }
    virtual_ipaddress {
        192.168.31.100
    }

    track_script {
        chk_nginx
    }
}

virtual_server 192.168.31.100 80 {
    #(每隔10秒查询realserver状态)
    delay_loop 10
    #(lvs 算法)
    lb_algo wlc
    #(DR模式)
    lb_kind DR
    #(同一IP的连接60秒内被分配到同一台realserver)
    persistence_timeout 60
    #(用TCP协议检查realserver状态)
    protocol TCP
    real_server 192.168.31.21 80 {
        #(权重)
        weight 100
        TCP_CHECK {
        #(10秒无响应超时)
        connect_timeout 10
        nb_get_retry 3
        delay_before_retry 3
        connect_port 80
        }
    }
    real_server 192.168.31.22 80 {
        weight 100
        TCP_CHECK {
        connect_timeout 10
        nb_get_retry 3
        delay_before_retry 3
        connect_port 80
        }
     }
}

```

* 编辑 dir2 vim /etc/keepalived/keepalived.conf: 只是修改"state BACKUP" "priority 90" 两处
* dir1 dir2 编辑监控脚本(此脚本也可以不写，把chk_nginx项删除) vim /usr/local/sbin/check_online.sh
  此脚本只是判断keepalived有没有启动，实际可能没什么作用，因为用自己判断自己

```bash
#!/bin/bash
#时间变量，用于记录日志
d=`date --date today +%Y%m%d_%H:%M:%S`
#计算nginx进程数量
n=`ps -C keepalived --no-heading|wc -l`
#echo "file is running==========" >> /var/log/messages
#echo $? >> /tmp/messages
#echo `who am i`xxx >> /tmp/messages
#如果进程为0，则启动nginx，并且再次检测nginx进程数量，
#如果还为0，说明nginx无法启动，此时需要关闭keepalived
if [ $n -eq "0" ]; then
        #echo start >> /tmp/messages
#       sh -x /etc/init.d/nginx start >> /tmp/messages
        #echo $? >> /tmp/messages
        #echo `who am i`ssssss >> /tmp/messages
        n2=`ps -C keepalived --no-heading|wc -l`

        if [ $n2 -eq "0"  ]; then
        #       echo "over" >> /tmp/messages
         #       echo "$d nginx down,keepalived will stop" >> /tmp/messages
               # systemctl stop keepalived
            echo "keepalived is not running!!\n please check conf." >> /tmp/messages
        fi

```

* rs1 rs2 编辑环境脚本: vim /usr/local/sbin/lvs_rs.sh #记得给执行权限

```BASH
#/bin/bash
vip=192.168.31.100
#把vip绑定在lo上，是为了实现rs直接把结果返回给客户端
ifconfig lo:0 $vip broadcast $vip netmask 255.255.255.255 up
route add -host $vip lo:0
#以下操作为更改arp内核参数，目的是为了让rs顺利发送mac地址给客户端
#参考文档www.cnblogs.com/lgfeng/archive/2012/10/16/2726308.html
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

```

* rs1 rs2 nginx服务 启动

测试:
*ip addr 查看vip，ipvsadm -l 查看在线rs，ipvsadm -lc 查看请求连接*
* dir1 上 ip addr 查看有vip 192.168.31.100，client访问 192.168.31.100 返回rs1的内容，
  关闭rs1 ngixn服务内容，几秒后 返回rs2 ngixn服务内容
  **这个和普通的 ipvsadm DR负载均衡有了优化，在当前访问的ngixn服务出现问题的时候，先前的要等到调度转换后正常，这个只要等几秒就可以正常访问**

* 用两台client分别访问 vip 192.168.31.100 分别返回 rs1 rs2 的数据 说明负载均衡生效
*关闭 dir1服务器 或者停用 dir1 keepalived 服务， dir2 中 ip addr 可以看 vip 192.168.31.100，此时访问 服务还是正常，
 按照前面步骤测试

**此模式架构为 dir 调度机 实行高可用(dir1 dir2)，rs 服务机群 通过调度机实现负载均衡，其中服务机群互相有点高可用的意思(但不是真的高可用只是比普通的DR要快点)**

## 负载均衡软件 说明

* 按照网络负载大小、网络复杂度 小网络 用nginx 或 haproxy 大网络复杂网络 用 LVS
* haproxy 补充了nginx的缺点，支持 session 保持 cookie引导 同时支持通过获取指定的url来检测后端服务器的状态。
  处理效率比nginx高，
  支持TCP 负载均衡转发 可以对mysql做负载均衡

* nginx 容易布置，工作在7层网络，可以针对 目录结构 域名做分流，
  nginx 可以做反向代理
  nginx 可以做静态网页和图片服务器


* LVS(keepalived) 负载能力强 可以对大量应用做负载均衡 包括数据库

