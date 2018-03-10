#20180309
徐江波

192.168.200.155    lvs1  #冯旭东
192.168.200.156    lvs2  #林柏圣
192.168.200.157    zabbix  #余明朕
192.168.200.158    rs1  #赵升
192.168.200.159    rs2  #赵升
192.168.200.160    rs3  #徐江波
192.168.200.161    rs4  #徐江波
192.168.200.165    nfs1  #黄达平
192.168.200.166    nfs2  #黄达平
192.168.200.167    mem1   #成晓敏
192.168.200.168    mem2   #成晓敏
192.168.200.169    db-master1   #谢涛主   徐江波配合
192.168.200.170    db-master2   #谢涛   徐江波
192.168.200.171    db-slave1     #谢涛   徐江波
192.168.200.172    db-slave2     #谢涛   徐江波
# 192.168.200.162
# 192.168.200.163
# 192.168.200.164
192.168.200.161    zrlog.team5.cn
--------------------------------------------
# web 和 数据库

介绍:
web:
web包括 discuz dedecms zrlog
dscuz dedecms 用 nginx
zrlog 使用 nginx代理 tomcat
数据库:
使用双主双从 并且双主实行高可用

* web 访问域名 zrlog.team5.cn bbs.team5.cn cms.team5.cn
*web和数据库连接 使用 vip 192.168.200.180
* mysql:
  数据库   表名     用户名   密码 
  discuz   discuz   discuz   123456
  dedecms  dedecms  dedcms   123456
  zrlog    zrlog    zrlog    123456

# nfs 静态文件 备份 
* //192.168.200.166 nfs2 备份 nfs1的
* 59 23 * * * /root/./auto_backup.sh //每天凌晨开始备份nfs的静态文件 crontab -e
* auto_backup.sh地址:https://github.com/crawlering/note/blob/master/task/auto_backup.sh

# nfs 自动 挂载
* 开机启动自动探测性挂载auto_mount_nfs.sh地址:https://github.com/crawlering/note/blob/master/task/auto_mount_nfs.sh
* rc.local 增加: bash /root/auto_mount_nfs.sh&

# nfs1 rs静态文件挂载
* mount -t nfs 192.168.200.165:/home/nfsdir /data/nfstest
* nfstest: 挂载上去使用软链接到各处

    /data/www/tomcat/zrlog/attached -> /data/nfstest/tomcat/attached/
    /data/www/discuz/data/attachment -> /data/nfstest/discuz
    /data/www/dedecms/uploads -> /data/nfstest/dedecms



