#tomcat

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
