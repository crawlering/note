# iptables

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
	   -t nat     -I           PREROUTING        -d               -j REJECT
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

* iptables -L [INPUT/OUTPUT] #显示当前规则
* iptables -F #删除所有规则
* iptables save #保存当前规则到配置文件
* 配置文件 /etc/sysconfig/iptables

## iptables 实例

ping通外面，外面ping不同里面，ICMP 分为一个请求包一个应答包 request reply

* iptables -I INPUT 1 -t filter -p icmp --icmp-type echo-request -j DROP # 只要禁用 外面来的数据的请求包就可以达到要求了


实验中ping包看到"请求超时"的 是 DROP 了请求包
当REJECT 请求包的时候"无法连到端口"
当局域网不存在此IP的时候显示"无法访问目标主机"
