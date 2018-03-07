十四周一次课（1月19日）
16.1 Tomcat介绍
16.2 安装jdk
16.3 安装Tomcat

扩展
java容器比较 http://my.oschina.net/diedai/blog/271367 

  
  http://www.360doc.com/content/11/0618/21/16915_127901371.shtml 

  j2ee、j2se、ejb、javabean、serverlet、jsp之间关系 http://bbs.csdn.net/topics/50015576 

  tomcat server.xml配置详解  http://blog.csdn.net/yuanxuegui2008/article/details/6056754 

  tomcat常用数据库连接的方法  http://wjw7702.blog.51cto.com/5210820/1109263
  ---------------------------------------------------------------------------------
  十四周二次课（1月22日）
16.4 配置Tomcat监听80端口
16.5/16.6/16.7 配置Tomcat虚拟主机
16.8 Tomcat日志

扩展
邱李的tomcat文档 https://www.linuser.com/forum.php?mod=forumdisplay&fid=37 

JAR、WAR包区别  http://blog.csdn.net/lishehe/article/details/41607725 

tomcat常见配置汇总  http://blog.sina.com.cn/s/blog_4ab26bdd0100gwpk.html 

resin安装 http://fangniuwa.blog.51cto.com/10209030/1763488/ 

1 tomcat  单机多实例
http://www.ttlsa.com/tomcat/config-multi-tomcat-instance/ 

2 tomcat的jvm设置和连接数设置
http://www.cnblogs.com/bluestorm/archive/2013/04/23/3037392.html 

3 jmx监控tomcat
http://blog.csdn.net/l1028386804/article/details/51547408 

4 jvm性能调优监控工具jps/jstack/jmap/jhat/jstat
http://blog.csdn.net/wisgood/article/details/25343845 

 
http://guafei.iteye.com/blog/1815222 

5 gvm gc 相关
http://www.cnblogs.com/Mandylover/p/5208055.html 

http://blog.csdn.net/yohoph/article/details/42041729 
---------------------------------------------------------------

# Tomcat 

## Tomcat 介绍

 Tomcat是Apache软件基金会（Apache Software Foundation）的Jakarta项目中的一个核心项目，由Apache、Sun和其他一些公司及个人共同开发而成。
 java程序写的网站用tomcat+jdk来运行
 tomcat是一个中间件，真正起作用的，解析java脚本的是jdk
 jdk（java development kit）是整个java的核心，它包含了java运行环境和一堆java相关的工具以及java基础库。
 最主流的jdk为sun公司发布的jdk，除此之外，其实IBM公司也有发布JDK，CentOS上也可以用yum安装openjdk

网上解释:
* Apache是web服务器，Tomcat是应用（java）服务器，它只是一个servlet容器，是Apache的扩展。*
*Apache和Tomcat是独立的，在通一台服务器上可以集成*
*Apache是一辆卡车，上面可以装一些东西如html等。但是不能装水，要装水必须要有容器（桶），Tomcat就是一个桶（装像Java这样的水），而这
    个桶也可以不放在卡车上。*

### Java SE EE ME 解介绍

* Java SE(Java Platform, Standard Edition): java平台标准版，Java SE包括用于开发Java Web服务的类库，
  同时，Java SE为Java EE和Java ME提供了基础，Java SE 就是基于JDK和JRE的
* Java EE(Java Platform,Enterprise Edition):java 企业版
* Java ME(Java Platform, Micro Edition): java 微软版本，又称 J2ME，
  是为机顶盒、移动电话和PDA之类嵌入式消费电子设备提供的Java语言平台，包括虚拟机和一系列标准化的Java API。
* Java ME与Java SE、Java EE一起构成Java技术的三大版本，通过JCP（Java Community Process）制订

## 安装配置tomcat

* 下载安装jdk
* 下载安装tomcat
* 运行tomcat
* 配置tomcat监听端口80
* 配置tomcat虚拟机
* 配置认识 tomcat 日志


### 下载安装jdk

jdk版本1.6，1.7，1.8

* wget -O jdk-8u161-linux-x64.tar.gz--no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz


* tar -zxvf jdk-8u161-linux-x64.tar.gz--no-check-certificate
* /etc/init.d/nginx restart
* mv jdk1.8.0_144 /usr/local/jdk1.8
* vi /etc/profile //最后面增加
   JAVA_HOME=/usr/local/jdk1.8/
   JAVA_BIN=/usr/local/jdk1.8/bin
   JRE_HOME=/usr/local/jdk1.8/jre
   PATH=$PATH:/usr/local/jdk1.8/bin:/usr/local/jdk1.8/jre/bin
   CLASSPATH=/usr/local/jdk1.8/jre/lib:/usr/local/jdk1.8/lib:/usr/local/jdk1.8/jre/lib/charsets.jar 

* source /etc/profile
* java -version

### 下载安装tomcat

* wget http://apache.fayea.com/tomcat/tomcat-8/v8.5.20/bin/apache-tomcat-8.5.20.tar.gz
* tar zxvf apache-tomcat-8.5.20.tar.gz
* mv apache-tomcat-8.5.20 /usr/local/tomcat
* /usr/local/tomcat/bin/startup.sh
* ps aux|grep tomcat
* netstat -lntp |grep java
  三个端口8080为提供web服务的端口，8005为管理端口，8009端口为第三方服务调用的端口，比如httpd和Tomcat结合时会用到
* web端访问 ip:8080 # iptables 通过8080端口: iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT

### tomcat 监听端口80

* vim /usr/local/tomcat/conf/server.xml
    Connector port="8080" protocol="HTTP/1.1"修改为Connector port="80" protocol="HTTP/1.1"
* /usr/local/tomcat/bin/shutdown.sh  #停止服务
* /usr/local/tomcat/bin/startup.sh   #启动服务
*每次修改配置文件都要停止服务重新启动*
* iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

### 配置 tomcat 的虚拟主机

* vim /usr/local/tomcat/conf/server.xml
    其中<Host>和</Host>之间的配置为虚拟主机配置部分，name定义域名，
    appBase定义应用的目录，Java的应用通常是一个war的压缩包，你只需要将war的压缩包放到appBase目录下面即可。
    而docBase: 定义网站的文件存放路径， 不定义默认是在在 appBase/ROOT里。
    增加虚拟主机，编辑server.xml,在</Host>下面增加如下内容

```BASH    
    <Host name="www.testtom.cn" appBase=""
        unpackWARs= "true" autoDeploy="true"
        xmlValidation="false" xmlNamespaceAware="false">
        <Context path="" docBase="/data/www/tom/" debug="0" reloadable="true" crossContext="true"/>
    </Host>
```
#### server.xml 部分参数介绍
 
* docBase，这个参数用来定义网站的文件存放路径，如果不定义，默认是在appBase/ROOT下面，
  定义了docBase就以该目录为主了，其中appBase和docBase可以一样。网页目录在这里设定
  docBase:默认 是以appBase开始为相对目录的
  *在这一步操作过程中很多同学遇到过访问404的问题，其实就是docBase没有定义对。*
* appBase 为主机目录，为docBase的相对路径的基本目录，一些基本配置在该目录里比如manage等环境配置文件,
  相对目录是从安装tomcat的目录开始
* unpackWARs 设置为true，自动解包WAR文件*放应用war格式文件在webapps中会自动解压，不过需要几秒的时间可以 ls 查看*

Example:
 *zrlog,简易博客*
 下面我们通过部署一个java的应用来体会appBase和docBase目录的作用
 下载zrlog wget http://dl.zrlog.com/release/zrlog-1.7.1-baaecb9-release.war
 mv zrlog-1.7.1-baaecb9-release.war /usr/local/tomcat/webapps/
 mv /usr/local/tomcat/webapps/zrlog-1.7.1-baaecb9-release /usr/local/tomcat/webapps/zrlog
 mv /usr/local/tomcat/webapps/zrlog/* /data/www/tom

 浏览器访问 ip:8080/zrlog/install/ #浏览器提示需要设置zrlog数据文件，重新设置需要删除rm /data/www/tom/WEB-INF/install.lock

* 数据库添加 zrlog数据库:
    CREATE DATABASE zrlog;
    GRANT ALL PRIVILEGES  ON zrlog.* to zrlog@'127.0.0.1' IDENTIFIED BY '123456';
* 然后登入 创建的帐号是否正常登入

*期间登入不进去，查看日志tail -f logs/catalina.out: 'IllegalArgumentException: An invalid domain' 百度知道不支持'_'下划线引起 把test_tom 改成testtom*


## tomcat 日志

具体方法是在对应虚拟主机的<Host></Host>里面加入下面的配置（假如域名为123.cn）：
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
         prefix="123.cn_access" suffix=".log"
         pattern="%h %l %u %t &quot;%r&quot; %s %b" />
prefix定义访问日志的前缀，suffix定义日志的后缀，pattern定义日志格式。
新增加的虚拟主机默认并不会生成类似默认虚拟主机的那个localhost.日期.log日志，
错误日志会统一记录到catalina.out中。关于Tomcat日志，你最需要关注catalina.out，当出现问题时，我们应该第一想到去查看它。

