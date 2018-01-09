# LAMP 学习总结

## 安装

* nginx - PHP 安装对于 apache 需要加 增加 --enable-fpm 
* nginx 安装 可以加 --with-dubug 增加 debug信息 
  下载 echo-nginx-module 进行安装 --add-module=/usr/src/local/echo-nginx-module-master
  加 --with-http_ssl_module 增加 https 协议的解析

## 用户认证
* nginx 用户认证 auth_basic "Auth"; auth_basic_user_file /usr/local/nginx/conf/htpasswd,使用httpd的 htpasswd 生成密码文件

##域名重定向
* 域名重定向 使用 rewrite ^(.*)$ http://test.com/$1 permanent;

## 日志访问
* nginx 日志访问: log_format 
  在虚拟中不定义access_log 则默认使用combined 
  网页打开PHP dubug日志: 	/usr/local/php-fpm/etc/php.ini 中打开 "display_errors = on"
  

* php-fpm 慢执行日志 在虚拟主机中定义:request_slowlog_timeout = 1
  slowlog = /usr/local/php-fpm/var/log/www-slow.log


## nginx 代理 和 均衡负载

* proxy

    proxy_pass      http://121.201.9.155/;
    proxy_set_header Host   $host;
    proxy_set_header X-Real-IP      $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;


* 负载均衡：

    upstream qq_com
{
    ip_hash;
    server 61.135.157.156:80;
    server 125.39.240.113:80;
}
    
## ssl (https)

* ssl 生成密钥
* ssl配置

server
{
    listen 443;
    server_name aming.com;
    index index.html index.php;
    root /data/wwwroot/aming.com;
    ssl on;
    ssl_certificate aminglinux.crt;
    ssl_certificate_key aminglinux.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
}

* 解析php需要重新定义

## php-fpm 进程管理

* php-fpm pool  #include etc/php-fpm.d/*.conf  需要放在 pid 和 log 的后面，不然会报错
* php-fpm 进程管理 既是对 php-fpm 参数的配置 
    pm = dynamic  #动态
    pm.max_children = 50 #最大子进程 ps aux 可以查看
    pm.start_servers = 20 #启动服务时候启动的进程
    pm.min_spare_servers = 5 #空闲最小进程
    pm.max_spare_servers = 35 #空闲最大进程
    pm.max_requests = 500 #定义一个进程最大的请求数，
    rlimit_files = 1024







=========================================
十二周三次课（1月9日）
12.21 php-fpm的pool
12.22 php-fpm慢执行日志
12.23 open_basedir
12.24 php-fpm进程管理

---------------------------

# php-fpm 的pool

* vim /usr/local/php/etc/php-fpm.conf//在[global]部分增加
 include = etc/php-fpm.d/*.conf

**include 需要加在pid 和 error_log的后面,否则会报错**

* mkdir /usr/local/php/etc/php-fpm.d/
* cd /usr/local/php/etc/php-fpm.d/
* vim www.conf //内容如下

```bash
[www]
listen = /tmp/www.sock
listen.mode=666
user = php-fpm
group = php-fpm
pm = dynamic
pm.max_children = 50
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
rlimit_files = 1024
```

* 继续编辑配置文件 vim xujb.conf


```bash
[xujb]
listen = /tmp/xujb.sock
listen.mode=666
user = php-fpm
group = php-fpm
pm = dynamic
pm.max_children = 50
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
rlimit_files = 1024

```

* /usr/local/php/sbin/php-fpm –t
* /etc/init.d/php-fpm restart

**每个网站服务器设定一个专门的守护程序并且进行参数配置，listen 的sock 是给nginx 去绑定的**
nginx 绑定的位置就是在进行PHP解析的地方

```bash
location ~ \.php$
        {
            include fastcgi_params;
            fastcgi_pass unix:/tmp/php-fcgi.sock; #或者xujb.sock
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /usr/local/nginx/html$fastcgi_script_name;
        }

```

# php 慢执行日志

**慢执行日志的作用就是可以定位到程序在哪里执行的慢了，消耗的时间长了**

* vim /usr/local/php-fpm/etc/php-fpm.d/www.conf//加入如下内容
 > request_slowlog_timeout = 1
 > slowlog = /usr/local/php-fpm/var/log/www-slow.log

* 配置nginx的虚拟主机test.com.conf，把unix:/tmp/php-fcgi.sock改为unix:/tmp/www.sock
 重新加载nginx服务
* vim /data/www/test02/sleep.php//写入如下内容
> <?php echo “test slow log”;sleep(2);echo “done”;?>

* curl -x127.0.0.1:80 test.com/sleep.php 
* cat /usr/local/php-fpm/var/log/www-slow.log

**测试过程中 访问设置的sleep.php 文件显示找不到，然后在访问此文件夹内的其他php文件同样访问不到，然后查找虚拟机配置文件 php解析出发现"fastcgi_param SCRIPT_FILENAME /usr/local/nginx/html$fastcgi_script_name" 寻找PHP文件位置找错了 修改为"fastcgi_param SCRIPT_FILENAME /data/www/test02/$fastcgi_script_name" 即可**

# nginx php 定义 open_basedir

*目录访问限制*

在apache中配置 php解析的时候 在php配置文件里可以配置 open_basedir 这个是全局配置的，所有虚拟主机都一样，
需要当个虚拟主机不同的配置，在PHP配置文件就不进行配置放在虚拟主机进行配置,
配置参数为 (php_admin_value open_basedir "/data/www/test01/:/tmp" 表示此虚拟机目录限制在/data/www/test01/和/tmp 目录下 )


* 而在 nginx中设定就可以在 nginx 虚拟服务器 对应php-fpm 的pool 中 进行定义

* vim /usr/local/php-fpm/etc/php-fpm.d/aming.conf//加入如下内容
 >php_admin_value[open_basedir]=/data/www/test01:/tmp/

而上述配置看不出来我们的open_basedir 是否成功限制注了PHP读取目录，因为nginx的读取目录也是在这里，所以可以设置小点的范围，改成：
 > php_admin_value[open_basedir]=/data/www/test01/testdir:/tmp/
* curl -x192.168.31.20:80 -uxujb:123456 www.test01.com/testdir/test.php 测试结果为：在根目录下的html文件可以访问，".php"文件访问不了，显示"No input file specified",而testdir文件内的".php" 文件可以正常访问，而前面没有做限制的时候是可以正常访问根目录的".php"文件的*

# nginx php-fpm 进程管理

* pm = dynamic  //动态进程管理，也可以是static
* pm.max_children = 50 //最大子进程数，ps aux可以查看
* pm.start_servers = 20 //启动服务时会启动的进程数
* pm.min_spare_servers = 5 //定义在空闲时段，子进程数的最少数量，如果达到这个数值时，php-fpm服务会自动派生新的子进程。
* pm.max_spare_servers = 35 //定义在空闲时段，子进程数的最大值，如果高于这个数值就开始清理空闲的子进程。
* pm.max_requests = 500  //定义一个子进程最多处理的请求数，也就是说在一个php-fpm的子进程最多可以处理这么多请求，当达到这个数值
  时，它会自动退出。


==================================================
十三周一次课（1月8日）
12.17 Nginx负载均衡
12.18 ssl原理
12.19 生成ssl密钥对
12.20 Nginx配置ssl

扩展 
针对请求的uri来代理 http://ask.apelearn.com/question/1049 

根据访问的目录来区分后端的web http://ask.apelearn.com/question/920 

nginx长连接  http://www.apelearn.com/bbs/thread-6545-1-1.html 
---------------------------------------------------------------
 
# nginx 负载均衡

* vim /usr/local/nginx/conf/vhost/load.conf // 写入如下内容

```bash    
upstream qq_com
{
    ip_hash;
    server 61.135.157.156:80;
    server 125.39.240.113:80;
}
server
{
    listen 80;
    server_name www.qq.com;
    access_log logs/2.log combined_realip;
    location /
    {
        proxy_pass      http://qq_com;
        proxy_set_header Host   $host;
        proxy_set_header X-Real-IP      $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

```

* upstream来指定多个web server *
* ip_hash; #保持一台客户端主机始终访问1服务器IP，如果服务器有2个IP，但是没有这个参数，就会有可能当你登入后，一段时间又需要你重
  重新登入
* dig #查看域名所对应的所有ip
* 查看现象需要在 nginx.conf 中log_format 中加入 $upstream_addr 参数去显示每次访问的IP，然后用多台主机可以测试到每台主机访问的IP
  都是随机的


# SSL 工作流程

* 浏览器发送一个https的请求给服务器；
* 服务器要有一套数字证书，可以自己制作（后面的操作就是阿铭自己制作的证书），也可以向组织申请，区别就是自己颁发的证书需要客户端验证通过，才可以继续访问，而使用受信任的公司申请的证书则不会弹出>提示页面，这套证书其实就是一对公钥和私钥；
   服务器会把公钥传输给客户端；
* 客户端（浏览器）收到公钥后，会验证其是否合法有效，无效会有警告提醒，有效则会生成一串随机数，并用收到的公钥加密；
    客户端把加密后的随机字符串传输给服务器；
* 服务器收到加密随机字符串后，先用私钥解密（公钥加密，私钥解密），获取到这一串随机数后，再用这串随机字符串加密传输的数据（该加密为对称加密，所谓对称加密，就是将数据和私钥也就是这个随机字符串>通过某种算法混合在一起，这样除非知道私钥，否则无法获取数据内容）；
  服务器把加密后的数据传输给客户端；
* 客户端收到数据后，再用自己的私钥也就是那个随机字符串解密；

简易流程:

**客户端**--https请求--> **服务器** ---公钥传输---> **客户端** ---验证是否合法有效---合法或有效就产生随机字符串--加密-->
**服务器**---私钥解密获取发送来的随机字符串---加密发送信息---> **客户端** 用随机字符串进行解密

# 生成 SSL 密钥对

* cd /usr/local/nginx/conf
* openssl genrsa -des3 -out tmp.key 2048//key文件为私钥
* openssl rsa -in tmp.key -out test.key //转换key，取消密码 
* rm -f tmp.key #可以不删除
* openssl req -new -key test.key -out test.csr//生成证书请求文件，需要拿这个文件和私钥一起生产公钥文件
* openssl x509 -req -days 365 -in test.csr -signkey test.key -out test.crt
 这里的test.crt为公钥

# nginx 配置SSL

* vim /usr/local/nginx/conf/vhost/ssl.conf//加入如下内容

```bash
server
{
    listen 443;
    server_name www.test02.com;
    index index.html index.php;
    root /data/www/test02;
    ssl on;
    ssl_certificate test.crt;
    ssl_certificate_key test.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
}
```

* -t && -s reload //若报错unknown directive “ssl” ，需要重新编译nginx，加上--with-http_ssl_module
* mkdir /data/www/test02
* echo “ssl test page.”>/data/www/test02/index.html
  编辑hosts，增加127.0.0.1 www.test02.com
* curl https://www.test02.com/
* 在浏览器中访问 https://www.test02.com ，如果只是输入 www.test02.com 会访问里外个服务器。


----------------------------------------
十二周四次课（1月5日）
12.13 Nginx防盗链
12.14 Nginx访问控制
12.15 Nginx解析php相关配置
12.16 Nginx代理

扩展
502问题汇总 http://ask.apelearn.com/question/9109 

location优先级 http://blog.lishiming.net/?p=100 
-----------------------------------------------------
# nginx 防盗链

* 参考链接:http://nginx.org/en/docs/http/ngx_http_referer_module.html
* 来自模块: Module ngx_http_referer_module

##指令：

* refere_hash_bucket_size
Sets the bucket size for the valid referers hash tables. The details of setting up hash tables are provided in a separate document.
* refere_hash_max_size
Sets the maximum size of the valid referers hash tables. The details of setting up hash tables are provided in a separate document.
* valid referes: valid_referers none | blocked | server_names | string ...;
指定"REFERE"请求头部字段值，会引起"$invalid_refere" 的值为"0"或"1",后面字符匹配的则为"0"，否则则为"1"，匹配不区分大小写
>none: 在请求头部没有"Referer" 字段
>blocked: 请求头部中存在 “Referer” 字段，但是其值被防火墙或者代理服务器删除，此种情况会出现不是以"http://"和"https://"开始的
>server_names: 请求头部包含服务器名
>string: 定义一个服务器名，和一个可选的URI前缀，服务器名可以是以"*"结尾或者开始，不进行端口的检查

正则表达式：
第一个符号应该使用"~",并且匹配字符应该是从"http://"和"https://"

```bash
Example:

valid_referers none blocked server_names
               *.example.com example.* www.example.org/galleries/
               ~\.google\.;
```




* 配置如下，可以和上面的配置结合起来

```bash
location ~* ^.+\.(gif|jpg|png|swf|flv|rar|zip|doc|pdf|gz|bz2|jpeg|bmp|xls)$
{
    expires 7d;
    valid_referers none blocked server_names  *.test.com ;
    if ($invalid_referer) {
        return 403;
    }
    access_log off;
}
```

*location ~* ...:"~*"表示后面内容执行一个正则匹配并且不区分大小写，而"~"表示执行正则匹配但是区分大小写 *

*上面配置文件无作用，下载echo-nginx-module 在if($invalid_referer) 中加echo语句 可以看出并没有执行到该语句*

# nginx 访问控制

* 可以匹配正则

```bash
location ~ .*(abc|image)/.*\.php$
{
        deny all;
}
```

* 根据user_agent限制

```bash
if ($http_user_agent ~ 'Spider/3.0|YoudaoBot|Tomato')
{
      return 403;
}
 deny all和return 403效果一样
```
* 测试使用curl -A Tomato 或者 curl --user-agent Tomato 进行模拟代理

# nginx解析php的配置

* 配置如下:

```bash
location ~ \.php$
    {
        include fastcgi_params;
        fastcgi_pass unix:/tmp/php-fcgi.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /data/www/test02$fastcgi_script_name;
    }

```

* fastcgi_pass 用来指定php-fpm监听的地址或者socket
* fastcgi_index index.php #设定访问根目录默认去找的文件
* fastcgi_param SCRIPT_FILENAME /data/www/test02$fastcgi_script_name #设置访问根目录时默认寻找的文件

fastcgi_param SCRIPT_FILENAME /data/www/test02/abc$fastcgi_script_name #访问根目录www.test02.com/ 
会去默认寻找abc中index.php文件，而此时去访问这个index.php文件是寻找不到的只能通过根目录去访问
www.test02.com/abc/index.php 返回404

* 查看/usr/local/php-fpm/etc/php-fpm.conf 

```bash
pid = /usr/local/php-fpm/var/run/php-fpm.pid
error_log = /usr/local/php-fpm/var/log/php-fpm.log
[www]
listen = /tmp/php-fcgi.sock
;listen = 127.0.0.1:9000
listen.mode = 666
user = php-fpm
group =php-fpm
pm = dynamic
pm.max_children = 50
pm.start_servers = 20
pm.min_spare_servers =5
pm.max_spare_servers = 35
pm.max_requests = 500
rlimit_files = 1024

```

* 此文件设定了nginx 绑定的位置去给php-fpm解析

# nginx 代理

* cd /usr/local/nginx/conf/vhost
*  vim proxy.conf //加入如下内容

```bash
server
{
    listen 80;
    server_name ask.apelearn.com;

    location /
    {
        proxy_pass      http://121.201.9.155/;
        proxy_set_header Host   $host;
        proxy_set_header X-Real-IP      $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

----------------------------------------
20170102
十二周一次课（1月2日）
12.1 LNMP架构介绍
12.2 MySQL安装
12.3/12.4 PHP安装
12.5 Nginx介绍

扩展
Nginx为什么比Apache Httpd高效：原理篇 http://www.toxingwang.com/linux-unix/linux-basic/1712.html 

apache和nginx工作原理比较 http://www.server110.com/nginx/201402/6543.html 

mod_php 和 mod_fastcgi以及php-fpm的比较   http://dwz.cn/1lwMSd 

概念了解：CGI，FastCGI，PHP-CGI与PHP-FPM    http://www.nowamagic.net/librarys/veda/detail/1319/ 
---------------------------------------------------------------------

#LNMP架构介绍

* LNMP和LAMP 不同的是提供web服务的是Nginx
* PHP是作为一个独立服务存在的，这个服务叫做php-fpm
* Nginx直接处理静态请求，动态请求会转发给php-fpm

用户浏览器 ----Nginx-----php-fpm
                 |         |
	    静态文件     mysql


#PHP安装

* 和LAMP安装PHP是有差别的，需要开启php-fpm服务
* cd /usr/src/local/
* wget http://hk1.php.net/get/php-7.2.0.tar.gz/from/this/mirror #下载7.2.0
* ./configure --prefix=/usr/local/php-fpm --with-config-file-path=/usr/local/php-fpm/etc --enable-fpm --with-fpm-user=php-fpm --with-fpm-group=php-fpm --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-pdo-mysql=/usr/local/mysql --with-mysql-sock=/tmp/mysql.sock --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-mcrypt --enable-soap --enable-gd-native-ttf --enable-ftp --enable-mbstring --enable-exif --with-pear --with-curl  --with-openssl

```BASH
checking for cURL 7.10.5 or greater... configure: error: cURL version 7.10.5 or later is required to compile php with cURL support

```
* curl --version 查看版本是7.29.0？，查看php 搜索关键字curl 查看requirements需要安装libcurl，rpm -qa libcurl 显示的也是7.29.0
yum search curl 看到有devel包而，我们好像没有安装这个开发包，所以yum -y install libcurl-devel
* 之后./configure ... 之后有php5.0的参数去掉，重新./configure..
* make && make install

* cp php.ini-production /usr/local/php-fpm/etc/php.ini #从源文件中拷贝配置文件
* cp /usr/local/php-fpm/etc/php-fpm.conf.default /usr/local/php-fpm/etc/php-fpm.conf #编辑

```BASH
[global]
;include=/usr/local/php-fpm/etc/php-fpm.d/*.conf

pid = /usr/local/php-fpm/var/run/php-fpm.pid
error_log = /usr/local/php-fpm/var/log/php-fpm.log
[www]
listen = /tmp/php-fcgi.sock
;listen = 127.0.0.1:9000
listen.mode = 666
user = php-fpm
group =php-fpm
pm = dynamic
pm.max_children = 50
pm.start_servers =20
pm.min_spare_servers =5
pm.max_spare_servers = 35
pm.max_requests = 500
rlimit_files = 1024

```

* useradd -s /sbin/nologin php-fpm
* cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm #源码中拷贝服务启动文件到服务启动处
* chmod 755 /etc/init.d/php-fpm #给其root执行权限
* chkconfig --add php-fpm #加入开机启动项
* chkconfig php-fpm on #开机启动
* service php-fpm start #启动服务

# nginx

## nginx 介绍

* Nginx官网 nginx.org，最新版1.13，最新稳定版1.12 
* Nginx应用场景：web服务、反向代理、负载均衡(1个叫反向代理，2个反向代理叫负载均衡)
*  Nginx著名支
淘宝基于Nginx开发的Tengine，使用上和Nginx一致，服务名，配置文件名都一样，和Nginx的最大区别在于Tenging增加了一些定制化模块，在安全限速方面表现突出，另外它支持对js，css合并
* Nginx核心+lua相关的组件和模块组成了一个支持lua的高性能web容器openresty，参考http://jinnianshilongnian.iteye.com/blog/2280928

## nginx 安装

* cd /usr/src/local
* wget http://nginx.org/download/nginx-1.12.2.tar.gz
* tar -zxvf nginx-1.12.2.tar.gz
* ./configure --prefix=/usr/local/nginx
* make && make install
* vim /etc/init.d/nginx 

```bash
#!/bin/bash
# chkconfig: - 30 21
# description: http service.
# Source Function Library
. /etc/init.d/functions
# Nginx Settings

NGINX_SBIN="/usr/local/nginx/sbin/nginx"
NGINX_CONF="/usr/local/nginx/conf/nginx.conf"
NGINX_PID="/usr/local/nginx/logs/nginx.pid"
RETVAL=0
prog="Nginx"

start() 
{
    echo -n $"Starting $prog: "
    mkdir -p /dev/shm/nginx_temp
    daemon $NGINX_SBIN -c $NGINX_CONF
    RETVAL=$?
    echo
    return $RETVAL
}

stop() 
{
    echo -n $"Stopping $prog: "
    killproc -p $NGINX_PID $NGINX_SBIN -TERM
    rm -rf /dev/shm/nginx_temp
    RETVAL=$?
    echo
    return $RETVAL
}

reload()
{
    echo -n $"Reloading $prog: "
    killproc -p $NGINX_PID $NGINX_SBIN -HUP
    RETVAL=$?
    echo
    return $RETVAL
}

restart()
{
    stop
    start
}

configtest()
{
    $NGINX_SBIN -c $NGINX_CONF -t
    return 0
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  reload)
        reload
        ;;
  restart)
        restart
        ;;
  configtest)
        configtest
        ;;
  *)
        echo $"Usage: $0 {start|stop|reload|restart|configtest}"
        RETVAL=1
esac

exit $RETVAL
```

* chmod 755 /etc/init.d/nginx
* chkconfig --add nginx 
* chkconfig nginx on 
* cd /usr/local/nginx/conf/; mv nginx.conf nginx.conf.bak
* vim nginx.conf

```bash
user nobody nobody;
worker_processes 2;
error_log /usr/local/nginx/logs/nginx_error.log crit;
pid /usr/local/nginx/logs/nginx.pid;
worker_rlimit_nofile 51200;
events
{
    use epoll;
    worker_connections 6000;
}
http
{
    include mime.types;
    default_type application/octet-stream;
    server_names_hash_bucket_size 3526;
    server_names_hash_max_size 4096;
    log_format combined_realip '$remote_addr $http_x_forwarded_for [$time_local]'
    ' $host "$request_uri" $status'
    ' "$http_referer" "$http_user_agent"';
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 30;
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    connection_pool_size 256;
    client_header_buffer_size 1k;
    large_client_header_buffers 8 4k;
    request_pool_size 4k;
    output_buffers 4 32k;
    postpone_output 1460;
    client_max_body_size 10m;
    client_body_buffer_size 256k;
    client_body_temp_path /usr/local/nginx/client_body_temp;
    proxy_temp_path /usr/local/nginx/proxy_temp;
    fastcgi_temp_path /usr/local/nginx/fastcgi_temp;
    fastcgi_intercept_errors on;
    tcp_nodelay on;
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 8k;
    gzip_comp_level 5;
    gzip_http_version 1.1;
    gzip_types text/plain application/x-javascript text/css text/htm 
    application/xml;
    server
    {
        listen 80;
        server_name localhost;
        index index.html index.htm index.php;
        root /usr/local/nginx/html;
        location ~ \.php$ 
        {
            include fastcgi_params;
            fastcgi_pass unix:/tmp/php-fcgi.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /usr/local/nginx/html$fastcgi_script_name;
        }    
    }
}
```

* /usr/local/nginx/sbin/nginx -t
* /etc/init.d/nginx  start
* netstat -lntp |grep 80

##测试PHP解析

* vi /usr/local/nginx/html/1.php //加入如下内容

```BASH
 <?php
    echo "test php scripts.";
?>

```

* curl localhost/1.php


## nginx 默认虚拟主机

* vim /usr/local/nginx/conf/nginx.conf //增加
include vhost/*.conf; //加在http中
* mkdir /usr/local/nginx/conf/vhost
* cd !$;  vim default.conf
* /usr/local/nginx/sbin/nginx -t
* /usr/local/nginx/sbin/nginx -s reload
* curl localhost
* curl -x127.0.0.1:80 123.com

##nginx 用户认证
* vim /usr/local/nginx/conf/vhost/test.com.conf

```BASH
server
{
    listen 80;
    server_name test.com;
    index index.html index.htm index.php;
    root /data/wwwroot/test.com;
    
location  /
    {
        auth_basic              "Auth";
        auth_basic_user_file   /usr/local/nginx/conf/htpasswd;
}
}

```

* yum install -y httpd #如果没有安装就安装，为了使用他的htpasswd
*  /usr/local/apache2.4/bin/htpasswd -c /usr/local/nginx/conf/htpasswd xujb 
* /usr/local/nginx/sbin/nginx -t &&  -s reload //测试配置并重新加载

> 返回错误吗500?
>查看nginx_error.log 看到是查询htpasswd文件失败,查看文件所属看到不是nobody用户，使用chown nobody:nobody htpasswd,然后访问正常

* mkdir /data/wwwroot/test.com
* echo “test.com”>/data/wwwroot/test.com/index.html
* curl -x127.0.0.1:80 test.com -I//状态码为401说明需要验证
* curl -uxujb:passwd 访问状态码变为200
 编辑windows的hosts文件，然后在浏览器中访问test.com会有输入用户、密码的弹窗
* 针对目录的用户认证

```bash
location  /admin/
    {
        auth_basic              "Auth";
        auth_basic_user_file   /usr/local/nginx/conf/htpasswd;
}
```

## nginx 域名重定向

* 添加test02.conf

```BASH
server
{
    listen 80;
    server_name www.test02.com test02.com test2.com;
    index index.html index.htm index.php;
    root /data/www/test02;
    if ($host != 'test.com' ) {
        rewrite  ^/(.*)$  http://test01.com/$1  permanent;
    }
}
```

*除去test02.com 外 其他 www.test02.com或者 test2.com都进行跳转，返回状态码为301*

* server_name后面支持写多个域名，这里要和httpd的做一个对比
* permanent为永久重定向，状态码为301，如果写redirect则为302

    
