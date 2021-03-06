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
Hostname=xujb01 //自定义主机名(为客户端的名字，后面服务器添加项目时需要)，一会需要在服务器端web界面下设置同样的主机名
```

* systemctl start zabbix-agent
* systemctl enable zabbix-agent #开机启动
* 服务器端10051 端口 客户端 10050端口 默认

主动模式和被动模式的理解:

主动和被动模式是相对客户端来讲的，客户端主动发送汇报信息，服务端listen状态，此时为主动模式，
客户端为listen模式，服务器去项客户端寻求信息，客户端listen到寻求信息，然后发送采集到的汇报信息，此为被动模式
**当客户端数量非常多时，建议使用主动模式，这样可以降低服务端的压力 ?
服务端有公网IP 客户端只有外网ip 但却能连外网，这种场合适合主动模式**

 
### 访问web

* systemctl start httpd 
* 浏览器访问:http://ip/zabbix
* 安装zabbix
  PHP option "date.timezone" fail: /etc/httpd/conf.d/zabbix.conf
  <IfModule mod_php5.c> 中 # php_value date.timezone Europe/Riga 改成 php_value date.timezone Asia/Shanghai
  重启httpd服务
  或者 vim /etc/php.ini： date.timezone = Asia/Shanghai
* web登入初始密码: Admin zabbix
* 在用户那里设置语言 修改密码	
 
### 后台修改zabbix密码
 

*  进入mysql命令行，选择zabbix库
*  mysql -uroot -p zabbix
*  update users set passwd=md5(‘newpasswd’) where alias=‘Admin’;
*  这样就更改了Admin用户的密码

## 创建一个监控主机
 
* 配置-创建主机组
* 创建一个新建模版(方便以后设置主机)
  1、先创建一个空模版(群组选择 templates)
  2、在空模版里 链接的模版 选择适合的模版 template os linux，保存后
  3、取消链接，但是模版保存下来了
  4、然后其他需要添加的项目 到其他模版里复制项目到 创建模版中
    自动发现项没有 复制(也可以在链接模版的时候就设置好)
    (导出一个模版的xml文件，删除其他配置，只留自动发现，然后导入)
* 然后创建主机-选择群组-选择添加监控主机IP 端口 -链接模版(之后记得取消模版)

* 检测图形-下方有乱码
   设置为中文后，zabbix图形的中文文字会显示小方框
   这是因为在zabbix的字体库中没有中文字体，需要从windows上借用一个过来
   vim /usr/share/zabbix/include/defines.inc.php //搜索ZBX_FONTPATH
   它定义的路径是“fonts”，它是一个相对路径，绝对路径为/usr/share/zabbix/fonts，而字体文件为“ZBX_GRAPH_FONT_NAME”所定义的“graphfont”，它是一个文件，绝对路径为/usr/share/zabbix/fonts/graphfont
   windows字体路径为“C:\Windows\Fonts\”，找到“simfang.ttf”(其实就是那个仿宋简体)，先把它复制到桌面上，然后上传到linux的/usr/share/zabbix/fonts/，并且改名为graphfont.ttf
   chmod 777 granphfont.ttf //然后刷新页面，不需要重启   

## 自定义一个监控项
 
* vim /usr/local/etc/zabbix_scripts/check_httpd.sh:
  
  ```BASH
# 判断httpd服务是否起来，起来返回数据0，
# 没有则返回1
  #!/bin/bash

result=`ps -ef | grep httpd | grep -v grep | grep -v check_httpd`  //grep -v check_httpd 过滤脚本名字
if [ -n "$result" ]
then
    echo "0"

else
    echo "1"

fi
  ```

* vim /etc/zabbix/zabbix_agentd.d/check_httpd.conf //配置脚本执行参数，定义 键值
   UnsafeUserParameters=1 设置 允许用户自定义参数中传递所有字符  
   UserParameter=<key>,<command>
   UserParameter=key[*],command //[*]定义该Key接收括号内的参数。在配置监控项时给出参数。

```bash
UnsafeUserParameters=1
UserParameter=check_httpd,/usr/local/etc/zabbix_scripts/check_httpd.sh

```

* agent 端测试 设置的键值是否 有用: zabbix_agentd -t mysql.questions
* server 端测试 设置客户端的键值传输: 	zabbix_get -s 207.246.96.252 -p 10050 -k check_httpd
* 服务端server 设置serveractive模式(客户端主动模式 ) 在设置主机中agent代理程序的接口:填写ip:0.0.0.0 端口:0
  客户端主动模式才有用	

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
  “管理”，“报警媒介类型”，“创建媒体类型” 类型:脚本
  添加脚本参数:{ALERT.SENDTO} ，{ALERT.SUBJECT}，{ALERT.MESSAGE}

* 创建用户: #创建一个接受告警邮件的用户
    报警媒介设置 监控中心中设置过的 报警媒介
    权限: 给读写权限(如果报警不成功请把群组 给某个主机 读写权限)

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
        msg = MIMEText(unicode(content).encode('utf-8')) //发送中文乱码
	msg = MIMEText(content,format,"utf-8")
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
    sendqqmail('123xujiangbo@163.com','123456','123xujiangbo@163.com',to,subject,content)
    sendqqmail('123xujiangbo@163.com','123456','123xujiangbo@163.com',to,subject,content)
if __name__ == "__main__":
    main()
    
    
#####脚本使用说明######
#1. 首先定义好脚本中的邮箱账号和密码
#2. 脚本执行命令为：python mail.py 目标邮箱 "邮件主题" "邮件内容"
```

*脚本放在 /usr/lib/zabbix/alertscripts 目录中 #可以根据grep "AlertScriptsPath=" /etc/zabbix/zabbix_server.conf 查询脚本目录位置*

* 阿里云服务器25端口关闭，所以需要启用ssl发送邮件 sslport=465,替换相应部分
   ```BASH

   smtp = smtplib.SMTP_SSL(host=gserver, port=sslport)
   smtp.ehlo()
   smtp.login(username,password)
   smtp.sendmail(mailfrom, mailto, msg.as_string())
   smtp.close()
  ```

* 然后在监控项中设置 一个触发器 设置 问题表现和恢复表达式
* 然后进行测试 #可以关闭客户端的 zabbix-agent 服务



* 总结发送邮箱过程
 1、 首先 要一个发送脚步在服务器:根据zabbix_server.conf "AlertScriptsPath" 指定了报警脚本的位置，给该脚本执行权限
     当然需要检验该脚本是否能正常发送邮件(mail.py)
 2、设置好后 然后在管理处 设置报警媒介 类型选择脚本 脚本名称写上方定义的名称(mail.py) 
     脚本参数 设置三个，因为脚本里也定义需要三个该参数
     {ALERT.SENDTO}  //该选项和后面设置用户 的接收邮箱应该是那里读取的
     {ALERT.SUBJECT}  // zabbix根据错误自定义的主题
     {ALERT.MESSAGE} // 动作设置默认信息
     然后启用功能，这里就设置好了 zabbix服务器 调用 报警脚本的接口
 
2.2、创建用户: 设置用户去 触发上述接口 进行报警
     创建用户 着重设置报警媒介 添加 类型选择上方刚设置的 报警名
     收件人:设置 收件箱
     然后是发送邮件提醒 的报警级别
     启用 添加
     然后是权限 对应的 监控主机 在该用户一定要读写权限， 或者所有组 设置 读写，通过设置用户类型或者去
     设置用户群组去设置权限


 3、然后设置动作 把参数信息传送给报警的用户 去发送邮件 
    首先 动作 项可以保持默认
    操作项: 默认接收人: Problem: {TRIGGER.NAME} //很明显这个是主题
    默认信息: HOST:{HOST.NAME} {HOST.IP}
              TIME:{EVENT.DATE}  {EVENT.TIME}
              LEVEL:{TRIGGER.SEVERITY}
              NAME:{TRIGGER.NAME}
              messages:{ITEM.NAME}:{ITEM.VALUE}
              ID:{EVENT.ID}
    	      //定义邮件的内容
    维护期间暂停操作: 勾选
    操作: 新的 创建
    选择发送消息给用户
    而用户里定义了 什么消息 就发送报警 到 自定义邮箱
    然后一般恢复操作也做相同的设置，确认就不用了

4、 然后就是触发报警了

过程就应该是: 触发报警 -> 用户有相应权限 去读取该主机的状态-> 读到状态 在发送邮件提醒的级别 -> 
执行动作获取 需要发送的参数 -> 然后用户通知一个设置好的 报警媒介去执行操作->
然后 报警媒介找到接口去执行相应的脚本，并把参数传给他->脚本发送邮件提醒


