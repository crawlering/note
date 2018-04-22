# saltstack 介绍

基于python开发 c/s机构 支持多平台
在远程执行命令时非常快捷 


# saltstack 安装

1、安装参照官网https://repo.saltstack.com/#rhel

2、安装准备:
   主: 47.75.74.16
   仆: 207.246.96.252
   服务端口:
   4505:消息发布端口
   4506:客户端通信端口(所以在两台主机需要开放这2个端口)


3、安装过程
   主:47.75.74.16
   安装yum源:yum -y install https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest-2.el7.noarch.rpm 
   安装主程序和仆程序:yum install -y salt-master salt-minion
   安装一些插件:yum install -y salt-ssh salt-syndic salt-cloud salt-api
   仆:207.246.96.252
   安装yum源:yum -y install https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest-2.el7.noarch.rpm 
   安装仆程序:yum install -y salt-minion

4、编辑hosts,vim /etc/hosts: 
   207.246.96.252 xujb02
   47.75.74.16 xujb01
   在minion主机中vim /etc/salt/minion:
   master: xujb01

5、配置认证:
    * minoin 服务在第一次启动会在/etc/salt/pki/minion/ 下生成 minion.pem 和 minion.pub 
    * master 服务第一次启动也会在/etc/salt/pki/master/ 下生成 “master.pem  master.pub  minions  minions_autosign  
      minions_denied  minions_pre  minions_rejected” 等文件
      当master接收到minion传过来的公钥后，通过salt-key工具接受这个公钥，一旦接受后就会在/etc/salt/pki/master/minions/
      目录里存放刚刚接受的公钥，同时客户端也会接受master传过去的公钥，把它放在/etc/salt/pki/minion目录下，
      并命名为minion_master.pub
    * 以上过程需要使用salt-key 来实现:
      salt-key -a xujb01 //添加主机xujb01 key值
        -a  后面跟主机名，认证指定主机
        -A 认证所有主机
	-r  跟主机名，拒绝指定主机
	-R  拒绝所有主机
	-d 跟主机名，删除指定主机认证
	-D 删除全部主机认证
	-y 省略掉交互，相当于直接按了y

6、saltstack 远程执行命令
    * salt '*' test.ping //对所有minion主机进行ping操作 salt 'xujb01' test.ping 对xujb01执行
    * salt '*' cmd.run 'hostname' //对minion主机进行 shell命令 hostname输出查看
      ‘*’:为minion主机匹配，可以使用通配符 列表 以及正则,是主机名可能和上面定义的本地host不一样
      salt 'myvm[23]' cmd.run 'hostname' //通配
      salt -L 'myvm2,myvm3' cmd.run 'hostname' //列表
      salt -E 'myvm.*' cmd.run 'hostname' //正则

7、saltstack grains
    * grains是在minion启动时收集到的一些信息，比如操作系统类型、网卡ip、内核版本、cpu架构等。
    * salt 'myvm2' grains.ls //查看grains所有项目名
    * salt 'myvm2' grains.items //查看grains所有项目名和对应的值
    
*grains的信息并不是动态的，并不会实时变更，它是在minion启动时收集到的*
*并且grains信息可以自定义，自定义后需要重启salt-minion服务*

    * 在minion主机上编辑:vim /etc/salt/grains 
      role: nginx
      env: test
      //注意':'后面有空格
    * 重启minion服务: systemctl restart salt-minion.service
      在master主机上获取: salt 'myvm2' grains.item role env
      可以借助grains信息进行匹配执行命令:
      salt -G role:nginx cmd.run 'hostname' //使用role属性进行分组执行某个命令

8、 saltstack pillar	
    * pillar和grains不一样，是在master上定义的，并且是针对minion定义的一些信息。
      像一些比较重要的数据（密码）可以存在pillar里，还可以定义变量等
    * 配置pillar: vim /etc/salt/master
      找到 pillar_roots: 去掉前面的#号,类似:
      pillar_roots:
        base:
          - /srv/pillar //每行比前面一行多2个空格，严格要求
     mkdir /src/pillar
     vim /src/pillar/test.sls
     
         ```bash
         conf: /etc/123.conf
         ```

     vim /src/pillar/top.sls
     
         ```bash
         base:
           'myvm2':
             - test
         ``` 

     *test.sls为项目文件 top.sls为pillar默认读取文件，然后从top.sls中读取test.sls项目*
     top.sls
     base:
       'myvm2':  //定义minion主机
         - test  //定义读取根目录test(.sls)项目
     test.sls:
     conf: /etc/123.conf //定义conf 对应值 /etc/123.conf

     salt -I "conf:/etc/123.conf" cmd.run "hostname" //类似grains匹配
     salt '*' pillar.items //查看项目值
     修改 /etc/salt/master 文件内容需要重启salt-master服务: systemctl restart salt-master.service
     修改 test.sls等文件内容需要刷新pillar:  salt '*' saltutil.refresh_pillar //*/

 
# saltstack 发布文件以及更新程序

* 在master上 /etc/salt/master:
  搜索找到file_roots:
  添加内容:
  file_roots:
    base:
      - /srv/salt

* 重启服务: systemctl restart salt-master.service	  
* mkdir /srv/salt
* vim /src/salt/top.sls
  base:
    '*':
      - test_httpd
* vim /src/salt/test_httpd.sls:
  httpd-service:
    pkg.installed:
      - names: //如果只有httpd则可以直接写成 - name: httpd
        - httpd
	- httpd-devel
    service.running:
      - name: httpd
      - enable: True

说明:
httpd-service是id的名字，自定义的。
pkg.installed 为包安装函数，下面是要安装的包的名字。
service.running也是一个函数，来保证指定的服务启动，
enable表示开机启动。
  

* 执行 salt 'myvm2' state.highstate //在myvm2执行设置项目
  ?怎么更新指定项目

配置管理文件:

* vim file_test.sls
  file_test:
    file.managed:
      - name: /tmp/xujb //转存的目标文件
      - source: salt://test/123/1.txt
      - user: root
      - group: root
      - mode: 600
说明：
第一行的file_test为自定的名字，表示该配置段的名字，可以在别的配置段中引用它，
source指定文件从哪里拷贝，这里的salt://test/123/1.txt相当于是/srv/salt/test/123/1.txt

* vim top.sls
  base:
    '*':
      - file_test
* salt '*' state.highstate //检查各个主机的/tmp/xujb 文件属性


配置saltstack 管理目录:

* vim dir_test.sls
  dir_test:
    file.recurse:
      - name: /tmp/testdir
      - source: salt://test/123/
      - use: root
      - file_mode: 640
      - dir_mode: 750
      - mkdir: True
      - clean: True //加上该参数源文件删除或目录，目标也会跟着删除，否则不会删除

* 修改 top.sls
  base:
    '*':
      - dir_test
* salt '*' state.highstate //执行配置项目

说明：这里有一个问题，如果source对应的目录里有空目录的话(目录里没有文件)，客户端上不会创建该目录
 

配置 saltstack 管理远程命令

* vim test_shell.sls
  shell_test:
    cmd.script:
      - source: salt://test/1.sh
      - user: root
* vim top.sls
  base:
    '*':
      - test_shell
* vim test/1.sh;chmod +x 1.sh

```bash
#!/bin/bash
touch /tmp/111.txt
if [ ! -d /tmp/1]
then
  mkdir /tmp/1
fi
```

* salt '*' state.highstate


配置 saltstack 管理任务计划

* vim test_cron.sls
  cron_test:
  cron.present:
    - name: /bin/touch /tmp/111.txt
    - user: root
    - minute: '*'
    - hour: 20
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'
注意:
'*'需要用单引号引起来。当然我们还可以使用file.managed模块来管理cron，因为系统的cron都是以配置文件的形式存在的。
想要删除该cron，需要增加：
cron.absent:
  - name: /bin/touch /tmp/111.txt
两者不能共存，要想删除一个cron，那之前的present就得去掉。

* 其他步骤省略

saltstack 其他可能用到的命令

* cp.get_file 拷贝master上的文件到客户端
  salt '*' cp.get_file salt://test/1.txt  /tmp/123.txt
* cp.get_dir 拷贝目录
  salt '*' cp.get_dir salt://test/conf /tmp/ //会自动在客户端创建conf目录，所以后面不要加conf，如果写成 /tmp/conf/  则会在/tmp/conf/目录下又创建conf
* salt-run manage.up  显示存活的minion
* salt '*' cmd.script salt://test/1.sh  命令行下执行master上的shell脚本
 
# salt-ssh使用

* salt-ssh不需要对客户端做认证，客户端也不用安装salt-minion，它类似pssh/expect
* 按照上面安装 yum 源
* yum install -y salt-ssh
* vi /etc/salt/roster //增加如下内容
  xujb01:
    host: ip1
    user: root
    passwd: 123456
  xujb02:
    host: ip2
    user: root
    passwd: 123456
* salt-ssh --key-deploy '*' -r 'w' //第一次执行的时候会自动把本机的公钥放到对方机器上，
  然后就可以把roster里面的密码去掉,第一ssh时可能会报错254 需要手动ssh主机一次 
  'w' 为执行命令


# 总结

* salt 分为 salt-key salt 和salt-ssh 管理
* salt-key: 
  pillar: 打开功能 master文件: pillar_roots
  grains: 创建 /etc/salt/grains 
  批量发布: 打开功能 master: file_roots
    其中包括:
    对文件管理: file.managed:
    对目录管理: file.recurse:
    对脚本执行管理：cmd.script:
    对cron管理: cron.present: //添加cron
                cron.absent: //删除cron
    对服务管理: pkg.installed: //安装
                service.running: //启动服务


