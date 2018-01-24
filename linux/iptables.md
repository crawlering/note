
# iptables

## iptables  常用参数

* iptables -A INPUT -j DROP
  iptables -A OUTPUT -j DROP
  iptables -A FORWARD -j DROP  #禁止所有端口
* iptables -A INPUT -p tcp --dport 22 -j ACCEPT
  iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT #开放22端口
* iptables -nvL --line-numbers
* service iptables save #保存 当前 规则 到 /etc/sysconfig/iptables
* iptables-save > my.ipt #保存规则到my.ipt
* iptables-restore < my.ipt #把my.ipt 恢复到 当前

## 5表5链

* filter: INPUT OUTPUT FORWARD
  用于过滤包，内核模块:iptables_filter
* nat: PREROUTING POSTROUTING OUTPUT
  用于网络地址转换(IP,端口)，内核模块:iptables_nat
* mangle: PREROUTING POSTROUTING INPUT OUTPUT FORWARD
  修改数据报服务类型、TTL、并且可以配置路由实现QOS内核模块:iptables_mangle
raw: OUT PREROUTING
  决定数据包是否被状态跟踪机制处理， 内核模块: iptable_raw
security:用于强制访问控制MAC的网络规则

    数据进入 先通过 **PREROUTING** ----数据是给主机的---INPUT--主机---OUTPUT--->POSTROUTING
    数据进入  先通过 **PREROUTING** ----数据给其他主机的---FORWARD---->POSTROUTING

* 5 表: filter nat mangle raw security
* 5 链: PREROUTING FORWARD POSTROUTING INPUT OUTPUT

规则链：


1.INPUT——进来的数据包应用此规则链中的策略
2.OUTPUT——外出的数据包应用此规则链中的策略
3.FORWARD——转发数据包时应用此规则链中的策略
4.PREROUTING——对数据包作路由选择前应用此链中的规则
（记住！所有的数据包进来的时侯都先由这个链处理）
5.POSTROUTING——对数据包作路由选择后应用此链中的规则
（所有的数据包出来的时侯都先由这个链处理）


第一种情况：入站数据流向

       从外界到达防火墙的数据包，先被PREROUTING规则链处理（是否修改数据包地址等），之后会进行路由选择（判断该数据包应该发往何处），如果数据包 的目标主机是防火墙本机（比如说Internet用户访问防火墙主机中的web服务器的数据包），那么内核将其传给INPUT链进行处理（决定是否允许通 过等），通过以后再交给系统上层的应用程序（比如Apache服务器）进行响应。

第二冲情况：转发数据流向

       来自外界的数据包到达防火墙后，首先被PREROUTING规则链处理，之后会进行路由选择，如果数据包的目标地址是其它外部地址（比如局域网用户通过网 关访问QQ站点的数据包），则内核将其传递给FORWARD链进行处理（是否转发或拦截），然后再交给POSTROUTING规则链（是否修改数据包的地 址等）进行处理。

第三种情况：出站数据流向
       防火墙本机向外部地址发送的数据包（比如在防火墙主机中测试公网DNS服务器时），首先被OUTPUT规则链处理，之后进行路由选择，然后传递给POSTROUTING规则链（是否修改数据包的地址等）进行处理。


## 管理和设置 iptables

      
iptables   table       command     chain           parameter        target
                      -A           INPUT             -p               -j ACCEPT
	   -t filter  -D           OUTPUT            -s               -j DROP
	              -I           PREROUTING        -d               -j REJECT
	              -R           POSTROUTING       -i
		      -L           FORWARD           -o
		      -F                             --sport
		      -Z                             --dport
		      -N
		      -X
		      -P



parameters                                            specified

-p                                               TCP 、UDP、 ICMP、A protocol name from /etc/protocols、all

-s                                              network name、 hostname 、subnet(192.168.0.0/24;192.168.0.0/255.255.255.0)
                                                IP address

-d                                             network name、 hostname 、subnet(192.168.0.0/24;192.168.0.0/255.255.255.0)                                                       IP address

-i/-o                                          interface name(eth0) 、interface name ends in a "+"(eth+)

--sport/--dport                               service name 、port number 、 port range(1024:65535)


-i/-o 表示接口 -i 输入接口 -o 输出使用接口(网口) 指定 数据包 进入INPUT FORWARD PREROUTING 链时 经过的接口。

## iptables 常用命令

* iptables -L [INPUT/OUTPUT] #显示当前规则 iptables -nvL --line-numbers
* iptables -F #删除所有规则
* iptables save #保存当前规则到配置文件
* 配置文件 /etc/sysconfig/iptables

## iptables 实例

ping通外面，外面ping不同里面，ICMP 分为一个请求包一个应答包 request reply

* iptables -I INPUT 1 -t filter -p icmp --icmp-type echo-request -j DROP # 只要禁用 外面来的数据的请求包就可以达到要求了


实验中ping包看到"请求超时"的 是 DROP 了请求包
当REJECT 请求包的时候"无法连到端口"
当局域网不存在此IP的时候显示"无法访问目标主机"



## iptbales nat 

nat表需要的三个链：

  1.PREROUTING:可以在这里定义进行目的NAT的规则，因为路由器进行路由时只检查数据包的目的ip地址，所以为了使数据包得以正确路由，我们必须在路由之前就进行目的NAT;
  2.POSTROUTING:可以在这里定义进行源NAT的规则，系统在决定了数据包的路由以后在执行该链中的规则。
  3.OUTPUT:定义对本地产生的数据包的目的NAT规则。

需要用到的几个动作选项：（真实环境中用大写）

 redirect	 将数据包重定向到另一台主机的某个端口，通常用实现透明代理和对外开放内网某些服务。
snat	源地址转换，改变数据包的源地址
dnat	目的地址转换，改变数据包的目的地址
masquerade	IP伪装，只适用于ADSL等动态拨号上网的IP伪装，如果主机IP是静态分配的，就用snat
PRERROUTING:DNAT 、REDIRECT   （路由之前）只支持-i，不支持-o。在作出路由之前，对目的地址进行修改

 POSTROUTING:SNAT、MASQUERADE （路由之后）只支持-o，不支持-i。在作出路由之后，对源地址进行修改

 OUTPUT:DNAT 、REDIRECT   （本机）DNAT和REDIRECT规则用来处理来自NAT主机本身生成的出站数据包.

一、打开内核的路由功能。

   要实现nat，要将文件/proc/sys/net/ipv4/ip_forward内的值改为1，（默认是0）。

 

二、nat不同动作的配置

 1）MASQUERADE：是动态分配ip时用的IP伪装：在nat表的POSTROUTING链加入一条规则:所有从ppp0口送出的包会被伪装（MASQUERADE）

 [root@localhost]# iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

要想系统启动时自动实现nat，在/etc/rc.d/rc.local文件的末尾添加

   [root@localhost]# echo "1">/proc/sys/net/ipv4/ip_forward

   [root@localhost]# /sbin/iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

 2) SNAT:一般正常共享上网都用的这个。

 所有从eth0（外网卡）出来的数据包的源地址改成61.99.28.1（这里指定了一个网段，一般可以不指定）

 [root@localhost]# iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j SNAT --to 61.99.28.1

3）DNAT:目的nat 做智能DNS时会用到

 智能DNS：就是客户端在dns项里无论输入任何ip，都会给他定向到服务器指定的一个dnsip上去。

 在路由之前所有从eth0（内网卡）进入的目的端口为53的数据包，都发送到1.2.3.4这台服务器解析。

 [root@localhost]# iptables -t nat -I PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to-destination 1.2.3.4:53

 [root@localhost]# iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 53 -j DNAT --to-destination 1.2.3.4:53

4）REDIRECT：重定向，这个在squid透明代理时肯定要用到它

 所有从eth1进入的请求80和82端口的数据，被转发到80端口，由squid处理。

 [root@localhost]# iptables -t nat -A PREROUTING - -i eth1 -p tcp -m multiport --dports 80,82 -j REDIRECT --to-ports 80


##iptables -m state --stat

Iptables参数

-m state --state <状态>

有数种状态，状态有：

▪ INVALID：无效的封包，例如数据破损的封包状态

▪ ESTABLISHED：已经联机成功的联机状态；

▪ NEW：想要新建立联机的封包状态；

▪ RELATED：这个最常用！表示这个封包是与我们主机发送出去的封包有关， 可能是响应封包或者是联机成功之后的传送封包！这个状态很常被设定，因为设定了他之后，只要未来由本机发送出去的封包，即使我们没有设定封包的 INPUT 规则，该有关的封包还是可以进入我们主机， 可以简化相当多的设定规则。

实验1：

允许 ICMP 封包与允许已建立的联机通过

filter表中INPUT链为DROP，OUTPUT链为ACCEPT，

此时本机ping其他主机不通，在INPUT链中添加规则：

iptables -AINPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

本机可以ping其他主机，但是其他主机无法ping本机
