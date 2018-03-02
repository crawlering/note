# tomcat

## tomcat manager 和 host-manager

* manager: 
  manager-gui:Access to the HTML interface.
  manager-status:Access to the "Server Status" page only.
  manager-script: Access to the tools-friendly plain text interface that is described in this document, 
                  and to the "Server Status" page.
  manager-jmx: Access to JMX proxy interface and to the "Server Status" page.

manager-gui manager-status 等可以在webapps/manager/WEB-INF/web.xml中查看到（有该定义）

* host-manager: 
  admin-gui: allows access to the HTML GUI and the status pages
  admin-script:allows access to the text interface and the status pages

admin-gui admin-script 在webapps/host-manager/WEB-INF/web.xml 中可以查看到

##打开 manager status 和host-manager

* 上面两个服务在 vim conf/tomcat-users.xml 中定义，打开该功能

    ```bash
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <user username="admin" password="123456" roles="manager-gui,admin-gui"/>
    ```

*添加多个功能类似 manager-gui和admin-gui*
*username password 定义登入账户密码*

* 在webapps/manager/META-INF/context.xml 中去打开访问IP #打开host-manager在对应位置更改
> allow="127\.0\.0\.1|192\.168\.31\.95"/> #后面添加 “|192\.168\.31\.95” 允许ip访问

## tomcat 配置文件

* appBase="webapps" # server.xml 定义webapps
 应用包括 docBase="/data/www/tom/" 网页 
测试 zrlog，其中 zrlog就是 appBase中的一个应用，也可把zrlog文件拷到/data/www/tom 下，直接访问域名就可以访问zrlog 博客

*虚拟主机可以把webapps内容考入到虚拟主机定义网页项*

* cp -r webapps/* /data/www/tom/ #其中webapps有 zrlog
* vim conf/server.xml
    
    ```BASH
     <Host name="www.testtom.com" appBase="/data/www/tom"
         unpackWARs= "true" autoDeploy="true"
         xmlValidation="false" xmlNamespaceAware="false">
         <Context path="" docBase="/data/www/tom/zrlog" debug="0" reloadable="true" crossContext="true"/>

    ```

* 默认访问zrlog，可以设置docBase="/data/www/tom/ROOT" 页面就会显示 tomcat。


## tomcat 中 jar war ear

Jar、war、EAR、在文件结构上，三者并没有什么不同，它们都采用zip或jar档案文件压缩格式。但是它们的使用目的有所区别：
　
* Jar文件（扩展名为. Jar，Java Application Archive）包含Java类的普通库、资源（resources）、辅助文件（auxiliary files）等

* War文件（扩展名为.War,Web Application Archive）包含全部Web应用程序。在这种情形下，
     一个Web应用程序被定义为单独的一组文件、类和资源，用户可以对jar文件进行封装，并把它作为小型服务程序（servlet）来访问。

* Ear文件（扩展名为.Ear,Enterprise Application Archive）包含全部企业应用程序。在这种情形下，
    一个企业应用程序被定义为多个jar文件、资源、类和Web应用程序的集合。
　　
每一种文件（.jar, .war, .ear）只能由应用服务器（application servers）、小型服务程序容器（servlet containers）、EJB容器（EJB containers）等进行处理。

*EAR文件包括整个项目，内含多个ejb module（jar文件）和web module(war文件)*


## tomcat 中 JVM 设置

设置:

* WINDOWS 在  bin/catalina.bat 添加 set JAVA_OPTS=-Xms64m -Xmx256m -XX:PermSize=128M -XX:MaxNewSize=256m -XX:MaxPermSize=256m

* linux 在  bin/catalina.sh 添加 JAVA_OPTS="-Xms128m -Xmx1024m" #设置 堆内存
  *-XX:PermSize=512m  -XX:MaxPermSize=512m  非堆内存 java 64位不支持*

堆的尺寸 
-Xmssize in bytes 
    设定Java堆的初始尺寸，缺省尺寸是2097152 (2MB)。这个值必须是1024个字节（1KB）的倍数，且比它大。
   （-server选项把缺省尺寸增加到32M。） 
-Xmnsize in bytes 
    为Eden对象设定初始Java堆的大小，缺省值为640K。（-server选项把缺省尺寸增加到2M。) 
-Xmxsize in bytes 
    设定Java堆的最大尺寸，缺省值为64M，（-server选项把缺省尺寸增加到128M。） 最大的堆尺寸达到将近2GB（2048MB）。 

请注意：很多垃圾收集器的选项依赖于堆大小的设定。请在微调垃圾收集器使用内存空间的方式之前，确认是否已经正确设定了堆的尺寸。 

垃圾收集:内存的使用 
-XX:MinHeapFreeRatio=percentage as a whole number 
    修改垃圾回收之后堆中可用内存的最小百分比，缺省值是40。如果垃圾回收后至少还有40%的堆内存没有被释放，则系统将增加堆的尺寸。 
-XX:MaxHeapFreeRatio=percentage as a whole number 
    改变垃圾回收之后和堆内存缩小之前可用堆内存的最大百分比，缺省值为70。这意味着如果在垃圾回收之后还有大于70%的堆内存，则系统就会减少堆的尺寸。 
-XX:NewSize=size in bytes 
    为已分配内存的对象中的Eden代设置缺省的内存尺寸。它的缺省值是640K。（-server选项把缺省尺寸增加到2M。） 
-XX:MaxNewSize=size in bytes 
    允许您改变初期对象空间的上限，新建对象所需的内存就是从这个空间中分配来的，这个选项的缺省值是640K。（-server选项把缺省尺寸增加到2M。） 
-XX:NewRatio=value 
    改变新旧空间的尺寸比例，这个比例的缺省值是8，意思是新空间的尺寸是旧空间的1/8。 
-XX:SurvivorRatio=number 
    改变Eden对象空间和残存空间的尺寸比例，这个比例的缺省值是10，意思是Eden对象空间的尺寸比残存空间大survivorRatio+2倍。 
-XX:TargetSurvivorRatio=percentage 
    设定您所期望的空间提取后被使用的残存空间的百分比，缺省值是50。 

-XX:MaxPermSize=size in MB 
    长久代（permanent generation）的尺寸，缺省值为32（32MB）。

查看 tomcat 的JVM 内存:

1. Tomcat6中没有设置任何默认用户，因而需要手动往Tomcat6的conf文件夹下的tomcat-users.xml文件中添加用户。

 

    如：<role rolename="manager"/>
          <user username="tomcat" password="tomcat" roles="manager"/>

    注：添加完需要重启Tomcat6。

 

2. 访问http://localhost:8080/manager/status，输入上面添加的用户名和密码。

 

3. 然后在如下面的JVM下可以看到内存的使用情况。

JVM

    Free memory: 2.50 MB Total memory: 15.53 MB Max memory: 63.56 MB

## tomcat 连接数

Tomcat的server.xml中Context元素设置一下参数

maxThreads="150" 表示最多同时处理150个连接 
minSpareThreads="25" 表示即使没有人使用也开这么多空线程等待 
maxSpareThreads="75" 表示如果最多可以空75个线程，例如某时刻有80人访问，之后没有人访问了，则tomcat不会保留80个空线程，而是关闭5个空的
acceptCount="100" 当同时连接的人数达到maxThreads时，还可以接收排队的连接，超过这个连接的则直接返回拒绝连接。 

```BASH
<Connector port="8080" 
maxThreads="150" 
minSpareThreads="25" 
maxSpareThreads="75" 
acceptCount="100" 
/>   

```

tomcat4 以下是使用 以下参数:
minProcessors：最小空闲连接线程数，用于提高系统处理性能，默认值为10
maxProcessors：最大连接线程数，即：并发处理的最大请求数，默认值为75
acceptCount：允许的最大连接数，应大于等于maxProcessors，默认值为100
enableLookups：是否反查域名，取值为：true或false。为了提高处理能力，应设置为false
connectionTimeout：网络连接超时，单位：毫秒。设置为0表示永不超时，这样设置有隐患的。通常可设置为30000毫秒

## JVM 性能调优

* http://blog.csdn.net/wisgood/article/details/25343845 JVM性能调优监控工具jps、jstack、jmap、jhat、jstat
* 官网 https://wiki.apache.org/tomcat/FAQ/Troubleshooting_and_Diagnostics?highlight=%28jmap%29    
    jinfo - 打印JVM进程信息
    jstack - 打印线程堆栈跟踪
    jmap - 转储堆并显示堆状态
    jhat - 堆分析器工具


### JVM  的 GC 机制 及 JVM 调优

* http://www.cnblogs.com/Mandylover/p/5208055.html
    sun JVM 的内存管理采用分代策略:
    1、Young Gen(年轻代)
    2、Tenured Gen(年老代)
    3、Perm Gen(持久代)

* jstat -gc 4347 250 4  # 4347 pid
    
    S0C、S1C、S0U、S1U：Survivor 0/1区容量（Capacity）和使用量（Used）
    EC、EU：Eden区容量和使用量
    OC、OU：年老代容量和使用量
    PC、PU：永久代容量和使用量
    YGC、YGT：年轻代GC次数和GC耗时
    FGC、FGCT：Full GC次数和Full GC耗时
    GCT：GC总耗时
