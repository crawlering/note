
#20171108
���ܵڶ��οΣ�11��07�գ�
5.1 vim����
5.2 vim��ɫ��ʾ���ƶ����
5.3 vimһ��ģʽ���ƶ����
5.4 vimһ��ģʽ�¸��ơ����к�ճ��

#vim
1. һ��ģʽ
2. ����ģʽ
3. ����ģʽ

##vim ��ɫ����
* ���û�Ŀ¼�±༭.viminfo ��� :colorscheme desert
* ��PUTTY�����ɫwindows-colours
```
Default Foreground 89 166 114
default Background 10 10 10
ANSI Blue 117 117 0
```
## ����ģʽ�¹����ƶ�

###���ڲ���
* ���������ƶ���j k h l # nj �����ƶ�n��
* ���ʼ��ƶ���꣺w(����ƶ�һ�����ʣ�nw����ƶ�n������) b����ǰ�ƶ�1�����ʣ�nb��,���ͣ�ڵ�����λ
		  e������ƶ�1�����ʣ����ͣ�ڵ���ĩβ
* �ƶ������ס���β��^(����0) $
* �������������ַ�������fx(����nfx)������Fx(����nFx)����   
###�в���
* gg G �����������µĿ�ͷ�ͽ�β
* �����ƶ� (c+d)��(c+u) ��ǰ�����ƶ�����
* ȫ���ƶ�(c+f)(c+b)�����ƶ�������һ����Ļ������
* ngg����nG �ƶ�����n��
* zz zt zb �ѵ�ǰ��������м䡢�������ײ�

##�����ַ�
* `/` `?` ���¡��������� 
* ���ͣ�ڵ���λ�ð� `*`���������Ĵ�
* n N �����ؼ��ֺ� ������������
* `:set ignorecase`,`:set noignorecase` ���Դ�Сд�������Դ�Сд

##

#20171106
���ܵ�һ�ο�(11��06�գ�
4.10/4.11/4.12 lvm����
4.13 ���̹���С����

##һ��lvm

**pv�������->vg�����飩->lv���߼���**

* fdisk /dev/sdb #������������ sdb1 sdb2 sdb3ÿ��1G  
`fdisk /dev/sdb n t�޸ķ�����ʽ��8e->lvm`

* pvcreate  /dev/sdb1                 #���������
`yum provides "/*/pvcreate"   yum -y install  lvm2`
```
����404���󣬺�yum update����yum����/boot�������㣬Ȼ���ҵ�/boot
��40M���ļ����Ƶ�/mnt�£�ɾ��Դ�ļ��������������ӣ�Ȼ��update yum
��yum provides "/*/pvcreateѰ�Ҳ������ lvm2
```

* partprobe #�ֶ����·�����Ϣ��û�г���/dev/sdb1��ʱ��

* pvdisplay

* pvs


*  vgcreate vg1 /dev/sdb1 /dev/sdb2                 #������

* vgdisplay      pvs

* lvcreate -L 100M -n lv1 vg1  #�����߼���

* lvs #�鿴�߼���
* mkfs.ext4 /dev/vg1/lv1       #��ʽ��

* moount /dev/vg1/lv1 /mnt/lv #����

## �����߼���

* lvresize -L 200M /dev/vg1/lv1
* e2fsck -f /dev/vg1/lv1     #������ ��Ҫ�Ѵ���ж��

* resize2fs /dev/vg1/lv1 #�����߼�����Ϣ


##�����߼��� ��xfs��֧�֣�
* umount

* e2fsck -f /dev/vg1/lv1

* resize2fs /dev/vg1/lv1 #�����߼�����Ϣ

* lvresize -L 100M /dev/vg1/lv1 #����
* lvs             #�鿴�߼�����Ϣ
* blkid /dev/vg1/lv1 #�鿴�߼����ʽ

## ����xfs ������Ҫж�أ�
* blkid /dev/vg1/lv1 #�鿴���߼����ʽ
* umout /dev/vg1/lv1 #ж��
* mkfs.xfs -f /dev/vg1/lv1 #��ʽ��xfs,��Ҫ
* lvresize -L 300M /dev/vg1/lv1 �������þ��С

* e2fsck -f /dev/vg1/lv1 #�����̴���xfs�������˲�����
* resize2fs /dev/vg1/lv1 #�����߼�����Ϣ��xfs�����˲�����
*����������������mount���ϻ���ʾ���ļ�ϵͳ���ָ�ʽ������wipefs  -a /dev/vg1/lv1�����߳���ʽ����Ϣ������wipefs -t xfs /dev/vg1/lv1����xfs��ʽ����
Ȼ�����¸�ʽ����ִ��ԭ��������������˲��������super-block����
ϵͳ�����������ʽ�����³���*

* xfs_growfs  /dev/vg1/lv1 #xfs_growfs ��Ҫ���ز���ִ�в���
* df -T #�鿴���صĸ�ʽ
## ��չ����

* fdisk /dev/sdb     #����/dev/sdb5 2G
* pvcreate /dev/sdb5  #���������
* vgextend vg1 /dev/sdb5 #�Ѵ���5�������vg1
* lvresize -L 100M /dev/vg1/lv1 #�������þ��С
* pvs  #�鿴�������
```
[root@xujb01 mnt]# pvs
  PV         VG  Fmt  Attr PSize    PFree
  /dev/sdb1  vg1 lvm2 a--  1020.00m 720.00m
  /dev/sdb3  vg1 lvm2 a--   496.00m 496.00m
  /dev/sdb5  vg1 lvm2 a--    96.00m  96.00m    #�¼ӵ�100M���̣�û��Ѱ�ҵ�sbb5ʹ��partprobe /dev/sdb5������ҵ����������ô���1M���Ҳ�������


```

 ##�Ƴ������
* ɾ��������ʱ�����־�����Ϣ

```

WARNING: Re-reading the partition table failed with error 16: �豸����Դæ.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)

```

* ɾ���߼����鼴���

```

[root@xujb01 mnt]# lvremove vg1
WARNING: Device for PV YtQpSx-YkMp-d8UB-qIfZ-1b2Z-GTaQ-A21sFX not found or rejected by a filter.
WARNING: Device for PV u3OEJm-BEdI-Ucmx-sh3i-KUOj-VU7T-Ba6RsW not found or rejected by a filter.
Do you really want to remove active logical volume vg1/lv1? [y/n]: y
Logical volume "lv1" successfully removed

```

 * �´�Ӧ��һ��һ����lv-vg-pv��ɾ��Ȼ����ɾ������

** �����¼��**



����             |  pv               |    vg         |    lv   

:----------------|:-----------------:|:-------------:|:---------------:

 ����scan   |      pvscan    |     vgscan|   lvscan

��ʾdisplay| pvdisplay      | vgdisplay  | lvdisplay

����extend|                      | vgextend |  lvextend(lvresize)

����reduce |                    | vgreduce | lvreduce(lvresize)

ɾ��remove|   pvremove | vgremove  | lvremove

�ı�����resize|               |                   | lvresize

�ı�����attribute| pvchange|vgchange|lvchange












