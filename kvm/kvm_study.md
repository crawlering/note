# 虚拟机



VMware Workstation 就是虚拟化
虚拟化简单讲，就是把一台物理计算机虚拟成多台逻辑计算机，每个逻辑计算机里面可以运行不同的操作系统，
相互不受影响，这样就可以充分利用硬件资源。

关键字: Hypervisor(VMM) 虚拟机管理器

虚拟技术分为:全虚拟化和半虚拟化

* 早早期PU不支持虚拟化，需要通过VMM翻译，过程比较耗费资源，这种虚拟化技术叫做全虚拟化(VMware Workstation)
* 半虚拟化通过修改guestos内核，但修改内核比较鸡肋(XEN)
* 后续CPU厂商支持虚拟化，不需要通过VMM翻译指令了，无所谓半虚拟化和全虚拟化。


## 虚拟化软件

* VMware 系列
  VMware workstation 、VMware vsphere(VMware esxi)、VMware Fusion(Mac)
* xen 开源半虚拟化
  XenServer 商业 厂商Ctirx，基于Xen的
* KVM 开源 基于linux内核模块
* Openvz开源 基于linux虚拟机和宿主机共用一个内核
* VirtualBox 开源 sun公司开发 oracle收购sun


type I ： 硬件-虚拟化软件-虚拟机...
type II： 硬件-host(宿主机)-虚拟化软件-虚拟机...
Xen:属于 type I
KVM属于 type II


## KVM 介绍

* KVM 是linux内核的一个模块，把linux内核变成一个Hypervisor
* KVM 是完全开源的 redhat 记忆KVM 的虚拟化解决方案叫做 RHEV
* KVM 在linux操作系统里面以进程的形式出现，由标准的linux调度程序进行调度，
  是的KVM能够使用linux内核的已有功能
* KVM 内核模块单独不能实现虚拟化的全部功能，
* QEMU 是一个开源的虚拟软件，纯软件，可以虚拟化所有的硬件，性能不强，
* KVM基于QEMU开发一个能够运行在用户空间的工具QEMU-KVM
  磁盘 网络设备等 都是通过 QEMU-KVM这个工具模拟出来的
  KVM 和 QEMU-KVM 通信是通过 /dev/kvm实现的
  libvirt是用来管理KVM 虚拟机的API，其命令为virsh
* libvirt->KVM---QUMU-KVM > /dev/kvm ->虚拟机


* KVM 架构图
-----------------------------

guestOS  |  guestOS
         |
         |
QEMU-KVM |  QEMU-KVM
         |
虚拟硬件 | 虚拟硬件
         
-----------------------------
/dev/kvm

    linux内核  KVM 模块

-----------------------------
 硬件资源 cpu 内存 硬盘等
 
-----------------------------


## KVM 安装

* grep -Ei "vmx|svm" /proc/cpuinfo //查看cpu是否支持虚拟化，如果没有匹配到，cpu确实又支持虚拟化(BIOS有虚拟化设置)，则到vmware
  软件中，开启 virtualize功能，如果还不行则把电脑重启一次
* 虚拟机新增 到2个cpu 2G内存 20G 磁盘
* mkdir /kvm_data;mkfs.ext4 /dev/sdc;mount /dev/sdc /kvm_data;
* vim /etc/fstab  --> /dev/sdc	/kvm_data	ext4	defaults	0	0 //增加开机启动
* yum install -y qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer

```bash
测试的时候开机出现 panic kernel
**yum -y install virt-* //出现依赖问题，未解决**

```

### kvm 配置
 
* cp /etc/sysconfig/network-scripts/ifcfg-ens37 /etc/sysconfig/network-scripts/ifcfg-br0
  修改 br0: TYPE="Bridge" ip为ens37的IP DEVICE NAME 做相应修改
  ens37: 注释掉有关IP的信息(网关 dns等)增加BRIDGE=br0
* lsmod | grep kvm //检查kvm模块是否加载
* systemctl start libvirtd //启动libvirtd服务
* brctl show 可以查看到两个网卡 br0(桥接)和virbr0(NAT)
* 把windows 的 linux.iso系统 传输到 主机，这里把windows文件共享挂载在/mnt/share
* virt-install --name=kvmtest --memory=512,maxmemory=1024 --vcpus=1,maxvcpus=2 --os-type=linux --os-variant=rhel7 --location=/kvm_data/CentOS-7-x86_64-DVD.iso --disk path=/kvm_data/kvmtest.img,size=10 --bridge=br0 --graphics=none --console=pty,target_type=serial  --extra-args="console=tty0 console=ttyS0" //安装系统


### kvm 虚拟机管理

* 安全完虚拟机需要重启，要退出虚拟机使用快捷键ctrl ]
* ps aux |grep kvm //查看kvm进程
* virsh list //查看虚拟机列表，只能看到运行的虚拟机
* virsh list --all //查看虚拟机列表，包括未运行的虚拟机
* virsh console aminglinux01//进入指定虚拟机
* virsh shutdown aminglinux01 //关闭虚拟机
* virsh start aminglinux01 //开启虚拟机
* virsh destroy aminglinux01//类似stop，这个是强制停止
* virsh undefine aminglinux01//彻底销毁虚拟机，会删除虚拟机配置文件，virsh list --all就看不到了
* ls /etc/libvirt/qemu/  //可以查看虚拟机配置文件
* virsh autostart aminglinux01//宿主机开机该虚拟机也开机
* virsh autostart --disable aminglinux01//解除开机启动
* virsh suspend aminglinux01//挂起
* virsh resume aminglinux01//恢复

### kvm 虚拟机 克隆虚拟机

* virsh shutdown aminglinux01
* virt-clone  --original aminglinux01 --name aminglinux02 --file /kvm_data/aminglinux02.img
  --original指定克隆源虚拟机
  --name指定克隆后的虚拟机名字
  --file指定目标虚拟机的虚拟磁盘文件
* 如果aminglinux01虚拟机开机状态，则提示先关闭或者暂停虚拟机


### 快照管理

* 创建快照  virsh snapshot-create aminglinux01
* raw格式的虚拟磁盘不支持做快照，qcow2支持
* qemu-img info /kvm_data/aminglinux01.img //查看aminglinux01.img信息，同时会查看到快照列表
* virsh snapshot-list aminglinux01 //列出所有快照
* virsh snapshot-current aminglinux01//查看当前快照版本
* ls /var/lib/libvirt/qemu/snapshot/aminglinux01//查看所有快照配置文件
* virsh snapshot-revert aminglinux01 1513440854//恢复指定快照
* virsh snapshot-delete aminglinux01  1513440854//删除快照

### 磁盘格式

* 虚拟磁盘常用格式raw、qcow2
* qemu-img info /kvm_data/aminglinux01.img//查看虚拟磁盘格式
* qemu-img create -f raw /kvm_data/aminglinux01_2.img 2G//创建2G的raw格式磁盘
 
 // 把raw格式的磁盘转换为qcow2格式
* qemu-img convert -O qcow2 /kvm_data/aminglinux01_2.img /kvm_data/aminglinux01_2.qcow2

 // 转换后用ls -lh查看磁盘文件的大小，可以看到qcow2文件比较小，raw文件大小和我们指定空间大小一样是2G
* raw格式的磁盘性能比qcow2要好，但是raw格式的磁盘无法做快照,

//给aminglinux02转换为raw格式的磁盘
* virsh shutdown aminglinux02
* qemu-img convert -O raw /kvm_data/aminglinux02.img /kvm_data/aminglinux02_3.raw
* virsh edit aminglinux02//更改格式和文件路径
* virsh start aminglinux02

### 磁盘扩容-raw格式

* qemu-img resize /kvm_data/aminglinux02_3.raw +2G
*  qemu-img info /kvm_data/aminglinux02_3.raw 
*  virsh destroy aminglinux02
*  virsh start aminglinux02
*  virsh console aminglinux02
*  fdisk -l 查看磁盘情况，并分新的分区

除了对已有磁盘扩容外，还可以额外增加磁盘
*  qemu-img create -f raw /kvm_data/aminglinux02_2.raw 5G
*  virsh edit aminglinux02 //增加<disk>…</disk>，注意更改source、target、slot
*  virsh destroy aminglinux02
*  virsh start aminglinux02

### 磁盘扩容-qcow2

* qemu-img resize /kvm_data/aminglinux01.img +2G
*  若提示qemu-img: Can't resize an image which has snapshots，需要删除快照
*  qemu-img info /kvm_data/aminglinux01.img 
*  virsh destroy aminglinux01
*  virsh start aminglinux01
*  virsh console aminglinux01
*  fdisk -l 查看磁盘情况，并分新的分区

  除了对已有磁盘扩容外，还可以额外增加磁盘
*  qemu-img create -f qcow2 /kvm_data/aminglinux01_2.img 5G
*  virsh edit aminglinux01 //增加<disk>…</disk>，注意更改source、target、slot
*  virsh destroy aminglinux01
*  virsh start aminglinux01


### 调整cpu、内存、网卡

* virsh dominfo aminglinux01 //查看配置
*  virsh edit aminglinux01//更改如下部分内容
   <memory unit='KiB'>1048576</memory>
   <currentMemory unit='KiB'>524288</currentMemory>
   <vcpu placement='static' current='1'>2</vcpu>
*  virsh shutdown aminglinux01
*  virsh start aminglinux01
*  virsh setmem aminglinux01 800m//动态调整内存 
*  virsh dumpxml aminglinux01 > /etc/libvirt/qemu/aminglinux01.xml//需要把配置写入到配置文件里
*  virsh setvcpus aminglinux01 2 //动态调整cpu数量
*  virsh domiflist aminglinux01//查看网卡
*  virsh attach-interface aminglinux01 --type bridge  --source virbr0
   //增加一块新的网卡，并设置为nat网络模式（virbr0类似vmware的vmnet8），这里如果写--source br0，则网络模式为桥接
*  virsh dumpxml aminglinux01 > /etc/libvirt/qemu/aminglinux01.xml//需要把配置写入到配置文件里

### 迁移虚拟机

 该方式要确保虚拟机是关机状态
* virsh shutdown aminglinux01
* virsh dumpxml aminglinux01 > /etc/libvirt/qemu/aminglinux03.xml  // 如果是远程机器，需要把该配置文件拷贝到远程机器上
* virsh domblklist aminglinux01  //查看虚拟机磁盘所在目录
* rsync -av /kvm_data/aminglinux01.img  /kvm_data/aminglinux03.img  //如果是迁移到远程，则需要把该磁盘文件拷贝到远程机器上

* vi /etc/libvirt/qemu/aminglinux03.xml  
  //因为是迁移到本机，配置文件用的是aminglinux01子机的配置，不改会有冲突，所以需要修改该文件，如果是远程机器不用修改
  修改domname:   <name>aminglinux03</name>
  修改uuid（随便改一下数字，位数不要变）
  修改磁盘路径
* virsh define /etc/libvirt/qemu/aminglinux03.xml //定义新虚拟机
* virsh list --all   //会发现新迁移的aminglinux03子机

