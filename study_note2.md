十一周三次课（12月27日）
11.32 php扩展模块装安
扩展
apache rewrite教程 http://coffeelet.blog.163.com/blog/static/13515745320115842755199/ 

   http://www.cnblogs.com/top5/archive/2009/08/12/1544098.html 

   apache rewrite 出现死循环 http://ask.apelearn.com/question/1043 

   php错误日志级别参考  http://ask.apelearn.com/question/6973 

   php开启短标签 http://ask.apelearn.com/question/120 

   php.ini详解  http://legolas.blog.51cto.com/2682485/493917 
------------------------------------------------------
#PHP 扩展模块安装

* /usr/local/php/bin/php -m //查看模块
* 测试安装一个redis的模块
> cd /usr/local/src/
> wget https://codeload.github.com/phpredis/phpredis/zip/develop 
> mv develop phpredis-develop.zip
> unzip phpredis-develop.zip
> cd phpredis-develop
> /usr/local/php/bin/phpize //生成configure文件
> ./configure --with-php-config=/usr/local/php/bin/php-config
> make && make install
> /usr/local/php/bin/php -i |grep extension_dir //查看扩展模块存放目录，我们可以在php.ini中去自定义该路径 
> vim /usr/local/php/etc/php.ini  //增加一行配置（可以放到文件最后一行）
   extension = redis.so  #php.ini中增加扩展模块加入的声明，从而加载模块
*如果php源码中有需要扩展的模块，就直接到相应目录做同样的操作即可（就不用重新下载源码了）*

=========================================
十一周二次课（12月26日）
11.28 限定某个目录禁止解析php
11.29 限制user_agent
11.30/11.31 php相关配置
扩展
apache开启压缩  http://ask.apelearn.com/question/5528 

apache2.2到2.4配置文件变更  http://ask.apelearn.com/question/7292 

apache options参数  http://ask.apelearn.com/question/1051 
--------------------------------------------------------
#限定某个目录禁止解析PHP

*  核心配置文件内容

```BASH
    <Directory /data/www/test01/upload>
        php_admin_flag engine off
    </Directory>
```
*  curl测试时直接返回了php源代码，并未解析

* 禁止PHP解析任何文件

```BASH
<Directory "/data/www/test01/upload">
    php_admin_flag engine off
    <FilesMatch ".*\.php$"> 
        order deny,allow
        deny from all
    </FilesMatch>
</Directory>

```

# 控制访问 限制user_agent

* user_agent可以理解为浏览器标识
 核心配置文件内容

```BASH 
  <IfModule mod_rewrite.c>
        RewriteEngine on
        RewriteCond %{HTTP_USER_AGENT}  .*curl.* [NC,OR]   #OR "或" 无此标签则表示"且"
        RewriteCond %{HTTP_USER_AGENT}  .*baidu.com.* [NC]
        RewriteRule  .*  -  [F]   #403 forbiden "-"不进行跳转，直接403
    </IfModule>
```

* curl -A "123123" -x127.0.0.1:80 www.test01.com/index.html #指定user_agent

# PHP 相关配置

*  查看php配置文件位置
>/usr/local/php/bin/php -i|grep -i "loaded configuration file" #如果系统上装了多个PHP可能得到的内容不是实际的配置文件位置
>可以使用phpinfo()函数进行查看

```BASH
index.php:
<?php
phpinfo();
?>
然后浏览器访问该文件，查看"configuration file位置查看相关目录文件位置"
```

* 其他重要参数
```BASH 
php.ini:
date.timezone 
 disable_functions #禁用函数参数
eval,assert,popen,passthru,escapeshellarg,escapeshellcmd,passthru,exec,system,chroot,scandir,chgrp,chown,escapeshellcmd,escapeshellarg,shell_exec,proc_get_status,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,leak,popepassthru,stream_socket_server,popen,proc_open,proc_close,phpinfo 
 error_log, log_errors, display_errors, error_reporting
 open_basedir

httpd-vhosts.conf:
 php_admin_value open_basedir "/data/www/test01:/tmp/"
```
* error_log=/tmp/php_errors.log #log位置
* logs_error=on #错误日志开启
* display_error=off #错误不显示在网页端（访问返回错误）
* error_reporting=E_ALL #开启所有日志 生成环境一般使用E_ALL & -E E_NOTICE

* open_basedir #设置访问目录，设定了以后，其他外的目录就没有权限访问，在php.ini中设置是对所有服务器上网站设定
> 如果需要各个虚拟网站都有不同的访问目录则需要在/usr/local/apache2.4/conf/extra/httpd_vhosts.conf 文件中进行设置
>php_admin_value open_basedir "/data/www/test01:/tmp/" 

=====================================================
十一周一次课（12月25日）
11.25 配置防盗链
11.26 访问控制Directory
11.27 访问控制FilesMatch
扩展
几种限制ip的方法 http://ask.apelearn.com/question/6519 

apache 自定义header http://ask.apelearn.com/question/830 
------------------------------------------------------

#apache 配置防盗链

*防止其他网站引用图片资源等*

* 通过限制referer来实现防盗链的功能
* vim /usr/local/apache2.4/conf/extra/httpd_vhosts.conf

```bash
  <Directory /data/www/test01>
        SetEnvIfNoCase Referer "http://www.test01.com" local_ref
        SetEnvIfNoCase Referer "http://test01.com" local_ref
        SetEnvIfNoCase Referer "^$" local_ref
        <filesmatch "\.(txt|doc|mp3|zip|rar|jpg|gif)">
            Order Allow,Deny
            Allow from env=local_ref
        </filesmatch>
    </Directory>
```

* curl -e "http://test02.com" -x192.168.31.20:80 www.test01.com  #自定义referer

# apache Directory 访问控制 	

* vim /usr/local/apache2.4/conf/extra/httpd_vhosts.conf

```bash

  <Directory /data/www/test01/admin/>
        Order deny,allow
        Deny from all
        Allow from 127.0.0.1
    </Directory>

```
* Order deny,allow #顺序为先执行deny语句，然后执行allow语句，先禁止所有访问，然后把本机访问权限开放
* curl测试状态码为403则被限制访问了

# apache FileMatch 访问控制

* vim /usr/local/apache2.4/conf/extra/httpd_vhosts.conf

```bash

<Directory /data/www/test01>
    <FilesMatch  "admin.php(.*)">
        Order deny,allow
        Deny from all
        Allow from 127.0.0.1
    </FilesMatch>
</Directory>

```

* FileMatch 限制文件

=====================================================
十周四次课（12月21日）
11.22 访问日志不记录静态文件 
11.23 访问日志切割
11.24 静态元素过期时间
扩展 
apache日志记录代理IP以及真实客户端IP http://ask.apelearn.com/question/960
apache只记录指定URI的日志 http://ask.apelearn.com/question/981
apache日志记录客户端请求的域名 http://ask.apelearn.com/question/1037
apache 日志切割问题 http://ask.apelearn.com/question/566
--------------------------------------------------

# 静态元素过期时间

* 浏览器访问网站的图片时会把静态的文件缓存在本地电脑里，这样下次再访问时就不用去远程下载了（只要文件没改变的话），
  相关虚拟机增加配置:/usr/local/apache2.4/conf/extra/httpd_vhosts.conf

```bash
<IfModule mod_expires.c>
    ExpiresActive on  //打开该功能的开关
    ExpiresByType image/gif  "access plus 1 days"
    ExpiresByType image/jpeg "access plus 24 hours"
    ExpiresByType image/png "access plus 24 hours"
    ExpiresByType text/css "now plus 2 hour"
    ExpiresByType application/x-javascript "now plus 2 hours"
    ExpiresByType application/javascript "now plus 2 hours"
    ExpiresByType application/x-shockwave-flash "now plus 2 hours"
    ExpiresDefault "now plus 0 min"
</IfModule>
```

* httpd.conf中 需要开启expires_module模块功能
* curl测试，看cache-control: max-age #过期时间
* windows crtl+F5 强制刷新网页

# 访问日志切割

* 日志一直记录总有一天会把整个磁盘占满，所以有必要让它自动切割，并删除老的日志文件 
  把虚拟主机配置文件(/usr/local/apache2.4/conf/extra/httpd_vhosts.conf)改成如下：

```bash 
 <VirtualHost *:80>
    DocumentRoot "/data/www/www.test01.com"
    ServerName www.123.com
    ServerAlias 123.com
    SetEnvIf Request_URI ".*\.gif$" img
    SetEnvIf Request_URI ".*\.jpg$" img
    SetEnvIf Request_URI ".*\.png$" img
    SetEnvIf Request_URI ".*\.bmp$" img
    SetEnvIf Request_URI ".*\.swf$" img
    SetEnvIf Request_URI ".*\.js$" img
    SetEnvIf Request_URI ".*\.css$" img 
    CustomLog "|/usr/local/apache2.4/bin/rotatelogs -l logs/test01.com-access_%Y%m%d.log 86400" combined env=!img
</VirtualHost>
```

* 重新加载配置文件 -t, graceful
* ls /usr/local/apache2.4/logs 

# 访问日志不记录静态文件

* 把虚拟主机配置文件改成如下： 
 <VirtualHost *:80>
    DocumentRoot "/data/wwwroot/www.test01.com"
    ServerName www.123.com
    ServerAlias 123.com
    SetEnvIf Request_URI ".*\.gif$" img
    SetEnvIf Request_URI ".*\.jpg$" img
    SetEnvIf Request_URI ".*\.png$" img
    SetEnvIf Request_URI ".*\.bmp$" img
    SetEnvIf Request_URI ".*\.swf$" img
    SetEnvIf Request_URI ".*\.js$" img
    SetEnvIf Request_URI ".*\.css$" img 
    CustomLog "logs/test01.com-access_log" combined env=!img
</VirtualHost>
* 重新加载配置文件 -t, graceful
* mkdir /data/www/test01/images //创建目录，并在这目录下上传一个图片
* curl -x127.0.0.1:80 -I test.com/images/test01.jpg 
* tail /usr/local/apache2.4/logs/test01.com-access_log 
   网站大多元素为静态文件，如图片、css、js等，这些元素可以不用记录 

===========================================
20171221
十周三次课（12月20日）
11.18 Apache用户认证
11.19/11.20 域名跳转
11.21 Apache访问日志
扩展 
apache虚拟主机开启php的短标签   http://ask.apelearn.com/question/5370 
-----------------------------------------------------------------------
#apache 用户认证

* 访问文件夹认证
* 访问单个文件认证


##访问文件夹认证

* vim /usr/local/apache2.4/conf/extra/httpd-vhosts.conf

```BASH
#在<VirtualHost *:80> </VirtualHost> 一个虚拟主机内定义该下内容
<Directory /data/www/test01>  #指定认证目录
    AllowOverride AuthConfig  #打开认证开关
    AuthName "test01.com-test" #自定义认证的名字，作用不大
    AuthType Basic #认证的了性，一般为basic
    AuthUserFile /usr/local/apache2.4/conf/htpasswd #指定密码文件名字和所在位置
    #AuthGroupFile /usr/local/apacha2.4/conf/htgroup  #指定用户组
    require valid-user #指定需要认证的用户为全部用户
    #require user user1 #单独指定用户user1 认证可以访问
</Directory>

```

* /usr/local/apache2.4/bin/htpasswd -c -m /usr/local/apache2.4/conf/htpasswd user1
* /usr/local/apache2.4/bin/htpasswd  -m /usr/local/apache2.4/conf/htpasswd user2 #"-c" 创建文件第一个用户使用 "-m" md5加密
* /usr/local/apache2.4/bin/apachectl -t/graceful #重新加载配置
* 绑定hosts 访问 对应虚拟主机，打开浏览器测试
* curl -x127.0.0.1:80 test01.com #状态码返回为401
* curl -x127.0.0.1:80 -uuser1:passwd test01.com #状态码返回200

##访问单个文件进行认证

* 针对单个文件进行认证

```BASH
#同样是在<VirtualHost *:80> </VirtualHost>虚拟主机内定义
<FileMatch admin.php>
    AllowOverride AuthConfig  #打开认证开关
    AuthName "test01.com-test"
    AuthType Basic
    AuthUserFile /usr/local/apache2.4/conf/htpasswd
    require valid-user
#内容是何对文件夹限制是一样的
</FileMatch>
```

# apache域名跳转

*访问一个网站的域名->跳转到另外个网站 访问内容*

* vim /usr/local/apache2.4/conf/extra/httpd-vhosts.conf

```BASH
<VirtualHost *:80>
DocumentRoot "/data/www/test01"
ServerName www.test01.com
ServerAlias test01.com
<ifModule mod_rewrite.c> #需要mod_rewrite 模块支持
    RewriteEngine on #打开rewrite功能
    RewriteCond %{HTTP_HOST} ^!www.test01.com$ #定义rewrite的条件
    RewriteRule ^/(.*)$ http://www.test01.com/$1 [R=301,L] #定义跳转规则，当满足上一个条件时就按该条规则进行条状
    #301 为永久条状 302 为临时跳转
</ifModule>

</VirtualHost>

```

* /usr/local/apache2.4/bin/apachectl -M | grep -i rewrite #若无加载该模块 编辑httpd.conf 配置文件内容“#LoadModule rewrite_module modules/mod_rewrite.so” 去掉注释

* curl -x127.0.0.1:80 -l test01.com #返回状态吗为403

# apache访问日志

* 日志文件 /usr/local/apache2.4/logs/*.access_log
* httpd-vhosts.conf 文件中 "CustomLog "logs/test01.dummy-host.example.com-access_log" common"  定义文件位置
* httpd.conf 文件中 定义文件格式

```BASH
<IfModule log_config_module>
    #
    # The following directives define some format nicknames for use with
    # a CustomLog directive (see below).
    #
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

<IfModule logio_module>

```
* httpd-vhosts.conf 中定义日志文件名和位置，后面可以选择格式化方式 原来是"common" 可以 改成 "combined"
* %{Referer}i 显示前一次访问的网站记录（跳转点） %{User-Agent}i 代理（浏览器种类等）

* 其他参数意义：

```BASH
  %a: 远程IP地址  
     %A: 本地IP地址  
     %B: 已发送的字节数，不包含HTTP头  
     %b: CLF格式的已发送字节数量，不包含HTTP头。例如当没有发送数据时，写入‘-’而不是0。  
      %{FOOBAR}e: 环境变量FOOBAR的内容  
      %f: 文件名字  
      %h: 远程主机  
      %H 请求的协议  
      %Foobar}i: Foobar的内容，发送给服务器的请求的标头行。  
      %l: 远程登录名字（来自identd，如提供的话）  
      %m: 请求的方法  
      %{Foobar}n: 来自另外一个模块的注解“Foobar”的内容  
      %{Foobar}o: Foobar的内容，应答的标头行  
      %p: 服务器响应请求时使用的端口  
      %P: 响应请求的子进程ID。  
      %q: 查询字符串（如果存在查询字符串，则包含“?”后面的部分；否则，它是一个空字符串。）  
      %r: 请求的第一行  
      %s: 状态。对于进行内部重定向的请求，这是指*原来*请求的状态。如果用%...>s，则是指后来的请求。  
      %t: 以公共日志时间格式表示的时间（或称为标准英文格式）  
     %{format}t: 以指定格式format表示的时间  
      %T: 为响应请求而耗费的时间，以秒计  
      %u: 远程用户（来自auth；如果返回状态（%s）是401则可能是伪造的）  
      %U: 用户所请求的URL路径  
      %v: 响应请求的服务器的ServerName  
      %V: 依照UseCanonicalName设置得到的服务器名字  
```

===========================================================
20171220
十周第二次课（12月19日）
11.14/11.15 Apache和PHP结合
11.16/11.17 Apache默认虚拟主机
--------------------------------------
# 配置httpd<-> php

* 配置httpd支持php
* 配置httpd支持php并且 配置虚拟主机

## 配置httpd支持php

* httpd 祝配置文件 /usr/local/apache2.4/conf/httpd.conf
* vim /usr/local/apache2.4/conf/httpd.conf #修改4个地方

```BASH
ServerName
Require all granted #denied-granted  #定义访问
AddType application/x-httpd-php .php
Directoryindex index.html index.php
```

* /usr/local/apache2.4/bin/apachectl -t #测试语法
* /usr/loca/apache2.4/bin/apachectl start #启动服务
* netstat -lntp 
* curl localhost 或者 windows访问主机
* vim /usr/local/apache2.4/htodcs/test.php #测试php加载成功后读取的文件

```BASH
<?php
echo test-php
?>
```

* curl localhost/test.php

##httpd配置虚拟主机

* 一台服务器中可以有多个网站提供被客户访问，每个网站对应一个虚拟主机
* 虚拟主机配置文件：/usr/local/apache2.4/conf/extra/httpd-vhosts.conf
* vim /usr/local/apache2.4/conf/extra/httpd-vhosts.conf

```BASH
<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host.example.com #邮箱可以去除
    DocumentRoot "/data/www/test01/" #定义访问目录
    ServerName www.test01.com  #定义域名
    ServerAlias test01.com test01-test.com #定义域名别名，可以定义多个别名
    ErrorLog "logs/test01.dummy-host.example.com-error_log" #日志文件
    CustomLog "logs/test01.dummy-host.example.com-access_log" common
</VirtualHost>

<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host2.example.com
    DocumentRoot "/data/www/test02/"
    ServerName www.test02.com
    ServerAlias test02.com test02-test.com
    ErrorLog "logs/test02.dummy-host2.example.com-error_log"
    CustomLog "logs/test02.dummy-host2.example.com-access_log" common
</VirtualHost>
```
* mkdir /data/www/test01
* mkdir /data/www/test02

test01/index.php

```bash
 <?php
echo "teststart-test01.com";
?>

```

test02/index.php

```bash
 <?php
echo "teststart-test02.com";
?>

```

* /usr/local/apache2.4/bin/apachectl -t #检查语法
* /usr/local/apache2.4/bin/apachectl graceful #重新加载配置文件

* curl -x192.168.31.20 www.test01.com #访问的是 test01的虚拟主机
* curl -x192.168.31.20 www.test02.com #访问的是 test02的虚拟主机
* curl -x192.168.31.20 #访问的是 test01的虚拟主机
* curl -x192.168.31.20 www.test03.com #域名test03 不存在虚拟主机中，未定义，故会去访问默认的虚拟主机即第一个定义的"test01"

* 在windows访问：需要设置hosts文件C:\Windows\System32\drivers\etc\hosts
```BASH
192.168.31.20   test01.com #增加这行
```
windows就会被指向 test01.com 网站的内容,其他同理

访问httpd 虚拟服务其过程
*  如果客户端访问出现 403 forbidden 错误，可以查看文件 /usr/local/apache2.4/conf/httpd.conf 文件中



```BASH

<Directory />
AllowOverride none
Require all denied    

</Directory>

```

* 禁止访问根目录 所以有两个解决办法去改变这个权限，

> 1：在这个文件此处直接改成granted

>2、在httpd-vhosts.conf 文件 相应的虚拟机定义中取定义目录权限，这样比上面定义要安全，比如:



```BASH

#此处是在<VirtualHost *:80> </VirtualHost>　中定义

<Directory "/data/www/test01">
#Options Indexes FollowSymLinks  #此处是当访问一个服务器的时候不写路径，并且文件夹中没有index类型文件的时候，会返回此服务器的目录结构
Options FollowSymLinks      #这个选项就不会返回目录结构 ，也会提示 403 forbidden
AllowOverride None           #  设置"None" 时，会忽略".htaccess"文件，设置为"All"的时候 访问服务器会去  .htaccess 中执行命令，算是命令重定向了
Order deny,allow
Allow from all
Require all granted
</Directory>

```

客户端（windows）

test01.com -> hosts 找到IP ->访问 ip的httpd服务器 ->然后根据被访问的域名(test01.com)，指向该虚拟主机的服务器，并返回结果

=====================================================
20171219

mysql php 连接器的意义

MYSQL:This extension is deprecated as of PHP 5.5.0, and has been removed as of PHP 7.0.0. 
MYSQLI: MySQL Improved Extension 
MySQLND: MySQL Native Drive 
PDO:The PHP Data Objects。extension defines a lightweight, consistent interface for accessing databases in PHP。

官方文档:http://php.net/manual/en/book.mysqli.php
参考博客:http://blog.csdn.net/u013785951/article/details/60876816

=======================================================
20171218
十周第一次课（12月18日）
11.10/11.11/11.12 安装PHP5
11.13 安装PHP7
php中mysql,mysqli,mysqlnd,pdo到底是什么   http://blog.csdn.net/u013785951/article/details/60876816 

查看编译参数  http://ask.apelearn.com/question/1295 
--------------------------------------------------------
#php
*当前主流版本5.6/7.1*

##php5安装

* cd /usr/src/local
* wget http://cn2.php.net/distributions/php-5.6.30.tar.gz
* tar -zxvf php-5.6.30.tar.gz
* cd php-5.6.30
* ./configure --prefix=/usr/local/php5 --with-apxs2=/usr/local/apache2.4/bin/apxs \
--with-config-file-path=/usr/local/php5/etc \
--with-mysql=/usr/local/mysql --with-pdo-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir \
--with-iconv-dir --with-zlib-dir --with-bz2 --with-openssl --with-mcrypt \
--enable-soap --enable-gd-native-ttf --enable-mbstring --enable-sockets --enable-exif

* 以下每解决一个错误都重新编译，然后产生第二个错误，一个一个解决

> "configure: error: libxml2 version 2.6.11 or greater required.",前面装apr-util装过一次而且是比这个要新的，不知道为什么会识别不到
> yum remove libxml2-devel;yum -y install libxml2-devel #重新安装
> "configure: error: Cannot find OpenSSL's <evp.h>" yum -y install openssl-devel "通过yum list | grep openssl 查找"

> "checking for zlib version >= 1.2.0.4... configure: error: libz version greater or equal to 1.2.0.4 required" 可以看到版本不够，然后查找发现版本比他新，没办法卸了重装试一下，果然解决了,不知道什么原因
> "configure: error: xml2-config not found. Please check your libxml2 installation." 这个我刚装过的呀，居然重装成功了估计是刚卸载了zlib引起的。
> "configure: error: Cannot find OpenSSL's <evp.h>" yum -y install openssl-devel #同上
> "configure: error: Please reinstall the BZip2 distribution" #终于除了个新的错误 老方法 yum list | grep bzip2，装devel包
> "configure: error: jpeglib.h not found" yum provides jpeglib.h 看下这个文件依赖哪个包，居然没有结果 yum list | grep jpeglib
	在试一试，还是没有 yum list | grep jpeg 搜索到了 凭直觉选一个安装 yum -y install openjpeg-devel 错了，google一下
	查到 "jpeglib.h"在libjpeg中 所以 yum -y install libjpeg-turbo-devel.x86_64 安装
> "configure: error: png.h not found." yum -y install libpng-devel
> "configure: error: freetype-config not found." yum provides freetype-config; yum -y install freetype-devel
> "configure: error: mcrypt.h not found. Please reinstall libmcrypt." 
> "configure: WARNING: unrecognized options: --with-pnp-dir" 查一下是写错了 应该是 --with-png-dir，只是个警告，不过还是重新链接一下


*注：一般devel后缀包都是供开发用，包含 "头文件" "链接库" 和一些开发文档以及演示代码*


* make && make test 
* make install


* cp php.ini-production /usr/local/php5/etc/php.ini

```BASH
Linux下查看Nginx、Napache、MySQL、PHP的编译参数的命令如下：

1、nginx编译参数：
#/usr/local/nginx/sbin/nginx -V
2、apache编译参数：
# cat /usr/local/apache/build/config.nice
3、php编译参数：
# /usr/local/php/bin/php -i |grep configure
4、mysql编译参数：
# cat /usr/local/mysql/bin/mysqlbug|grep configure
```

## php7 安装

参数中把php5改成php7，其他参数一样 “configure: WARNING: unrecognized options: --with-mysql, --with-mcrypt, --enable-gd-native-ttf”
取消这几个参数然后链接。然后执行./configure .... 没有报错，前面php5应该把需要链接的库文件都装好了，所以装的很顺畅。

================================================================================
20171218
九周第五次课（12月15日）
11.6 MariaDB安装
11.7/11.8/11.9 Apache安装
扩展
apache dso https://yq.aliyun.com/articles/6298 

apache apxs http://man.chinaunix.net/newsoft/ApacheMenual_CN_2.2new/programs/apxs.html 

apache工作模式 http://www.cnblogs.com/fnng/archive/2012/11/20/2779977.html 
-------------------------------------------------------------------
#apache 
apache 既是 httpd

##apache安装

* wget http://mirrors.cnnic.cn/apache/httpd/httpd-2.4.26.tar.gz #没有？
* wget http://archive.apache.org/dist/httpd/httpd-2.4.26.tar.gz

* wget http://mirrors.hust.edu.cn/apache/apr/apr-1.5.2.tar.gz
* wget http://mirrors.hust.edu.cn/apache/apr/apr-util-1.5.4.tar.gz

>apr 和 apr-util 是一个通用的函数库，他让httpd可以不关心底层的操作系统平台，可以方便移植(从linux到windows)

* tar -zxvf httpd-2.4.26.tar.gz
* tar -zxvf apr-util-1.5.4.tar.gz
* tar -zxvf apr-1.5.2.tar.gz   #系统已经安装了就不用安装了，

* cd /usr/src/local/apr-1.5.2
* ./configure --prefix=/usr/local/apr
* make && make install

* cd /usr/src/local/apr-util-1.5.4
* ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
* make && make install
* 出错因为没有expat.h 头文件： yum search expat；搜索到yum -y install expat-devel.x86_64 #安装后然后重新make编译安装 

* 出错“pcre-config for libpcre not found”：yum search pcre;搜索到 yum -y install pcre-devel.x86_64
* cd /usr/src/local/httpd-2.4.26

* ./configure \ 
--prefix=/usr/local/apache2.4\
--with-apr=/usr/local/apr\
--with-apr-util=/usr/local/apr-util\
--enable-so\
--enable-mods-share=most

* make && make install
> 出现 undefined reference to 'XML_GETErrorCode'等等 
>原因是编译apr-util的时候缺少了xml相关的库， yum -y install libxml2-devel
> 删除apr-util安装的目录和makefile（make distclean），重新进行安装，然后重新执行安装apache

* ls /usr/localapache2.4/modules
* /usr/local/apache2.4/bin/httpd -M  #查看加载的模块
> 带share字样的，表示该模块为动态共享模块，static表示静态模块
> 区别在于静态模块与/usr/local/apache2.4/bin/httpd 绑定在一起，我们看不到，而动态模块都是一个个独立的存在的文件modules目录下面的.so文件都是
* /usr/local/apache2.4/bin/apachectl start #启动服务






==========================================================
20171214
第九周第四次课（12月14日）
11.1 LAMP架构介绍
11.2 MySQL、MariaDB介绍
11.3/11.4/11.5 MySQL安装
扩展
mysql5.5源码编译安装 

http://www.aminglinux.com/bbs/thread-1059-1-1.html 

mysql5.7二进制包安装（变化较大） 

http://www.apelearn.com/bbs/thread-10105-1-1.html 
------------------------------------------------
#LAMP架构：

Linux + Apache(http) + MySQL + PHP
安装此架构需要按照一定的顺序安装
Linux -  MySQL > Apache > PHP

**三个软件也可以在一台机器上，也可以分开，但是httpd和PHP 需要在在一起**

##MySQL 和 Mariadb

*MySQL 是一个关系型数据库 2009年sun公司被oracle公司收购*

* Mariadb 为mysql的一个分支，[Mariadb](https://mariadb.com/) 最新版本呢10.2
*MariaDB 主要有SkySQL公司，由Mysql 大部分原班人马 创立*
*Mariadb5.5 对应Mysql5.5, 10.0对应MySQL5.6*

* Community 社区版本，Enterprise 企业版， GA(Generally Available)指  通用版本
在生产环境中用的，DMR(Development Milestone Release)开发里程碑发布,
RC(Release Candidate) 发行候选版本，Bate开放测试版本，Alpha 内部测试版本。

###安装mysql

* mysql 的几个常用安装包： rpm、源码、二进制免编译

* cd /usr/local/src
* wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
* tar -zxvf mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
* mv mysql-5.6.35-linux-glibc2.5-x86_64 /usr/local/mysql #原目录移动改名字mysql，转移前可以ls /usr/locl/ 看是否有mysql目录
* cd /usr/local/mysql
* usradd -M -s /sbin/nologin mysql
* passwd mysql
* mkdir /data/mysql
* chown -R mysql /data/mysql
* ./script/mysql_install_db --user=mysql --datadir=/data/mysql
>加--defaults-file=/usr/local/mysql/my.cnf 需要把/etc/my.cnf删除，看了mysql.server脚本没找到原因
>修改mysql.server 的conf=/usr/local/mysql/my.cnf 都不能解决问题，有/etc/my.cnf的时候貌似程序并没有执行到这，后面可以使用mysqld_safe --defaults-file 再次指定my.cnf才可以正常运行

>不实用该参数可以把 my.cnf复制到/etc/my.cnf
yum list | grep perl|grep -i dumper #模糊搜索
>yum -y install perl-Data-Dumper.x86_64，然后重新执行上面脚本

*搜索引擎 百度 google www.bing.com*

* cp support-files/mysql.server /etc/init.d/mysqld
* cp support-files/my-default.cnf /etc/my.cnf

* vi /etc/init.d/mysqld
  定义basedir=/usr/local/mysql #程序放的地方
  和 datadir=/data/mysql  #数据放的地方

* /etc/init.d/mysqld start

```BASH
root      7665     1  0 22:45 pts/2    00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/data/mysql --pid-file=/data/mysq/xujb01.pid
mysql     7761  7665 33 22:45 pts/2    00:00:15 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/data/mysql --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=/data/mysql/xujb01.err --pid-file=/data/mysql/xujb01.pid

```


>或者使用另外中方式启动:
>/usr/local/mysql/bin/mysqld_safe --defaults-file=/usr/local/mysql/my.cnf --user=mysql --datadir=/data/mysql

*注：killall mysqld 杀掉服务的时候如果一下没有结束，说明mysqld服务还有没结束的数据在传输，不能使用'-9'强制杀死，可能会导致数据异常*

###Mariadb 安装：

* cd /usr/src/local/
* wget http://downloads.mariadb.com/MariaDB/mariadb-10.2.6/bintar-linux-glibc_214-x86_64/mariadb-10.2.6-linux-glibc_214-x86_64.tar.gz

* tar -zxvf mariadb-10.2.6-linux-glibc_214-x86_64.tar.gz
* mv mariadb-10.2.6-linux-glibc_214-x86_64 /usr/local/mariadb
* cd /usr/local/mariadb
* mkdir /data/mariadb
* chown mysql /data/mariadb
* ./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mariadb --datadir=/data/mariadb
* cp support-files/mysql.server /etc/init.d/mariadb
* cp support-files/my-small.cnf /usr/local/mariadb/my.cnf
* vim /usr/local/mariadb/my.cnf #定义basedir 和 datadir
* vim /etc/init.d/mariadb #定义basedir datadir conf 以及启动参数
>conf=$basedir/my.cnf,然后在后面启动命令mysqld_safe --defaults-file=$conf
>datadir=/data/mariadb
>basedir=/usr/local/mariadb

* /etc/init.d/mariadb start

###mysql 源码安装
*查看官方文档：https://dev.mysql.com/doc/refman/5.7/en/source-installation.html*
* wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.20.tar.gz
* yum -y install cmake
* rpm -qa | grep gcc* #已经安装就不用安装了
* 下载boost_1_59_0
* 解压运行 ./bootstrap.sh
* ./b2 toolset=gcc
* ./b2 install --prefix=/usr/local/boost_1_59_0
* ldconfig #?
* useradd -r -g mysql -s /sbin/nologin mysql
* tar zxvf mysql-VERSION.tar.gz
* cd mysql-VERSION
* mkdir bld
* cd bld
* cp /usr/src/local/boost_1_59_0.tar.gz /usr/local/boost_1_59_0/
* yum -y install ncurses-devel
>centos7.0默认已经安装了ncurses-libs-5.9-14.20130511.el7_4.x86_64，而上面命令会默认安装ncurses-5.9-13版本的，
* wget http://mirror.centos.org/centos/7/updates/x86_64/Packages/ncurses-devel-5.9-14.20130511.el7_4.x86_64.rpm
>下载相应版本
* rpm -ivh ncurses-devel-5.9-14.20130511.el7_4.x86_64.rpm #安装
* rm /usr/src/local/mysql-5.7.20/CMakeCache.txt
* cmake .. -DWITH_BOOST=/usr/local/boost_1_59_0
* echo $? ==>0 #安装成功
* make && make install

=============================================
20171212
----------------
系统日志
-----------------
#日志

* 配置文件:/etc/logrotate.conf
* 其他相关文件:/etc/logrotate.d /var/log/

```BASH
/var/log/wtmp: 查看用户登入历史:last命令查看
/var/log/btmp：查看无效登入历史:lastb命令查看

```

* /etc/logratate.d/syslog 
>重新加载syslogd: /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true

相关命令：
* last
* dmesg #系统启动相关日志
```BASH
dmesg:
/var/log/dmesg：
```


==================================================================
20171211
后台保持运行sceen setid nohub (&)

--------------------------------------------------------------------------
#后台运行

意义:
当终端需要退出时，一般运行的脚本以及后台命令，会跟着终端注销而结束，有有几种保持后天的方法。
```用户注销终端会收到 hangup 信号，然后会关闭在其上运行的子进程， 
解决方法有两种:
1、 让执行得进程忽略HUP型号，
2、 让运行的进程不再属于需要退出的终端
```

注: （c+Z）ctrl+Z可以暂停任务然后 使用 bg %1 把该进程丢到后天运行，fg %1 把后台放在前台执行

## nohub

忽略HUP信号来防止进程被中断

1、 nohub ping www.baidu.com > ping.txt  2>&1 & # 标准输出 标准错误 都会重定向到ping.txt文件中，并放入后台执行
> nohup ping www.baidu.com & #默认标准输出和标准错误重定向到nohup.out文件中

##setsid

setsid 使进程不属于 正在运行的终端
正常后台运行:
```BASH
[test@xujb01 ~]$ sleep 1000&
[1] 19848
[test@xujb01 ~]$ ps -ef | grep sleep
test     19848  2275  1 07:37 pts/4    00:00:00 sleep 1000
test     19850  2275  0 07:37 pts/4    00:00:00 grep --color=auto sleep
[test@xujb01 ~]$ ps
  PID TTY          TIME CMD
   2275 pts/4    00:00:05 bash
   19848 pts/4    00:00:00 sleep
   19851 pts/4    00:00:00 ps
#可以看到sleep 进程属于 运行终端的子进程 19848 2275
更直观的观看:
[test@xujb01 ~]$ pstree

  ├─sshd───sshd───bash─┬─pstree
  │                    └─sleep

```

1、 setsid 
使用setsid后:
setsid sleep 1000&

```BASH

[test@xujb01 ~]$ ps -ef | grep sleep
test     19864     1  0 07:42 ?        00:00:00 sleep 10000
test     19868  2275  0 07:43 pts/4    00:00:00 grep --color=auto sleep
--------------
 [test@xujb01 ~]$ pstree

 ├─sleep
 ├─sshd───sshd───bash───vi
 ├─sshd───sshd───bash───pstree

#运行的进程属于了pid 1
```

## (command &)

(sleep 1000 &) #同样的此方法也是把该进程丢到后台并成为pid 1的子进程

```BASH
[test@xujb01 ~]$ (sleep 1000 &)
[test@xujb01 ~]$ ps -ef | grep sleep
test     19880     1  0 07:48 pts/4    00:00:00 sleep 1000
test     19882  2275  0 07:48 pts/4    00:00:00 grep --color=auto sleep
```

##disown
disown作业调度:当命令已经运行怎么把他变成不会随着终端注销而结束,使用disown
* disown -h %1 #使进程忽略HUP信号 （%1）和bg fg 方法一样，
* disown -ah #使所有作业忽略HUP信号
* disown -rh #使正在运行的作业忽略HUP信号
>和nohup一样当终端结束后把进程丢到 pid 1中

##scree
可以使用在大量的命令在后台稳定执行






=================================================================================
八周二次课（7月18日）
10.28 rsync工具介绍
10.29/10.30 rsync常用选项
10.31 rsync通过ssh同步
---------------------------------------------------------
#rsync
`使用快速增量备份工具Remote sync可以远程同步，支持本地复制，或者与其他SSH、rsync主机同步。`

##rsync命令备份

* `-v` #详细模式输出
* `-q` #精简模式输出
* `--partial` #保留那些因故没有完全传输的文件，以是加快随后的再次传输
* `--progress` #显示传输进度
* `-P` #相当于 `--pratial`和`--progress` 
* `-l` #保留软连接，
* `-L` #传输备份链接的源文件 可能需要权限，权限不够不影响其他文件传输
* `-z` #`--compress` 对备份的文件在传输时进行压缩处理。增加传输速度
* `-a` #归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD
* `p`  #--perms 保持文件权限
* `-o` #--owner 保持文件属主信息。
* `-g` #--group 保持文件属组信息。
* `-D` #--devices 保持设备文件信息。
* `-t` #--times 保持文件时间信息。
* `-r` #--recursive 对子目录以递归模式处理。

* `--delete` #删除DST中SRC没有的文件 
* `--config=FILE` #指定其他的配置文件，不使用默认的rsyncd.conf文件。
* `--bwlimit=KBPS` #限制I/O带宽 KBytes per second 
* `--exclude 'file'` #排除某个文件 该参数可以使用多个以便排除多个文件
* `--exclude-from ‘file.txt’` #file.txt文件中可写多个需要排除的文件
* `-e` #指定使用rsh、ssh方式进行数据同步 ` -e 'ssh -p 60000' `

##rsync后台服务同步： 
rsync --daemon #启动守护进程 #并且注意iptables规则是否把端口或者相应数据阻止了
配置文件: /etc/rsync.conf，更改文件不需要重启服务。

编辑文件:
```BASH
port=8730
logfile=/var/log/rsync.log
pid file=/var/run/rsync.pid

[xujb]
path=/tmp/rsync
use chroot=yes
#限制在此目录下，如果同步源文件中有软链接 同步的时候加了L选项，是不能同步链接的源文件的
max connections=4
read only=no
list=yes
#是否可以把模块名字“xujb”显示出来
uid=root
gid=root
#同步的时候所属组
auth users=test
secrets file=/etc/rsync.passwd
#用户认证
hosts allow=192.168.31.21
#允许主机
#
[test]
path=/tmp/rsync123
use chroot=yes
#限制在此目录下，如果同步源文件中有软链接 同步的时候加了L选项，是不能同步链接的源文件的
read only=no
list=yes
##是否可以把模块名字“xujb”显示出来
uid=root  
#采取读取文件的权限，不包括读取密码文件，只是对操作文件
gid=root
##同步的时候所属组
#auth user=test
#secrets file=/etc/rsync.passwd
#不加用户认证
hosts allow=192.168.31.21
##允许主机
```

* touch /etc/rsync.passwd #给400权限,*注others位绝对比可以给权限，给了权限认证就会通不过*
```BASH
test:123123

```
* mkdir /tmp/rysnc #创建活动文件夹

* 在另外台主机输入:rsync -avzP --port 8730 passwd/ test@192.168.31.20::xujb/
>调用xujb模块，用xujb模块指定的用户test登入，并到指定的位置去取密码，"::"默认使用端口是"873"，
> `--config "FILE" ` #指定其他的配置文件，不使用默认的rsyncd.conf文件，服务器端使用参数。
> `--password-file "FILE"  从FILE中得到密码。客户端使用参数


* ssh传输方式 rsync 服务器: rsync -avzP  -e ssh  passwd/ test@192.168.31.20::xujb/
* ssh 传输方式 rsync 方式: rsync -avzP  -e ssh  passwd/ test@192.168.31.20:/tmp/
`ssh可以设置密钥认证不需要密码传输 "::"为rsync服务器指示 `
`注： 当用户登入设置了.bashrc文件"ehco "了任何内容，会导致传输失败，认证会出错`
```BASH
protocol version mismatch -- is your shell clean?
(see the rsync man page for an explanation)
rsync error: protocol incompatibility (code 2) at compat.c(174) [sender=3.0.9]

```




==============================================================================
20171130


七周三次课（7月12日）
10.11 Linux网络相关
10.12 firewalld和netfilter
10.13 netfilter5表5链介绍
10.14 iptables语法

扩展（selinux了解即可）
1. selinux教程  http://os.51cto.com/art/201209/355490.htm
2.selinux pdf电子书  http://pan.baidu.com/s/1jGGdExK
------------------------------------------------------------
#网络

##linux网络相关

* ifconfig #查看网卡（yum -y install net-tools）
* ifdown ens33 && ifup ens33 #重启网卡
* ifconfig ens33:1 ip #临时设定虚拟网卡
* cp /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-ens33\:1
>编辑ifcfg-ens33:1文件 修改IP和NAME DEVICE ens33:1

* mii-tool ens33 或者 ethtool ens33 # 查看网卡是否连接
* hostnamectl set-hostname test #对应文件 /etc/hostname
* /etc/resolv.conf #DNS配置文件
* /etc/hosts #指定名称对应IP，算是本地域名解析

##linux防火墙
* getenforce #获得selinux 状态
* setenforce #临时设置selinux 状态 0:Permissive 警告  1:Enforcing 开启selinux
* 编辑/etc/selinux/config #修改SELINUX=enforcing这项 有 enforcing permissive disabled:关闭selinux 这几项

###linux 防火墙-netfilter

**iptables是netfilter的一个工具**

* centos7 之前使用netfiter 防火墙*
* centos7开始使用 firewalld 防火墙*

在centos7上使用netfilter步骤：
1、关闭firewalld
	systemctl stop firewalld #临时关闭frewalld
	sysctemctl disable firewalld #开机启动关闭firewalld
2、开启netfilter
	yum -y install iptables-services
	systemctl enable iptables #开机启动开启iptables
	systemctl start iptables #临时开启iptables
	iptables -nvL #查看iptables规则
>不停止firewalld安装netfilter来管理iptables，用命令systemctl start iptables会提示
>"Failed to start iptables.service: Unit not found."
>安装的时候如果提示多版本错误，则把原先安装的卸载yum remove iptables-services,然后执行install命令进行安装
>service iptables save #找不到service
>yum provides “service” #搜索到包"initscripts-9.49.39-1.el7.x86_64"，安装他后就可以正常使用

##netfilter 5表5链介绍

**netfilter 5表**

* filter  # INPUT OUTPUT FORWARD 链 控制进入机器网络数据包 
* nat
* mangle
* raw
* security

###filter

控制数据的进入INPUT，数据输出OUTPUT, 数据转发FORWARD

* 进入本地机器的数据 INPUT,OUTPUT 链
* 转发到别的机器的数据 FORWARD, OUTPUT 链


###nat
网络数据包地址转换
作用：
1、端口映射
2、地址转换
3、伪装IP

* PREROUTING  #数据进入机器时经过的链
* POSTROUTING #数据出去时经过的链

可以使用的动作有：
REDIRECT: 将数据包重定向到另一台主机的某个端口，通常用实现透明代理和对外开放内网某些服务。
SNAT: 源地址转换，改变数据包的源地址
DNAT: 目的地址转换，改变数据包的目的地址
MASQUERADE: IP伪装，只适用于ADSL等动态拨号上网的IP伪装，如果主机IP是静态分配的，就用snat

###iptbales语法

常用命令：
* iptables -nvL #查看iptables规则
* iptables -nvL --line-number
> iptables规则优先匹配前面的规则
* iptables -F #清空规则
* service iptables save
* iptables -t nat #指定表 #不加"-t" 参数默认是filter表
* iptables -Z #把计数器清零
> pkts bytes target     prot opt in     out     source               destination
  5713   15M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
  #既是pkts 和bytes

* iptables -I/-A/-D INPUT -s 1.1.1.1 -j DROP    #-I 插入 -A 增加 -D 丢弃 
* iptables -P INPUT DROP  #设置默认规则 "policy DROP"
> Chain INPUT (policy ACCEPT  0 packets, 0 bytes)

* iptables -I INPUT -m iprange --src-range 192.168.31.2-192.168.31.100 -j DROP #ip段范围控制
* iptables -I INPUT -s 192.168.31.0/24 -j DROP          #ip段范围控制
======================================================================
20171129
七周二次课（11月29日）
10.6 监控io性能
10.7 free命令
10.8 ps命令
10.9 查看网络状态
10.10 linux下抓包
扩展tcp三次握手四次挥手 http://www.doc88.com/p-9913773324388.html
tshark几个用法：http://www.aminglinux.com/bbs/thread-995-1-1.html
------------------------------------------------------------------
#监控系统状态

##iostat
* iostat -x #磁盘使用

```BASH
[root@xujb01 yum.repos.d]# iostat -x
Linux 3.10.0-693.5.2.el7.x86_64 (xujb01) 	2017年11月29日 	_x86_64_	(1 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.12    0.00    0.20    0.06    0.00   99.62

	   Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
	   sda               0.00     0.08    0.17    0.08     4.12     2.14    49.15     0.01   24.27   13.50   46.25   5.38   0.14
	   sdb               0.00     0.00    0.00    0.00     0.02     0.00    45.16     0.00    4.37    4.37    0.00   4.08   0.00
	   scd0              0.00     0.00    0.00    0.00     0.01     0.00   114.22     0.00   14.56   14.56    0.00  13.89   0.00

------------------------
util: 等待时间比，数字很大，读写就会很忙

```

##iotop
* iotop #磁盘使用
> yum -y install iotop

```BASH

ot@xujb01 yum.repos.d]# iotop

Total DISK READ :	0.00 B/s | Total DISK WRITE :       0.00 B/s
Actual DISK READ:	0.00 B/s | Actual DISK WRITE:       0.00 B/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
   3368 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.43 % [kworker/0:2]
   1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % systemd --switched-root --system --deserialize 21
--------------------
SWAPIN:交换分区到内存
```

##free
* free
> free -m/-h/-g
```BASH
[test@xujb01 ~]$ free -h
              total        used        free      shared  buff/cache   availabl 
Mem:           988M        106M        334M        6.8M        547M        694M
Swap:          2.0G          0B        2.0G
----------------------------------------------
数据到（磁盘）->cpu ： 数据（磁盘）->内存（cache）-> cpu  #读
cpu写到 ->磁盘： cpu-> 内存（buffer） -> 磁盘 #写

availabl: free + cache/buffer剩余部分（没有被用到的）
total = used + free + cache/buffer

```

##ps
* ps aux
```BASH
[test@xujb01 ~]$ ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.6 128164  6832 ?        Ss   11月28   0:27 /usr/lib/systemd/systemd --switched-root --system --deserialize 21
root         2  0.0  0.0      0     0 ?        S    11月28   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S    11月28   0:02 [ksoftirqd/0]
--------------------------
VSZ:虚拟内存
RSS:物理内存
STAT:进程状态  
	1、D :不能中断的进程
	2、R :run状态的进程，
	3、S:sleep状态的进程
	4、T:暂停的进程，(运行一个程序然后ctrl+z暂停任务可以看到暂停进程）
	5、Z:僵尸进程
a、 < :高优先级进程
b、 N ：低优先级进程
c、 L ： 内存中被锁的内存分页
d、 s ：主进程
e、 l : 多线程进程
d、 + :前台进程
```

##查看网路状态
* netstat #查看网络状态，tcp udp
* netstat -nlp #查看监听端口
* netstat -an #查看系统的网络连接状况
* netstat -lntup #只看tcp，udp 不包含socket(unix)
* netstat -an | awk '/^tcp/ {++sta[$NF]} END {for(key in sta) print key,"\t", sta[key]}'

```BASH
[test@xujb01 ~]$ netstat -anutp
(No info could be read for "-p": geteuid()=1000 but you should be root.)
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      -
tcp        0      0 192.168.31.20:22        192.168.31.95:61114     ESTABLISHED -
tcp        0     52 192.168.31.20:22        192.168.31.95:58980     ESTABLISHED -
tcp        0      0 192.168.31.20:22        192.168.31.95:61118     ESTABLISHED -
tcp6       0      0 :::22                   :::*                    LISTEN      -
tcp6       0      0 ::1:25                  :::*                    LISTEN      -
--------------
State： 三次握手四次挥手状态信息

```
* ss命令和netstat有类似功能

##tcpdump 抓包工具
yum -y install tcpdump
* 用法 tcpdump -nn -i ens33

```BASH
[root@xujb01 test]# tcpdump -nn -i ens33
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens33, link-type EN10MB (Ethernet), capture size 262144 bytes
07:37:38.758762 IP 192.168.31.20.22 > 192.168.31.95.58980: Flags [P.], seq 2728510939:2728511151, ack 2312649719, win 316, length 212
07:37:38.775795 IP 192.168.31.20.22 > 192.168.31.95.58980: Flags [P.], seq 212:408, ack 1, win 316, length 196
07:37:38.776513 IP 192.168.31.95.58980 > 192.168.31.20.22: Flags [.], ack 408, win 16400, length 0
-----------------
’-nn‘ #显示ip 显示端口
```

* tcpdump -nn port 80
* tcpdump -nn not port 22 and host 192.168.0.100
* tcpdump -nn -c 100 -w 1.pcap #保存到1.pcap文件内，可以拿到wireshark中分析
* tcpdump -r 1.pcap #查看数据包
* tcpdump -nn -S  0  #抓取完整包 默认是抓取长度为68字节

##tshark 抓包工具
yum -y install wireshare

* tshark -n -t a -R http.request -T fields -e "frame.time" -e "http.request.uri"




===================================
20171128
七周一次课（11月27日）
10.1 使用w查看系统负载
10.2 vmstat命令
10.3 top命令
10.4 sar命令
10.5 nload命令
------------------------------------
#监控系统状态

* w/uptime # 查看系统负载
* cat /proc/cpuinfo 查看cpu核数
* vmstat #监控系统状态

```BASH
vmstat 1 #1秒监控1次
关键的几列：r,b,swapd,si,so,bi,bo,us,wa
```

* top #查看进程使用情况

##使用w查看系统负载

```bash
[root@xujb01 yum.repos.d]# w
 07:15:19 up  1:44,  3 users,  load average: 0.00, 0.01, 0.05
 USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
 test     pts/0    192.168.31.95    05:32    7.00s  1.25s  1.12s vim study_note2.md
 test     pts/1    192.168.31.95    05:32   40:31   0.09s  0.09s -bash
 test     pts/2    192.168.31.95    05:32    7.00s  1.04s  0.28s sshd: test [priv]
 -------------------------------------------------------------------
 TTY:终端 pts/0 远程
 load average：系统负载，依次 1min 10min 15min监控的负载情况：使用cpu活动进程
 逻辑CPU: cat /proc/cpuinfo -> processor 0 表示1个逻辑cpu
 负载数小于cpu个数是较好的
```

##vmstat命令
vmstat 1 或者 vmstat 1 10 #1s显示一次显示10次

```BASH

[root@xujb01 yum.repos.d]# vmstat 1 5
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  0      0 406324  25796 468724    0    0    53    24   77   63  1  1 97  1  0
 0  0      0 406192  25796 468724    0    0     0     0   49   45  0  0 100  0  0
 0  0      0 406192  25796 468724    0    0     0     0  103  162  0  0 100  0  0
 0  0      0 406192  25796 468724    0    0     0     0   43   36  0  0 100  0  0
 0  0      0 406192  25796 468724    0    0     0     0   49   43  1  1 98  0  0
------------------------------------------------
r: run状态 在运行的进程
b: block状态 等待的进程
swpd: 内存不够的时候 swpd会变动，内存在频繁的写和释放
si: 有多少kb数据从swap进入到内存
so: 有多少kb数据从内存到swap
bi：磁盘到内存 读
bo：内存写到磁盘 写
us + sy + id=100 #百分比表示
wa:多少个进程在等待cpu
```

##top命令

1、top -c #显示详细的进程信息
2、top -bn1 #静态显示所有进程
3、q 退出，数字1显示所有cpu，进行cpu切换监控
4、大写M按内存排序
5、大写P按cpu使用情况排序

```BASH

ot@xujb01 yum.repos.d]# top -n1
top - 07:39:26 up  2:08,  3 users,  load average: 0.00, 0.02, 0.05
Tasks:  83 total,   1 running,  82 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  6.7 sy,  0.0 ni, 93.3 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  1012376 total,   405100 free,   112120 used,   495156 buff/cache
KiB Swap:  2097148 total,  2097148 free,        0 used.   720900 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
   1124 test      20   0  147844   2412   1104 S  6.7  0.2   0:07.75 sshd
      1 root      20   0  128164   6832   4072 S  0.0  0.7   0:08.55 systemd
----------------------------------
zombie:僵尸进程

```

##sar命令
1、安装sar

> yum -y install sysstat

2、常用选项

* sar -n DEV 1 5 #监控网卡流量
```BASH
[root@xujb01 yum.repos.d]# sar -n DEV 1 5
Linux 3.10.0-693.5.2.el7.x86_64 (xujb01) 	2017年11月28日 	_x86_64_	(1 CPU)

06时40分03秒     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
06时40分04秒        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
06时40分04秒     ens33      1.01      1.01      0.06      0.18      0.00      0.00      0.00

06时40分04秒     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
06时40分05秒        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
06时40分05秒     ens33      1.01      1.01      0.06      0.40      0.00      0.00      0.00
--------------------------------------------------------------------------------------------
rxpck/s:数据接收包，到达1W时需要注意是否有攻击需要抓包分析
rxkB/s：数据接收量

```

* sar -q #系统负载
```BASH
[root@xujb01 yum.repos.d]# sar -q
Linux 3.10.0-693.5.2.el7.x86_64 (xujb01) 	2017年11月28日 	_x86_64_	(1 CPU)

06时20分01秒   runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15   blocked
06时30分01秒         1       116      0.04      0.04      0.05         0
06时40分01秒         1       116      0.02      0.02      0.05         0
平均时间:         1       116      0.03      0.03      0.05         0
--------------------------------------------------------------------
#1S 5S 15S 负载量

```

*sar -b #磁盘读写
```BASH
[root@xujb01 yum.repos.d]# sar -b 1 5
Linux 3.10.0-693.5.2.el7.x86_64 (xujb01) 	2017年11月28日 	_x86_64_	(1 CPU)

06时47分19秒       tps      rtps      wtps   bread/s   bwrtn/s
06时47分20秒      0.00      0.00      0.00      0.00      0.00
06时47分21秒      0.00      0.00      0.00      0.00      0.00
06时47分22秒      0.00      0.00      0.00      0.00      0.00
06时47分23秒      0.00      0.00      0.00      0.00      0.00
06时47分24秒      0.00      0.00      0.00      0.00      0.00
平均时间:      0.00      0.00      0.00      0.00      0.00
-------------------------------------------------------------
bread/s：读
bwrtn/s：写

```

#sar -f /var/log/sa/saxx #查看历史信息
> /var/log/sa/saxx /var/log/sa/sarxx 
> sarxx是数据文件，可以直接cat，并且需要第二天才生成；而saxx为二进制文件，需要用命令-f选项来查看
> 命令举例：sar -n DEV -f /var/log/sa/sa27 或者 sar -q -f /var/log/sa/sa27

##nload命令 查看网卡流量
1、安装

> yum -y install epel-release;yum -y install nload

安装过程遇到的问题：
```BASH
[root@xujb01 yum.repos.d]# yum -y install nload
已加载插件：fastestmirror, priorities
Loading mirror speeds from cached hostfile
1099 packages excluded due to repository priority protections
没有可用软件包 nload。
错误：无须任何处理
-------------------------------------
[root@xujb01 yum.repos.d]# yum -y install epel-release
已加载插件：fastestmirror, priorities
Loading mirror speeds from cached hostfile
1099 packages excluded due to repository priority protections
匹配 epel-release-7-9.noarch 的软件包已经安装。正在检查更新。
无须任何处理
----------------------------------------------------------------
然后mv epel.repo.bak epel.repo；yum list | grep nload #前面更改了源引起的，之后安装软件正常
```

* 使用：方向键切换网卡


================================================================
20171123
六周第四次课（11月23日）
复习 
扩展
1、 打印某行到某行之间的内容http://ask.apelearn.com/question/559
> sed -n  '/abcf/,/rty/'p test.txt #匹配有abcf到有rty的行

2、sed转换大小写 http://ask.apelearn.com/question/7758

sed在某一行最后添加一个数字http://ask.apelearn.com/question/288
删除某行到最后一行 http://ask.apelearn.com/question/213
打印1到100行含某个字符串的行 http://ask.apelearn.com/question/1048
------------------------------------------------------------------------------------





==================================================================
20171123

六周第三次课（11月22日）
9.6/9.7 awk
扩展
把这里面的所有练习题做一下
http://www.apelearn.com/study_v2/chapter14.html
----------------------------------------------------------------
#awk用法
*awk 是以文件的一行为处理单元，一行一行的往下执行所定义的命令*

**awk -F ":" ‘｛print $1｝’** 
>“print $1”是打印第一行的意思，所以一行一行的执行该命令，就把所有的第一行打印出来

**常用参数**：

* `-F ":"`  #指定":"为分隔符，从而每行分$1 $2...,第一个字段，第二个字段等，默认分隔符为**空格**
* `{OSF="#"}` # 指定打印分隔符为"#"，

* `/test/` #匹配字符段用"//"标注里面内容为匹配内容，这个匹配是一行所有内容匹配
* `$2 ~ /test/` #此匹配为字段2进行匹配

* `NR` #行的序列号 相当于"cat -n test.txt"打印序列号
* `NF` #相应行的字段
* `$0 $1 $2...` #"$0"表示所有字段，"$1"第一字段，以此类推
* `BEGIN` #一般每个语句每行都会执行，但是用了BEGIN指定后就只是在开始执行，用法比如定义变量可以放在此处
* `END`  #一般每个语句每行都会执行，但是用了END指定后就只是在结束时执行，用法用于总结比如计算总数并打印

**定义约定**

* `{}` #大括号一般是输出内容“print语句一定要用大括号括起来”，并且一个大括号相当于下面的分号括号里面的内容是一组内容
* `;` #分号，分号为一组语法的结束，同一组语法是一起按顺序执行的，每组有每组语句的处理方式（结果）
	'{限定语句1 “空格” 执行操作1};{限定语句2 “空格” 执行操作2}'
* `空格` #语句的分隔符

##例子

* ";"和"{}" 分组语句

```BASH
[test@xujb01 awk]$ awk -F ":" '{if(NR==1) print "$1: " $1} {if(NR==1) print "$2: " $2}' test.txt
$1: root
$2: x
#"{}"分组；执行完语句1，然后执行语句2以输出两行
[test@xujb01 awk]$ awk -F ":" '{if(NR==1) print "$1: " $1 ;if(NR==1 print "$2: " $2}' test.txt
$1: root
$2: x
#";"分组，"{}"把他们分成1组但是里面有";"，所以组1里有 a，b两组语句
[test@xujb01 awk]$ awk -F ":" '{if(NR==1) print "$1: " $1,  "  $2: " $2}' test.txt
$1: root   $2: x
#这是一组语句所以打印在一行里面 "print"内分隔服可以用","也可以省略

```

**BEGIN END**

```BASH
[test@xujb01 awk]$ awk -F ":" 'BEGIN{tot=0;print "hello world"} {tot=$3+tot} END{print tot }' test.txt
hello world
11700
#第三个字段累加,并初始化tot=0，其实默认变量不定义直接使用都是0
[test@xujb01 awk]$ awk -F ":" 'BEGIN{print "hello world"} {tot=$3+tot} END{print tot }' test.txt
hello world
11700
#没有定义变量tot=0结果是一样的
[test@xujb01 awk]$ awk -F ":" 'BEGIN{print "hello world"} tot=$3+tot; END{print tot }' test.txt
hello world
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
...省略
#可以看到"tot=$3+tot"没有让大括号括起来，所以结尾要用分号和其他语句分开
#其实‘too=$3+tot’语句是和‘too=$3+tot{print $0}’ 是一样的
[test@xujb01 awk]$ awk -F ":" 'BEGIN{print "hello world"} tot=$3+tot{print $0}; END{print tot }' test.txt
hello world
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
...省略
#只有条件语句没有输出语句默认会输出'{print $0}'把该行所有的打印出来，（用括号括气来的为输出语句，没有叫条件语句）
[test@xujb01 awk]$ awk -F ":" 'NR==1' test.txt
root:x:0:0:root:/root:/bin/bash
#同理相当于 "awk -F ":" 'NR==1'{print $0} test.txt" 
[test@xujb01 awk]$ awk -F ":" '{NR==1}' test.txt
[test@xujb01 awk]$
#而此例子，输出语句里没有打印所以就不打印内容
```

**/test/和 $1 ~ /test/**

```bash
t@xujb01 awk]$ awk -F ":" '/test/' test2.txt
test:test:1
aaa:test:1

t@xujb01 awk]$ awk -F ":" '$1 ~ /test/' test2.txt
test:test:1
[test@xujb01 awk]$
# '$1 ~ /test/' 只对第一字段进行匹配
```

**和sed一样替换字符**
```BASH
[test@xujb01 awk]$ awk -F ":" '$1="root"' test2.txt
root test 1
root test 1
#第一字段替换成root
#还可以加上一些其他的限制
[test@xujb01 awk]$ awk -F ":" 'NR==1,$1="root"' test2.txt
root test 1
#第一行进行替换
[test@xujb01 awk]$ awk -F ":" 'NR==1,$1="root"{};{print $0}' test2.txt
root test 1
aaa:test:1
#语法1对语法2进行了影响，并且这个这是影响打印，并不会改变test2.txt的内容
```


===============================================================
20171122

六周第二次课（11月22日）
9.4/9.5 sed
----------------------------------------------
##sed 工具
> `-n` `p`  #打印匹配的第几行，其他的不打印
> `-r`  #启用扩展正则表达式，使用该参数可以不用`\`去转意
> `-e`  #多次匹配，1个内容可能匹配两次，如果两次匹配的内容相同的话
> `sed -n '/root/'Ip test.txt`  #忽略大小写
> `sed '1,10d' test.txt`  #删除内容
> `sed -i '1,10s/root/test/' test.txt` #把改变的内容写入文件，默认是不改变的，只是把改的打印出来，却不改变文件内容
> `sed '1,10s/root/test/g' test.txt` #替换
> `sed -nr 's/(test01:).*(test01:).*/xx:& yy:&\/'p test.txt` # '&'用法是匹配前面'()'内容，而'&'则表示匹配的内容到结束

**`-n``p`**:

```bash
[test@xujb01 exmple]$ sed -n '/root/'p 01
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```

**`-e`**:

```bash
[test@xujb01 exmple]$ sed -n -e '/root/'p -e '/test01/'p  01
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
test01:x:1001:1001::/home/test01:/sbin/nologin
```

**`Ip`**：

```BASH
[test@xujb01 exmple]$ sed -n '/bus/'Ip 01
ssssBUS
dbus:x:81:81:System message bus:/:/sbin/nologin
```
**&**:
```BASH
[test@xujb01 exmple]$ sed -rn 's/(test01:).*(test01:).*/\1---\2/'p 01
test01:---test01:
```
1、 '&'只是表示第一个匹配以及后面的内容，
2、 '&'是表示匹配到的内容+后面的内容
3、 '\1' '\2'表示第一个括号的内容和第二个括号的内容

```BASH
[test@xujb01 exmple]$ sed -rn 's/(test01:).*(test01:).*/XX:\1-&---\2-&/'p 01
XX:test01:-test01:x:1001:1001::/home/test01:/sbin/nologin---test01:-test01:x:1001:1001::/home/test01:/sbin/nologin
```

4、 所以根据第三条可以匹配‘&’的效果，而且可以指定位置添加内容：

```BASH
[test@xujb01 exmple]$ sed -rn 's/(test01:)(.*)(test01:)(.*)/xx:\1\2---yy:\3\4/'gp 01
xx:test01:x:1001:1001::/home/---yy:test01:/sbin/nologin
或者
[test@xujb01 exmple]$ sed -rn 's/(test01:.*)(test01:.*)/xx:\1---yy:\2/'gp 01
xx:test01:x:1001:1001::/home/---yy:test01:/sbin/nologin


```





=================================================================
20171121
六周第一次课（7月3日）
9.1 正则介绍_grep上
9.2 grep中
9.3 grep下
扩展
把一个目录下，过滤所有*.php文档中含有eval的行
grep -r --include="*.php" 'eval' /data/
------------------------------------------------------
#正则
##正则表达式的组成
* 一般字符
* 特殊字符（meta字符）：元字符，有在正则表达式中有特殊意义
	1、BRE:基本正则表达式
	2、ERE:扩展正则表达式

###通配符
* `*` #匹配0个或任意多个字符，匹配任意字符相当于基础正则里的“.*”
* `？` #匹配任意**一个**字符
* `[]` #匹配“[]”中任意一个字符
* `[-]` #匹配括号中任意一个字符，“-”代表范围”[A-Z]“ ”[a-z]“
* `[^]` #逻辑非，表示匹配不是中括号内的一个字符，[^0-9]，匹配非数字

###BRE 基础正则表达式
* `*` #前一个字符匹配0此或任意多次
* `.` #匹配除了换行符意外的任意一个字符，一次， `".*"`匹配所有内容
* `^` #匹配字符串头部
* `$` #匹配字符串尾部
* `\[\]` #匹配中括号中字符一次，`[A]` 匹配字符“A”一次`[A,B]`匹配字符"A"或者'B'一次
* `\[^x\]` #匹配字符“x”以外的字符
* `\` #转意字符如上面的中括号，在grep中可以加`-E`参数或者使用egrep就不用转意字符
* `a\{n\}` #匹配字符`a`n次
* `a\{2,\}` #匹配字符“a”出现不小于2次
* `a\{2,5\}` #匹配字符“a”出现次数为2-5次

###扩展正则表达式
* `|`  #管道符，表示“或”，“abc|hell” 匹配“abc”或者"hell"
* `()` #小括号，可以讲正则字符和元字符或表达式进行组合"(abc)|(hell)s"
	匹配"abcs"或者"hells"
* `?` #问号，匹配0个或者1个前表达式（或字符，字符串），“(ab)?”匹配“ab”
* `\<` #反斜杠+小于号，词首定位符， “\< abc”表示所有包含以”abc”开头的单词的行
* `\>` #反斜杠+大于号，词尾定位符， “\>abc”表示所有包含以”abc”结尾的单词的行
* `-`  #减号，用于指明字符范围， “[a-c]”将匹配包含a、b和c中任意一个字符的字符串
* `+` # 加号，匹配一个或多个前导表达式，相当于 expr{1,}, 与"?"不同的是至少匹配一次“?”可以匹配0次


##工具：
* grep 
* egrep #grep 的扩展
* sed
* awk

##grep 
option:
grep [-cinvABC] 'word' filename

* `-c` #统计匹配到的总行数
* `-i` #不区分大小写
* `-n` #显示行号
* `-r` #递归 目的可以写文件夹，递归里面所有的文件
* `-v` #取反过滤
* `-An` #列出匹配到的行以及下n行
* `-Bn` #列出匹配到的行以及上n行
* `-Cn` #列出匹配到的行以及上下n行

* grep -rn 'root' .  #递归匹配本目录下的 有‘root’字符的行，并打印行号，

```BASH
[test@xujb01 exmple]$ grep -rn root .
./a.txt:1:#123 root example
./a.txt:2:test 123 root
./test/2:1:#123 root example
./test/2:2:test 123 root
./b:1:#123 root example
./b:2:test 123 root
./1a:1:#123 root example
./1a:2:test 123 root
./1:1:#123 root example
./1:2:test 123 root
./3:1:#123 root example
./3:2:test 123 root

```

* grep -rn --include="[0-9]" .  #`--include` 对文件进行匹配过滤

```BASH
[test@xujb01 exmple]$ grep -rn --include="[0-9]" 'root' .
./test/2:1:#123 root example
./test/2:2:test 123 root
./1:1:#123 root example
./1:2:test 123 root
./3:1:#123 root example
./3:2:test 123 root

```

* grep -r 'o\{2\}' .
* grep -r -E 'o{2}' .   #-E就是启用扩展egrep
* egrep -r '0{2}' .     #此三个匹配内容是一样的


===========================================================
20171120
记录：
source、exec、fork
*这3者讨论三个地方；1、是否创建子shell 2、子级的环境变量是否影响父级 3、程序是否会随着子shell结束而结束*

**source**
test01.sh->
source ./test.sh
> 1、不创建子shell 在子shell中加入"echo $$"查看进程pid
> 2、子级的环境变量会影响父级
> 3、程序不会随着子shell结束而结束

**exec**
test01.sh->
exec ./test.sh
> 1、不创建子shell 在子shell中加入"echo $$"查看进程pid
> 2、子级的环境变量不会影响父级 #应为随着子shell结束整个脚本都结束了就没有变量返回只说了
> 3、程序是随着子shell结束而结束


**fork**
test01.sh->
./test.sh
> 1、创建子shell 在子shell中加入"echo $$"查看进程pid
> 2、子级的环境变量不会影响父级
> 3、程序不会随着子shell结束而结束，父shell结束而结束

---------------------------------------------------------------
20171120

五周第五次课（6月30日）
8.10 shell特殊符号cut命令
8.11 sort_wc_uniq命令
8.12 tee_tr_split命令
8.13 shell特殊符号下
相关测验题目：http://ask.apelearn.com/question/5437
扩展
1. source exec 区别 http://alsww.blog.51cto.com/2001924/1113112
2. Linux特殊符号大全http://ask.apelearn.com/question/7720
3. sort并未按ASCII排序 http://blog.csdn.net/zenghui08/article/details/7938975
-----------------------------------------------------------------------------
##管道符应用
**cut**
* 1、cut -d ":" -f 1,3([1-3])  #1,3表示用“：”分隔的第1和第3段字符串，[1-3]，是1到3段字符串（1，2，3）
* 2、cut -c 3 #显示第三个字符也有 1，3和1-3的运用

**sort**
* 3、sort /etc/passwd #按照ASCII码顺序排序
* 4、sort -n /etc/passwd #按照以数字排序，字母都是相当于0排在其他数字的前面
* 5 、sort -r /etc/passwd #反向排序
* 6、 sort -k3 -t ":" /etc/passwd #以":"为分隔符 第三个字段排序

**wc**
* wc -l/-w/-m /etc/passwd #`-l` 统计行数 `-w` 统计单词数，以空格为分隔符，`-m`/`-c` 统计字符数

**uniq**
* sort test.txt | uniq -c              #去重 -c统计行数

**tee**
* cat test.txt | tee 1.txt  #正确输出重定向 和 `cat test.txt > 1.txt`类似不过会多了屏幕输出
* cat test.txt | tee -a 1.txt #追加 `>>`

**tr**
* echo "hello world" | tr "h" "H" #把`h`替换成`H`，也可以替换成其他字符
**split**
* split -b 100k test.txt # 切割文件100k1个文件 命名以`x`开头
* split -b 100k test.txt txt. #命名以txt.为前缀 不带单位`k`则默认是字节
* split -l 100 test.txt txt. #100行切割1个文件以txt为命名前缀

##特殊符号

* $ #变量前缀
* !$ #代表上一个命令的最后一位字符串
* `;` #多条命令分隔符
* `~` #用户家目录 cd ~
* ./test.sh & #把执行test.sh脚本丢到后天执行
* `>`重定向  `>>` 追加 `2>` 错误重定向 `2>>` 错误追加 `&>` 错误正确都重定向到,相当于`2>&1`, 

```BASH
cat test.txt &> 1 和 cat test.txt 2>&1 >1 结果都是把标准错误输出和标准输出重定向到文件1

```
* `[]` #指定字符中的一个[1-9]1到9中的一个 [1,9]1和9其中一个
>echo "abc" | tr [a-c] "X" -> XXX
> echo "abc"| tr [a,c] "X" -> XbX

* || #SHELL命令行中为或运算符，遇到真的就不往后执行，结束
* && #SHELL命令行中为与运算符，遇到真的就往后执行，直到遇到假的结束





================================
20171117
五周第四次课（11月16日）
8.6 管道符和作业控制
8.7/8.8 shell变量
8.9 环境变量配置文件
扩展
bashrc和bash_profile的区别   http://ask.apelearn.com/question/7719
--------------------------------------------------------
#管道符#
把前面内容给到后面
* cat test.txt | wc -l 
* find / -name .conf -exec ls {} \;



##作业控制 （后台前台）

* ctrl+ z #暂停当前任务，并把其放置后天
* bg [id]  #把后台暂停任务置于后台运行，此时如果有输出，会一直输出，直到程序结束或手动结束
* fg [id]  #把后台任务放置前台执行
* jobs #查看后台任务，包括暂停任务和后台运行任务
* kill %id #杀掉后台任务

##变量

* PATH HOME PWD LOGNAME #系统变量
* env  #查看系统变量
* set  #查看系统变量和用户自定义变量
* a=1  #用户自定义变量
* unset a #删除变量
* 变量的累加  #a="c" b="d";echo $a$b-> cd
* 全局变量 export a=1 #可以在其子进程中生效，但是不会在其父进程中生效,用法在同一个bash中运行2个脚本可以共同使用1个变量

```BASH
[test@xujb01 test]$ export test="hello world"
[test@xujb01 test]$ echo $test
hello world
[test@xujb01 test]$ bash
[test@xujb01 test]$ echo $test
hello world
[test@xujb01 test]$ bash
[test@xujb01 test]$ echo $test
hello world

pstree：
 ├─sshd─┬─sshd───sshd───bash───su───bash───vim
        │      ├─sshd───sshd───bash
        │      └─sshd───sshd───bash───bash───bash───pstree

```
**全局变量在父进程中无效**
```BASH
[test@xujb01 test]$ export son="hello"
[test@xujb01 test]$ exit
exit
[test@xujb01 test]$ echo $son

```
** pstree #查看进程树**

* 变量命名规则：
	>由字母数字下划线组合，首位不能是数字
	>变量值有特殊符号时，需要用单引号括起来，单引号把字符符号原样输出，不做处理，如果用双引号需要用转义符'\'原样输出
	 一些特殊符号
	 a=‘1$b’ 和 a="1$b"结果不一样，和a="a\$b"结果一样



##环境变量配置文件

* /etc/profile #(系统)用户环境变量 交互 登入才执行，加载
* /etc/bashrc #（系统）执行shell就生效，执行脚本等会执行此文件
* ~/.bashrc   #当前用户相关环境变量文件 (家目录)
* ~/.bash_profile  #自动调用->.bashrc ->/etc/bashrc，和其内容有关
* ~./.bash_history #当前用户命令历史记录文件
* ~./.bash_logout #用户退出执行的文件
* PS1 #一个变量影响命令前提示：" [test@xujb01 ~]$" 
```BASH
[test@xujb01 ~]$ echo $PS1
[\u@\h \W]\$

```	
* PS2 #续行提示符 
```BASH
[test@xujb01 ~]$ echo $PS2
>
	
[test@xujb01 ~]$ for i in  `seq 1 10`
>	
```

**.bashrc 和 .bash_profile区别**
* .bash_profile 根据里面内容决定了会执行.bashrc,所以.bashrc执行的其也会执行
* .bashrc只影响远程用户(ssh)和不会影响到在本地主机上登入的用户，而.bash_profile两者都会影响
```bash
在.bashrc 添加 echo "hello bob"
在.bash_profile中添加 echo "it's test prifile"
在xshell中以远程登入用户时有提示，hello bob，而在本地（虚拟机上）登入有"hello bob" 和 "it's test prifile"提示，
但是无论在xshell登入后还是本地登入后执行bash，重新调用一个shell，都只有"hello bob"提示
```








==================================================================

20171116
五周第三次课（11月15日）
8.1 shell介绍
8.2 命令历史
8.3 命令补全和别名
8.4 通配符
8.5 输入输出重定向
----------------------------------------------------------------
#shell 基础

* shell是一个命令解释器，提供用户和机器之间的交互
* 支持特定的语法，比如逻辑判断、循环
* 每个用户都可以有自己的shell
* centos7默认shell为bash（Bourne Agin Shell）
* 还有zsh ksh等

* 查看当前shell
	>echo $SHELL 
	>echo $0 #不是所有shell都支持，centos7 sh不支持
	> env | grep SHELL
	>cat /etc/passwd | grep username
	>ps  #查看当前shell
	>echo $$	
	>ps -ef | grep `echo $$`| grep -v ps | grep -v grep

* cat /etc/shells #查看当前可以使用的shell 
	>FTP用户我们会不让他有登入shell的权限所以把shell设置成/sbin/nologin,此时生效还需要把、/sbin/nologin加入到/etc/shells
	 中（或者是/usr/sbin/shell）

##命令历史

* history命令 上下方向键控制history
* 命令历史存在家目录.bash_history中
* echo $HISTSIZE #查看hostory存最多多少条命令
* history -c #清除当前内存命令历史，但是.bash_history文件不会删除
* 每次要当用户退出当前shell命令历史才会被写入到.bash_history文件中
* 设置HISTSIZE配置文件在/etc/profile中，修改后source /etc/profile或者重新登录shell中
* 格式化history输出 `HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S "`当前生效加入到/etc/profile中永久生效
* 禁止删除.bash_history文件 `chattr +a .bash_history	#只可以追加内容
* !! #上一条命令
* !n #运行history中第n条命令
* !mkdir #运行最近mkdir命令

##命令补全及别名
* TAB键 1下或2下补全，有多个相同补全内容需要敲击2下
* centos7中可以自动补全参数 需要安装`bash-completion安装后需要重启系统
* 命令别名设置 `alias tt='touch test'`
	>在shell中之间输入alias进行别名设置退出shell后不会保存，需要自定义别名永久保存需要在家目录.bashrc文件中设置，
	修改后执行`source .bashrc` 重新加载配置文件
	>还有写配置文件可能在/etc/bashrc中或者在/etc/profile.d/中
	>`unlias tt`进行取消命令别名

##通配符
* ls *.txt #`*`任意多个字符
* ls ?.txt #`?`1个字符

* touch {1,2,5}
```BASH
[test@xujb01 test]$ touch {1,2,5}
[test@xujb01 test]$ ll
总用量 0
-rw-r--r--. 1 test sudo_test_group 0 11月 16 06:37 1
-rw-r--r--. 1 test sudo_test_group 0 11月 16 06:37 2
-rw-r--r--. 1 test sudo_test_group 0 11月 16 06:37 5
```

* ls [0-3].txt #匹配0-3中的一个.txt文件 不能touch

##输入输出重定向

* cat 1.txt > 2.txt #把1.txt内容重定向到2.txt 覆盖
* cat 1.txt >> 2.txt #把1.txt内容追加到2.txt中 
* cat 1.txt 2> 2.txt #默认cat 1.txt > 2。txt是把标准输出重定向到2.txt，如果命令错误是不会重定向到2.txt的，此命令就是
	把标准错误输出重定向到2.txt，例如如果1.txt不存在则把返回的错误信息重定向到2.txt，标准输出则不会写入
	```BASH
	[test@xujb01 test]$ cat 1.txt 2> 2.txt
	[test@xujb01 test]$ cat 2.txt
	cat: 1.txt: 没有那个文件或目录
        ```
* cat 1.txt > 2.txt 2>&1 #标准输出和标准错误输出都重定向到2.txt中
* cat > 2.txt < 1.txt #把文件1.txt内容重定向到2.txt中 `标准输入`

**linux shell下常用输入输出操作符是：**

1.  标准输入   (stdin) ：代码为 0 ，使用 < 或 << ； /dev/stdin -> /proc/self/fd/0   0代表：/dev/stdin 
2.  标准输出   (stdout)：代码为 1 ，使用 > 或 >> ； /dev/stdout -> /proc/self/fd/1  1代表：/dev/stdout
3.  标准错误输出(stderr)：代码为 2 ，使用 2> 或 2>> ； /dev/stderr -> /proc/self/fd/2 2代表：/dev/stderr

*注：`<<EOF`表示标准输入以`EOF`进行输入结束
```BASH
[test@xujb01 test]$ cat > test <<EOF
> hello world
> nihao
> EOF
[test@xujb01 test]$ cat test
hello world
nihao

```

=========================================================================
#20171115
五周第二次课（6月27日）
7.6 yum更换国内源
7.7 yum下载rpm包
7.8/7.9 源码包安装
扩展
1. 配置yum源优先级  http://ask.apelearn.com/question/7168
2. 把源码包打包成rpm包   http://www.linuxidc.com/Linux/2012-09/70096.htm
-------------------------------------------------------------------------
#yum仓库源更新和源码包安装

##更换yum仓库源

* 重命名原仓库源

```bash
ls /etc/yum.repos.d/ > /tmp/txt
cd /etc/yum.repos.d/
while read line;do mv $line "$line".bak;sleep 1;done</tmp/txt
```

* 下载163仓库源

```bash
* wget http://mirrors.163.com/.help/CentOS7-Base-163.repo #wget 未安装
* mv dvd.repo.bak dvd.repo
* yum -y install wget
* wget http://mirrors.163.com/.help/CentOS7-Base-163.repo 
* 或者不用安装wget使用：curl -O http://mirrors.163.com/.help/CentOS7-Base-163.repo

* yum list
* yum repolist #显示已经配置的源	
```

* 安装扩展源epel

```BASH
* yum install -y epel-release
* yum list | grep epel 或者 yum repolist 
```

##yum 下载rpm包
* yum install -y 包名 --downloadonly
* ls /var/cache/yum/x86_647/ #cat /etc/yum.conf 中cachedir内容
* yum install -y --downloadonly --downloaddir==路径 #指定路径下载不使用/etc/yum.conf中cachedir的内容
* yum reinstall -y 包名 --downloadonly --downloaddir=路径 #重新安装并下载

##源码包下载安装
* cd /usr/local/src #约定把源码包下载在此处
* [root@xujb01 src]# wget https://mirrors.aliyun.com/apache/httpd/httpd-2.2.34.tar.gz
* tar -zxvf httpd-2.2.34.tar.gz
* cd httpd-2.2.34
* 查看README-查看INSTALL
* ./configure --prefix=/usr/local/apache2 #指定源码包安装在此处
>如果提示错误：有依赖包未安装，就按照提示安装依赖包先，
	echo $？查看上一条命令的运行状态 0 为上条命令运行正常，1为运行错误 	

* make   #编译成二进制文件
* make install
* 卸载就是删除安装的文件

##扩展
* 配置yum优先级

```bash
* yum install -y yum-priorities
* cat /etc/yum/pluginconf.d/proorities.conf 
	[root@xujb01 httpd-2.2.34]# cat /etc/yum/pluginconf.d/priorities.conf
	[main]
	enabled = 1 #0 禁用 1启用
* 然后在 /etc/yum.repos.d/中的各个仓库中加入priority=N #N 范围 1-99 数字越大级别越低
	[root@xujb01 httpd-2.2.34]# cat /etc/yum.repos.d/dvd.repo
	[dvd]
	name=install dvd
	baseurl=file:///mnt
	enable=1
	gpgcheck=0
	priority=1
	在把刚下载的163的仓库base源加priority=2，然后用yum 下载软件可以看到源来自dvd，反过来修改就可以看到源来自base
	正在安装:
	 zsh          x86_64          5.0.2-28.el7             dvd          2.4 M

```

## 把源码包打包成rpm包

>http://www.linuxidc.com/Linux/2012-09/70096.htm


=====================================================================================
#20171114
五周第一次课（6月26日）
7.1 安装软件包的三种方法
7.2 rpm包介绍
7.3 rpm工具用法
7.4 yum工具用法
7.5 yum搭建本地仓库（视频中ppt小错误： gpcheck改为gpgcheck，yum cean 改为 yum  clean）
扩展
1. yum保留已经安装过的包   http://www.360doc.com/content/11/0218/15/4171006_94080041.shtml
2. 搭建局域网yum源  http://ask.apelearn.com/question/7627
-------------------------------------------------------
#安装与卸载软件
* rpm 工具
* yum 工具
* 源码包


##rpm 工具
* 设置光驱并挂载 #mount /dev/cdrom /mnt
* rpm 包格式，包名-版本号-发布版本号.平台 #zziplib-0.13.62-5.el7.x86_64.rpm
* rpm -ivh xx.rpm #安装
* rpm -Uvh xx.rpm #升级
* rpm -e xx.rpm #卸载
* rpm -qa #查询系统安装的包
* rpm -q xx.rpm #查询制定包是否已经安装
* rpm -qi xx.rpm #查询制定包信息
* rpm -ql xx.rpm #列出安装包的文件
* rpm -qf 文件绝对路径 #查看一个文件是由哪个包安装

###rpm 工具使用
* rpm -qf /usr/bin/ls
```bash
[root@xujb01 Packages]# rpm -qf /usr/bin/ls
coreutils-8.22-18.el7.x86_64
```
* rpm -ql coreutils
```bash
[root@xujb01 Packages]# rpm -ql coreutils
/etc/DIR_COLORS
/etc/DIR_COLORS.256color
/etc/DIR_COLORS.lightbgcolor
/etc/profile.d/colorls.csh
/etc/profile.d/colorls.sh
...省略
```
* rpm -qi coreutils
```bash
[root@xujb01 Packages]# rpm -qi coreutils
Name        : coreutils
Version     : 8.22
Release     : 18.el7
Architecture: x86_64
Install Date: 2017年10月18日 星期三 00时59分14秒
Group       : System Environment/Base
Size        : 14589167
License     : GPLv3+
...省略
```
**rpm 安装的时候有依赖关系，如果有依赖关系，需要手动一个一个按顺序按照好**

##yum 工具包

* yum list #列出可用rpm包
* /etc/yum.repos.d/ #yum仓库路径
* yum search vim #搜索包
* yum install -y 软件名
* yum grouplist #列出组 ‘最小安装、桌面视图安装等’
* yum groupinstall [-y] #安装组
* yum remove [-y] #卸载软件yum -y erase
* yum update [-y] #更新软禁
* yum provides "/*/vim" #查找提供指定内容的软件包
------------------

* yum list #列出可用rpm包
* yum search vim #搜索包
```bash
[root@xujb01 Packages]# yum list | grep vsftpd
vsftpd.x86_64                               3.0.2-22.el7               base
vsftpd-sysvinit.x86_64                      3.0.2-22.el7               base

[root@xujb01 Packages]# yum search vsftpd
已加载插件：fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: centos.ustc.edu.cn
 * updates: mirrors.aliyun.com
========================================================= N/S matched: vsftpd =========================================================
vsftpd-sysvinit.x86_64 : SysV initscript for vsftpd daemon
vsftpd.x86_64 : Very Secure Ftp Daemon

  名称和简介匹配 only，使用“search all”试试。

```
-----------------
###yum 本地仓库
* 挂载镜像到/mnt目录 #mount /dev/cdrom /mnt
* 删除系统的仓库文件
```bash

root@xujb01 Packages]# cp -r /etc/yum.repos.d/ /etc/yum.repos.d.bak;rm -f /etc/yum.repos.d/*  
                     

```
* vim /etc/yum.repos/dvd.repo #创建新仓库文件并编辑内容 
```bash
[dvd]
name=install dvd
baseurl=file:///mnt
enable=1
gpgcheck=0
```
* yum clean all #清空缓存数据
* yum list #查看是否更新万完成
```bash
最后一列为 仓库名 并且带@name 有@开头的表示已经安装过的软件
samba.x86_64                                4.6.2-11.el7_4             dvd
```

###保留yum安装的rpm包
* 系统默认安装完软件后自动删除rpm包，设置保留下载的rpm包
	vim /etc/yum.conf
```BASH

[main]
#cachedir=/var/cache/yum/$basearch/$releasever
cachedir=/home/soft1/yumcache
#keepcache=0
keepcache=1
#保存已经下载的rpm包
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=5
bugtracker_url=http://bugs.centos.org/set_project.php?project_id=23&ref=http://bugs.centos.org/bug_report_page.php?category=yum
distroverpkg=centos-release
```
###搭建局域网yum源  

```BASH
1、搭建Apache服务器或ftp服务器
yum安装或二进制包安装

2、准备RPM包把CentOS的DVD1和DVD2.iso都下载下来，把DVD1.iso里的所有内容解压出来，放到/var/www/html/centos-6目录下，然后把DVD2.iso解压出来的Packages目录下的rpm包复制到/var/html/centos-6/Packages目录下，这样/var/html/centos-6/Packages里面就有了6000多个rpm包。

3、创建yum仓库
准备createrepo：yum -y install createrepo
创建repository：createrepo /var/www/html/centos-6/
创建完成之后，会在/var/www/html/centos-6/repodata下生成一些文件。


4、使用软件源

在其他centos机器上试试软件源能不能用。

首先修改机器上软件源配置文件：

# cd /etc/yum.repos.d/
# mkdir bk
# mv *.repo bk/
# cp bk/CentOS-Base.repo ./
# vi CentOS-Base.repo

CentOS-Base.repo文件修改之后如下：

[base]
name=CentOS-$releasever - Base
baseurl=http://*.*.*.*/centos-6/
gpgcheck=1(改成0下面那行就不用设置了)
gpgkey=http:///*.*.*.*/centos-6/RPM-GPG-KEY-CentOS-6
enabled=1
#released updates 
#[updates]
#name=CentOS-$releasever - Updates
#baseurl=http:///*.*.*.*/centos-6/
#gpgcheck=1
#gpgkey=http:///*.*.*.*/centos-6/RPM-GPG-KEY-CentOS-6
#enabled = 1

保存之后，就可以使用局域网的软件源了：

# yum update


原地址：http://www.linuxidc.com/Linux/2013-07/87315.htm



=========================================================================================================
#20171110
四周第五次课（6月23日）
6.5 zip压缩工具
6.6 tar打包
6.7 打包并压缩
看下这个帖子： http://ask.apelearn.com/question/5435
------------------------------------------------------
##压缩文件2

###zip 压缩工具
**压缩**
* 可以压缩目录
* zip -R foo.zip "*" #只限制在所在目录进行递归压缩 不会删除源文件
* zip -r foo.zip /mnt/* #可以在其他目录进行递归压缩 不会删除源文件
* zip foo.zip "*" #会把所有文件和文件夹压缩，但是文件夹里的文件不会压缩
**解压**
* unzip foo.zip
* unzip foo.zip -d foo #指定压缩目录
* unzip -l foo.zip #查看foo.zip压缩文件列表，不解压

##打包工具 tar
* tar -cvf 11.tar 11
* tar -cvf 11.tar 11.txt 22.txt #把11.txt 22.txt文件打包
* tar -xvf 11.tar #在所在目录解包（pwd查看当前所在目录）如果当前目录有相印文件则覆盖
* tar -xvf 11.tar -C test01 #在指定目录进行解包操作
* tar -tf 11.tar  #查看打包文件列表
* tar -cvf 11.tar --exclude 11.txt --exclude 22.txt * #不把指定文件包含在内

* tar -rf 11.tar 2 # 打包文件11.tar增加文件2
* tar -uf 11.tar 2 # 打包文件11.tar更新文件2的内容 更新内容后查看文件可以看到有两个`2`文件，解包后可以看到是最新的内容

##tar 打包并压缩
* tar -zcvf 11.tar.gz 11    #单个打包压缩文件（gzip)
* tar -zcvf 11.tar.gz 11 22 #打包压缩多个文件
* tar -zxvf 11.tar.gz       #解压文件
* tar -zxvf 11.tar.gz -C test/ #解压到指定目录test

* tar -jcvf 11.tar.bz2 11 #单个打包压缩文件（bzip2）
* tar -jcvf 11.tar.bz2 11 22 #多个文件打包
* tar -jxvf 11.tar.bz2  #解压文件
* tar -jxvf 11.tar.bz2 -C test/ #解压到指定目录

* tar -Jcvf 11.tar.bz2 11 #单个文件打包压缩文件（xz格式）
* 其他和`gzip`打包压缩类似

* tar -tf 11.tar.bz2 #查看打包压缩文件，无论是什么格式的文件 


----------------------------------------------------
#20171109
四周第四次课（11月09日）
6.1 压缩打包介绍
6.2 gzip压缩工具
6.3 bzip2压缩工具
6.4 xz压缩工具
-----------------------------
##压缩文件
**常见压缩文件**

windows .rar .zip .7z
linux .zip .gz .bz2 .xz .tar.gz tar.bz2 .tar.xz

* gzip   zcat
* bzip2 
* xz     xzcat
*

###gzip 压缩工具
用法：
**压缩：**
* 不能压缩目录
* gzip 1.txt # 压缩1.txt文件，但是会把源文件删除 
* gzip -c 1.txt > 1.txt.gz # `-c`选项不删除源文件，但是要指定目的文件名
* gzip -6 1.txt # `-6` 选项指定压缩级别：级别为[1-9] 默认压缩级别为6
**解压缩**
* gzip -d 1.txt.gz # 解压的源文件1.txt.gz会删除
* gzip -d -c 1.txt.gz > 1.txt #`-c` 选项同样不删除源文件，也不需要指定文件名
* zcat 1.txt.gz > 1.txt #需要指定文件名不删除源文件
* gunzip -c 1.txt.gz > 1.txt #需要指定文件名

###bzip2 压缩工具
*压缩级别比gzip要高一些*
用法：
**压缩** 
* 不支持压缩目录
* bzip2 1.txt 
* gzip -c 1.txt > 1.txt.bz2
* gzip -9 1.txt # `-9` 为默认级别
*解压缩*
* bzip2 -d 1.txt.bz2
* bzip2 -d -c 1.txt.bz2 > 1.txt
* bunzip2 -c 1.txt.bz2 > 1.txt
*bzip2和gzip用法一样*

###xz 压缩工具
用法：
**压缩**
* 不能压缩目录
* xz 1.txt 
* xz -c 1.txt > 1.txt.xz
* xz -6 1.txt # `-6` 选项指定压缩级别：级别为[1-9] 默认压缩级别为6
**解压缩**
* xz -d 1.txt.xz
* xz -d -c 1.txt.xz > 1.txt
* unxz 1.txt.xxz
* xzcat 1.txt.xz > 1.txt





