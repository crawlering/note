
#20171108
四周第二次课（11月07日）
5.1 vim介绍
5.2 vim颜色显示和移动光标
5.3 vim一般模式下移动光标
5.4 vim一般模式下复制、剪切和粘贴

#vim
1. 一般模式
2. 插入模式
3. 命令模式

##vim 颜色设置
* 在用户目录下编辑.viminfo 添加 :colorscheme desert
* 在PUTTY软件配色windows-colours
```
Default Foreground 89 166 114
default Background 10 10 10
ANSI Blue 117 117 0
```
## 命令模式下光标的移动

###行内操作
* 下上左右移动：j k h l # nj 向下移动n行
* 单词间移动光标：w(向后移动一个单词，nw向后移动n个单词) b（向前移动1个单词，nb）,光标停在单词首位
		  e（向后移动1个单词）光标停在单词末尾
* 移动到行首、行尾：^(或者0) $
* 快速跳到行内字符：向右fx(或者nfx)，向左Fx(或者nFx)查找   
###行操作
* gg G 快速跳到文章的开头和结尾
* 半屏移动 (c+d)、(c+u) 向前下上移动半屏
* 全屏移动(c+f)(c+b)向下移动、向上一个屏幕的内容
* ngg或者nG 移动到第n行
* zz zt zb 把当前光标置于中间、顶部、底部

##搜索字符
* `/` `?` 向下、向上搜索 
* 光标停在单词位置按 `*`快速搜索改词
* n N 搜索关键字后 向下向上搜索
* `:set ignorecase`,`:set noignorecase` 忽略大小写，不忽略大小写

##

#20171106
四周第一次课(11月06日）
4.10/4.11/4.12 lvm讲解
4.13 磁盘故障小案例

##一、lvm

**pv（物理卷）->vg（卷组）->lv（逻辑卷）**

* fdisk /dev/sdb #创建三个分区 sdb1 sdb2 sdb3每个1G  
`fdisk /dev/sdb n t修改分区格式：8e->lvm`

* pvcreate  /dev/sdb1                 #创建物理卷
`yum provides "/*/pvcreate"   yum -y install  lvm2`
```
出现404错误，后yum update更新yum出现/boot容量不足，然后找到/boot
下40M的文件复制到/mnt下，删除源文件，并建立软连接，然后update yum
在yum provides "/*/pvcreate寻找插件名字 lvm2
```

* partprobe #手动更新分区信息当没有出现/dev/sdb1的时候

* pvdisplay

* pvs


*  vgcreate vg1 /dev/sdb1 /dev/sdb2                 #创建卷

* vgdisplay      pvs

* lvcreate -L 100M -n lv1 vg1  #创建逻辑卷

* lvs #查看逻辑卷
* mkfs.ext4 /dev/vg1/lv1       #格式化

* moount /dev/vg1/lv1 /mnt/lv #挂载

## 扩容逻辑卷

* lvresize -L 200M /dev/vg1/lv1
* e2fsck -f /dev/vg1/lv1     #检测磁盘 需要把磁盘卸载

* resize2fs /dev/vg1/lv1 #更新逻辑卷信息


##缩减逻辑卷 （xfs不支持）
* umount

* e2fsck -f /dev/vg1/lv1

* resize2fs /dev/vg1/lv1 #更新逻辑卷信息

* lvresize -L 100M /dev/vg1/lv1 #缩容
* lvs             #查看逻辑卷信息
* blkid /dev/vg1/lv1 #查看逻辑卷格式

## 扩容xfs （不需要卸载）
* blkid /dev/vg1/lv1 #查看你逻辑卷格式
* umout /dev/vg1/lv1 #卸载
* mkfs.xfs -f /dev/vg1/lv1 #格式化xfs,需要
* lvresize -L 300M /dev/vg1/lv1 重新设置卷大小

* e2fsck -f /dev/vg1/lv1 #检查磁盘错误（xfs不能做此操作）
* resize2fs /dev/vg1/lv1 #更新逻辑卷信息（xfs能做此操作）
*做上面两个操作后mount不上会显示有文件系统多种格式，利用wipefs  -a /dev/vg1/lv1可以檫出格式化信息（或者wipefs -t xfs /dev/vg1/lv1保留xfs格式），
然后重新格式化不执行原因此两部操作，此操作会更新super-block导致
系统会存在两个格式，导致出错*

* xfs_growfs  /dev/vg1/lv1 #xfs_growfs 需要挂载才能执行操作
* df -T #查看挂载的格式
## 扩展卷组

* fdisk /dev/sdb     #新增/dev/sdb5 2G
* pvcreate /dev/sdb5  #创建物理卷
* vgextend vg1 /dev/sdb5 #把磁盘5加入卷组vg1
* lvresize -L 100M /dev/vg1/lv1 #重新设置卷大小
* pvs  #查看卷组情况
```
[root@xujb01 mnt]# pvs
  PV         VG  Fmt  Attr PSize    PFree
  /dev/sdb1  vg1 lvm2 a--  1020.00m 720.00m
  /dev/sdb3  vg1 lvm2 a--   496.00m 496.00m
  /dev/sdb5  vg1 lvm2 a--    96.00m  96.00m    #新加的100M磁盘，没有寻找到sbb5使用partprobe /dev/sdb5后可以找到，好像设置磁盘1M就找不到磁盘


```

 ##移除物理卷
* 删除分区的时候会出现警告信息

```

WARNING: Re-reading the partition table failed with error 16: 设备或资源忙.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)

```

* 删除逻辑卷组即解决

```

[root@xujb01 mnt]# lvremove vg1
WARNING: Device for PV YtQpSx-YkMp-d8UB-qIfZ-1b2Z-GTaQ-A21sFX not found or rejected by a filter.
WARNING: Device for PV u3OEJm-BEdI-Ucmx-sh3i-KUOj-VU7T-Ba6RsW not found or rejected by a filter.
Do you really want to remove active logical volume vg1/lv1? [y/n]: y
Logical volume "lv1" successfully removed

```

 * 下次应该一步一步从lv-vg-pv逐渐删除然后在删除分区

** 命令记录：**



命令             |  pv               |    vg         |    lv   

:----------------|:-----------------:|:-------------:|:---------------:

 查找scan   |      pvscan    |     vgscan|   lvscan

显示display| pvdisplay      | vgdisplay  | lvdisplay

增加extend|                      | vgextend |  lvextend(lvresize)

减少reduce |                    | vgreduce | lvreduce(lvresize)

删除remove|   pvremove | vgremove  | lvremove

改变容量resize|               |                   | lvresize

改变属性attribute| pvchange|vgchange|lvchange












