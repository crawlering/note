# 查看系统负载

* w/uptime
* top / top -bn1 / top -c 
  M 按内存排序
  P 按cpu使用排序
* sar -q  //sar 磁盘读写 负载 网卡流量

文件: cat /proc/loadavg

# 查看虚拟内存

* vmstat 1 5 //查看虚拟内存 内存 内存和swap交换 运行进程 io内存和磁盘读写 cpu读写
* ps aux // VSZ: 虚拟内存 RSS:物理内存

# 磁盘读写

* sar -b // sar -b -f /var/log/sa/xx 查看日志
* iostat -x //%util 数字大 读写忙
* iostat //统计IO读写大小
* iotop //各个进程对磁盘读写查看,实时查看读写值
 cat /proc/pid/io

# 网卡流量

* sar -n DEV 1 5
* nload // yum -y install nload 查看各个网卡流量情况 
* iptables -nvL //pkts 被本机匹配报文的个数 	bytes   报文所有大小记起来之和


# 网络状态

* netstat -anutp


# 抓包工具:

* tcpdump: tcp -nn -i ens33 -vv -s0 port 80 -w 1.pcap
* tcpdump -r 1.pcap


