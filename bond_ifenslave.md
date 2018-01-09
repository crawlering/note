#bonding 参数:

* modinfo bonding

```BASH
parm:           max_bonds:Max number of bonded devices (int)
parm:           tx_queues:Max number of transmit queues (default = 16) (int)
parm:           num_grat_arp:Number of peer notifications to send on failover event (alias of num_unsol_na) (int)
parm:           num_unsol_na:Number of peer notifications to send on failover event (alias of num_grat_arp) (int)
parm:           miimon:Link check interval in milliseconds (int)
parm:           updelay:Delay before considering link up, in milliseconds (int)
parm:           downdelay:Delay before considering link down, in milliseconds (int)
parm:           use_carrier:Use netif_carrier_ok (vs MII ioctls) in miimon; 0 for off, 1 for on (default) (int)
parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
parm:           primary:Primary network device to use (charp)
parm:           primary_reselect:Reselect primary slave once it comes up; 0 for always (default), 1 for only if speed of primary is better, 2 for only on active slave failure (charp)
parm:           lacp_rate:LACPDU tx rate to request from 802.3ad partner; 0 for slow, 1 for fast (charp)
parm:           ad_select:802.3ad aggregation selection logic; 0 for stable (default), 1 for bandwidth, 2 for count (charp)
parm:           min_links:Minimum number of available links before turning on carrier (int)
parm:           xmit_hash_policy:balance-xor and 802.3ad hashing method; 0 for layer 2 (default), 1 for layer 3+4, 2 for layer 2+3, 3 for encap layer 2+3, 4 for encap layer 3+4 (charp)
parm:           arp_interval:arp interval in milliseconds (int)
parm:           arp_ip_target:arp targets in n.n.n.n form (array of charp)
parm:           arp_validate:validate src/dst of ARP probes; 0 for none (default), 1 for active, 2 for backup, 3 for all (charp)
parm:           arp_all_targets:fail on any/all arp targets timeout; 0 for any (default), 1 for all (charp)
parm:           fail_over_mac:For active-backup, do not set all slaves to the same MAC; 0 for none (default), 1 for active, 2 for follow (charp)
parm:           all_slaves_active:Keep all frames received on an interface by setting active flag for all slaves; 0 for never (default), 1 for always. (int)
parm:           resend_igmp:Number of IGMP membership reports to send on link failure (int)
parm:           packets_per_slave:Packets to send per slave in balance-rr mode; 0 for a random slave, 1 packet per slave (default), >1 packets per slave. (int)
parm:           lp_interval:The number of seconds between instances where the bonding driver sends learning packets to each slaves peer switch. The default is 1. (uint)


```


# ifenslave 使用
*ifenslave [-c|-d|-f] bond0 ens33 ens37*
> `-a` 显示网络网口信息
> `-c` 更改活动的从属接口
> `-d` 从bonding设备中删除从属接口
> `-f` 强制增加新的的从属接口
> `-v` `-V` `-h` `-u`

# 加载bonding模块

* ifconfig -a

```BASH
[root@xujb01 filters]# ifconfig -a
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.31.20  netmask 255.255.255.0  broadcast 192.168.31.255
        inet6 fe80::d070:2290:af3:64a8  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:6c:0e:0a  txqueuelen 1000  (Ethernet)
        RX packets 145383  bytes 12578972 (11.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 52363  bytes 13000907 (12.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens37: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.129.137  netmask 255.255.255.0  broadcast 192.168.129.255
        inet6 fe80::d884:f010:5808:b6af  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:6c:0e:14  txqueuelen 1000  (Ethernet)
...省略...
```

* lsmod | grep bonding #可以看到bonding没有被加载

* 加载模块： modprobe bonding;ifconfig -a

```bash
[root@xujb01 filters]# modprobe bonding;ifconfig -a   #modprobe -r bonding 移除bonding 模块
bond0: flags=5122<BROADCAST,MASTER,MULTICAST>  mtu 1500
        ether 06:5b:7d:f1:ca:e7  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.31.20  netmask 255.255.255.0  broadcast 192.168.31.255
...省略...
```

* 同样使用 lsmod | grep bonding #可以看到模块被加载

* 此时bond0是没有被唤起的 ifconfig 看不到该接口
* ifconfig bond0 up #ifconfig 可以看到bond0 被唤起
* 首先查看bond0 状态: cat /proc/net/bonding/bond0

```BASH
[root@xujb01 filters]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: load balancing (round-robin)
MII Status: down
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
```

* bond 参数对应位置
> ls /sys/class/bond0/bonding/
> echo "1" > /sys/class/bond0/bonding/mode
*注在bodning启动之前写入数据*
* 或者在/etc/sysconfig/network/ifcfg-enss33 |ens37 | bond做相应配置

```BASH
ens33:
TYPE="Ethernet"

PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
#IPV6INIT="yes"
#IPV6_AUTOCONF="yes"
#IPV6_DEFROUTE="yes"
#IPV6_FAILURE_FATAL="no"
#IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
#UUID="d3c4ce19-6426-4ec0-b2aa-0df4d5a138ca"
DEVICE="ens33"
ONBOOT="yes"
MASTER=bond0
SLAVE=yes
USERCTL=no
----------------
ens37:
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="no"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
NAME="ens37"
DEVICE="ens37"
ONBOOT="yes"
MASTER=bond0
SLAVE=yes
USERCTL=no
---------------
bond0:
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
NAME="bond0"
DEVICE="bond0"
ONBOOT="yes"
IPADDR="192.168.31.20"
NETMASK="255.255.255.0"
GATEWAY="192.168.31.1"
DNS1="192.168.31.1"
DNS2="114.114.114.114"
BONDING_OPTS="mode=6 miimon=100 updelay=200 all_slaves_active=1 primary=ens33"
USERCTL=no
#primary 模式1(active-backup)才可以设置 ，但是先设置1然后把mode=6然后重启网卡primary也写进了/sys/class/bond0/bonding/primary中
#all_slaves_active 没有测出什么结果
```
