# 防火墙

* 硬件防火墙 物理隔离
* 软件防火墙


防火墙:
服务访问规则、验证工具、包过滤和应用网关 组成

主要类型:

网络层防火墙:

网络层防火墙 ip封包过滤器 运行在底层的 TCP/IP 协议堆栈上

过滤通过: 来源IP地址 来源端口号 目的IP地址或端口号 服务类型(如http ftp等) 也可以通过 通信协议 TTL值
          来源的网域名称或网段等属性来进行过滤


应用层防火墙:

应用层防火墙可以拦截进出某应用程序所有封包
根据侧重不同: 包过滤型防火墙 应用层网关型防火墙 服务器型防火墙

数据库防火墙:

基于数据库协议分析与控制技术的数据库安全防护系统

# Netfilter

netfilter 所设置的规则是存放在内核内存中的，而iptables是一个应用层程序 firewalld也是一个应用程序

* iptables -I INPUT 1 -t filter -p icmp --icmp-type echo-request -j DROP # 只要禁用 外面来的数据的请求包就可以达到要求了
* iptables -t nat -I PREROUTING -p tcp -s 192.168.31.95 --dport 60000 -j REDIRECT --to-dports 22 #端口60000 重定向成22 

ip 端口映射
* iptables -t nat -A PREROUTING -p tcp --dport 60001 -j DNAT --to-destination 192.168.31.21:50000
* iptables -t nat -A POSTROUTING -p tcp --dport 50000 -d 192.168.31.21 -j SNAT --to-source 192.168.31.20


# ESXI hypervisor KVM xen

 KVM，它是首个被集成到 Linux 内核的 hypervisor 解决方案，并且实现了完整的虚拟化。其次是 Lguest，这是一个实验 hypervisor，它通过少量的更改提高准虚拟化。
 VMware vSphere Hypervisor 是以前的 VMware ESXi Single Server 或免费的 ESXi（通常简称为“VMware ESXi”）的新名称


hypervisor 可以划分为两大类。首先是类型 1，这种 hypervisor 是直接运行在物理硬件之上的。其次是类型 2，这种 hypervisor 运行在另一个操作系统（运行在物理硬件之上）中。类型 1 hypervisor 的一个例子是基于内核的虚拟机（KVM —— 它本身是一个基于操作系统的 hypervisor）。类型 2 hypervisor 包括 QEMU 和 WINE

## KVM 

KVM kernel-based virtual machine, 他是一个linux 的一个内核模块，该内核模块是的linux变成一个hypervisor
数据进入的时候 进行 PREROUTING 转换成21 50000端口 并在出的时候 把源地址 改成 20 这样发给20 返回的数据不用做映射



