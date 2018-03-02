# linux 监控平台

常见开源监控软件

* cacti、nagios、zabbix、smokeping、open-falcon等等
* cacti、smokeping偏向于基础监控，成图非常漂亮
* cacti、nagios、zabbix服务端监控中心，需要php环境支持，其中zabbix和cacti都需要mysql作为数据存储，nagios不用存储历史数据，注重服务或者监控项的状态，zabbix会获取服务或者监控项目的数据，会把数据记录到数据库里，从而可以成图
* open-falcon为小米公司开发，开源后受到诸多大公司和运维工程师的追捧，适合大企业，滴滴、360、新浪微博、京东等大公司在使用这款监控软件，值得研究
 后续以介绍zabbix为主

## zabbix介绍

* C/S架构，基于C++开发，监控中心支持web界面配置和管理
* 单server节点可以支持上万台客户端
* 最新版本3.4，官方文档https://www.zabbix.com/manuals
 
* 5个组件
* zabbix-server 监控中心，接收客户端上报信息，负责配置、统计、操作数据
* 数据存储 存放数据，比如mysql
* web界面 也叫web UI，在web界面下操作配置是zabbix简单易用的主要原因
* zabbix-proxy 可选组件，它可以代替zabbix-server的功能，减轻server的压力
* zabbix-agent 客户端软件，负责采集各个监控服务或项目的数据，并上报

## 安装zabbix

服务器安装:

* 官网下载地址 www.zabbix.com/download
* 可以按照官网: rpm -i http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm #先安装yum源
   此时多了 /etc/yum.repo.d/zabbix.repo 文件
* yum install -y zabbix-agent zabbix-get zabbix-server-mysql zabbix-web zabbix-web-mysql #比官网多安装了zabbix-get 和 zabbix-web
  方便后面调试需要
* 上面安装会连带安装httpd和php
* 如果没有mysql先安装mysql

### 创建zabbix数据库并初始化
 
* mysql -uroot -p #确定数据库正常启动
* create database zabbix character set utf8 collate utf8_bin; #创建数据库
* grant all privileges on zabbix.* to zabbix@‘127.0.0.1’ identified by 'password'; #创建数据库zabbix登入用户
* quit
* zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix # 导入zabbix数据库数据，安装zabbix一起安装的

*数据库中需要配置 my.cnf 文件 character_set_server=utf8*

配置 zabbix server 数据库

* vi /etc/zabbix/zabbix_server.conf

```bash
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=password
```

* systemctl start zabbix-server
* systemctl enable zabbix-server #开机启动 测试的时候可以不开启
* netstat -anutp | grep zabbix #查看监听端口

客户端安装

* rpm -i http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
* yum install -y zabbix-agent

* vim /etc/zabbix/zabbix_agentd.conf

```bash
Server=192.168.31.20 //定义服务器端的ip(被动模式)
ServerActive=192.168.31.20 //定义服务器端的ip(主动模式)
Hostname=xujb01 //自定义主机名，一会需要在服务器端web界面下设置同样的主机名
```

* systemctl start zabbix-agent
* systemctl enable zabbix-agent #开机启动


主动模式和被动模式的理解:

主动和被动模式是相对客户端来讲的，客户端主动发送汇报信息，服务端listen状态，此时为主动模式，
客户端为listen模式，服务器去项客户端寻求信息，客户端listen到寻求信息，然后发送采集到的汇报信息，此为被动模式
**当客户端数量非常多时，建议使用主动模式，这样可以降低服务端的压力 ?
服务端有公网IP 客户端只有外网ip 但却能连外网，这种场合适合主动模式**


### zabbix web端介绍

首先文本中一级标题有: 监测中 资产记录 报表 配置 管理

####监测中

包括: 仪表板 问题 概述 web监测 最新数据 触发器 图形 聚合图形 拓扑图 自动发现 服务

其中 **图形**是可以看到 设置的 图形监测的 图形

### 配置

包括: 主机群主 模版 主机 维护 动作 关联项事件 自动发现 服务

主机群主: 为主机的集合

模版: 制作的主机监测模版，详细主机中介绍

主机: 为设定的主机 制定 监测项目

* 选项有: 应用集 监控项 触发器 图形 自动发现 web检测 接口

* 应用集: 为监控项集合，就像 监控项是散装的，而监控项把他们 分门别类后打包起来，拥有相同属性的一组就是一个应用集组
比如有: CPU Filesystems General Memory Network interfaces 等组
可以点击创建应用集进行创建应用集

* 监控项: 为监控 系统具体项目的设置

    创建监控项:
WEB中点击创建监控项并填写相应项目:
键值: 在/etc/zabbix/zabbix_agentd.conf UserParameter=estab.count[*],/usr/local/sbin/estab.sh 中的 estab.count 
类型: 其中最常用的 zabbix客户端 和 zabbix客户端(主动式) 有主动式标记的为 主动模式

在客户端编辑 /etc/zabbix/zabbix_agentd.conf 设置属性

```bash
UnsafeUserParameters=1
UserParameter=estab.count[*],/usr/local/sbin/estab.sh # estab.count 为键名 [*]为 参数项 后面为执行为执行脚本位置
```

* 触发器: 制作告警规则

创建触发器: 

名称:定义名称
严重性:定义这条告警规则的 告警级别
表达式:定义 告警规则

* 图形: 设置 监控项目 图形呈现
* 自动发现规则: 自动侦测项目接口 类似于 监控项，里面也有 监控项 触发器等项目
* web场景: 监测和不同于主机的另外个web服务 主要设置为 步骤-要求的状态码,和设置 相关触发器，设置触发器的时候 表达式选择相应
   web场景的 监控项



## 邮件告警设置

* 使用163或者QQ邮箱发告警邮件
* 首先登录你的163邮箱，设置开启POP3、IMAP、SMTP服务
* 开启并记录授权码
* 然后到监控中心设置邮件告警
  “管理”，“报警媒介类型”，“创建媒体类型”
  添加脚本参数:{ALERT.SENDTO} ，{ALERT.SUBJECT}，{ALERT.MESSAGE}

* 创建用户: #创建一个接受告警邮件的用户
    报警媒介设置 监控中心中设置过的 报警媒介
    权限: 给读写权限

* 创建一个动作: 

名称 

操作-默认信息修改：
HOST:{HOST.NAME} {HOST.IP}
TIME:{EVENT.DATE}  {EVENT.TIME} 
LEVEL:{TRIGGER.SEVERITY} 
NAME:{TRIGGER.NAME}
messages:{ITEM.NAME}:{ITEM.VALUE}
ID:{EVENT.ID}

    
操作-新的 发送到用户： 选择前面创建的用户
          仅送到 ： 选择前面设置的报警媒介
恢复 执行的操作类似

* 编写发送脚本(前面定义了脚本名称mail.py)

所以编写 mail.py 内容为:

```BASH 
#!/usr/bin/env python
#-*- coding: UTF-8 -*-
import os,sys
reload(sys)
sys.setdefaultencoding('utf8')
import getopt
import smtplib
from email.MIMEText import MIMEText
from email.MIMEMultipart import MIMEMultipart
from  subprocess import *
def sendqqmail(username,password,mailfrom,mailto,subject,content):
    gserver = 'smtp.163.com'
    gport = 25
    try:
        msg = MIMEText(unicode(content).encode('utf-8'))
        msg['from'] = mailfrom
        msg['to'] = mailto
        msg['Reply-To'] = mailfrom
        msg['Subject'] = subject
        smtp = smtplib.SMTP(gserver, gport)
        smtp.set_debuglevel(0)
        smtp.ehlo()
        smtp.login(username,password)
        smtp.sendmail(mailfrom, mailto, msg.as_string())
        smtp.close()
    except Exception,err:
        print "Send mail failed. Error: %s" % err
def main():
    to=sys.argv[1]
    subject=sys.argv[2]
    content=sys.argv[3]
##定义QQ邮箱的账号和密码，你需要修改成你自己的账号和密码（请不要把真实的用户名和密码放到网上公开，否则你会死的很惨）
    sendqqmail('123xujiangbo@163.com','bo5722436','123xujiangbo@163.com',to,subject,content)
if __name__ == "__main__":
    main()
    
    
#####脚本使用说明######
#1. 首先定义好脚本中的邮箱账号和密码
#2. 脚本执行命令为：python mail.py 目标邮箱 "邮件主题" "邮件内容"
```

*脚本放在 /usr/lib/zabbix/alertscripts 目录中 #可以根据grep "AlertScriptsPath=" /etc/zabbix/zabbix_server.conf 查询脚本目录位置*


* 然后进行测试 #可以关闭客户端的 zabbix-agent 服务





