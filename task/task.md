#2018-03-06 10:18:50

任务要求:
192.168.200.160-161： rs3 rs4 主要是把 lnmp、tomcat+jdk环境 discuz论坛、
                      dedecms企业网站以及zrlog博客，环境搭好
            169-172:  双主双从


## 搭建基本使用环境

* openssh-server  lrzsz vim net-tools wget bash-completion unzip
* hosts文件 编辑/root/.bashrc

1、yum -y install openssh-server lrzsz vim epel-release
   yum -y install gcc gcc-c++ autoconf automake make 
   yum -y install perl-Data-Dumper libaio
   yum -y install pcre-devel zlib-devel
   yum -y install httpd-devel  libxml2-devel  openssl-devel bzip2-devel libjpeg-turbo-devel libpng-devel freetype-devel
   yum -y install libmcrypt-devel
2、把xshell 公钥拷贝到 authorized_keys文件中
3、拷贝host内容到/etc/hosts 把hosts内容设置成 alias
 
## 搭建 lnmp

linux:CentOS Linux release 7.3.1611 (Core)
nginx： http://nginx.org/download/nginx-1.12.2.tar.gz
mysql: mysql5.6  http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
PHP: PHP7.2 http://hk1.php.net/get/php-7.2.0.tar.gz/from/this/mirror

mysql->nginx->php

下载文件
* wget -P http://nginx.org/download/nginx-1.12.2.tar.gz
...

### mysql

* 解压 mv 到 /usr/local/mysql(2进制包)
* useradd mysql;mkdir /data
* yum -y install perl-Data-Dumper libaio
* ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
* cp support-files/mysql.server /etc/init.d/mysqld
* vi /etc/init.d/mysqld
  定义basedir 和 datadir
* /usr/local/mysql/bin/mysqladmin -uroot password '123456' #设置密码
* ln -s /usr/local/mysql/bin/mysql /usr/bin/

### 安装nginx

* yum -y install gcc gcc-c++ autoconf automake make //可以在前面基础环境安装
* yum -y install pcre-devel zlib-devel
* ./confiure --prefix=/usr/local/nginx
* make && make install
* 配置 /etc/init.d/nginx;chmod 755 !$
* 编辑 conf/nginx.conf

### 安装 php7

--enable-memcache php7没有该参数 后期可以添加此模块

* yum -y install httpd-devel  libxml2-devel  openssl-devel bzip2-devel libjpeg-turbo-devel libpng-devel freetype-devel
* ./configure --prefix=/usr/local/php7 --with-apxs2=/usr/bin/apxs --with-config-file-path=/usr/local/php7/etc --with-pdo-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-bz2 --with-openssl --enable-soap --enable-mbstring --enable-sockets --enable-exif --enable-fpm 
* make&&make install 
* cp php.ini-production /usr/local/php7/etc/php.ini

 安装memcache
 * wget https://github.com/websupport-sk/pecl-memcache/archive/php7.zip
 * unzip  php7.zip
 * cd pecl-memcache-php7;/usr/local/php-fpm/bin/phpize //生成configure文件
 * ./configure --with-php-config=/usr/local/php/bin/php-config
 * make&&make install 
 * vim /usr/local/php7/etc/php.ini //添加 extension="memcache.so"
 * /usr/local/php7/bin/php -m | grep memcache //查看加载否
 
 * useradd -s /sbin/nologin php-fpm -U
 * vim /usr/local/php5/etc/php-fpm.conf

     ```bash
     pid = /usr/local/php5/var/run/php-fpm.pid
     error_log = /usr/local/php5/var/log/php-fpm.log
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
* /usr/local/php5/sbin/php-fpm //启动网站对php的支持

**至此LNMP 环境安装完成**

php5: 多安装: yum install -y epel-release;yum -y install libmcrypt-devel
安装memcache去官网安装。
* wget http://pecl.php.net/get/memcache-2.2.7.tgz
* ./configure --prefix=/usr/local/php5 --with-apxs2=/usr/bin/apxs \
--with-config-file-path=/usr/local/php5/etc \
--with-mysql=/usr/local/mysql --with-pdo-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir \
--with-iconv-dir --with-zlib-dir --with-bz2 --with-openssl --with-mcrypt \
--enable-soap --enable-gd-native-ttf --enable-mbstring --enable-sockets --enable-exif \
--enable-fpm



### tomcat 安装

下载jdk1.8并配置环境:
* 下载安装jdk1.8:wget -O jdk-8u161-linux-x64.tar.gz --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz
* 使用sftp 传递已经下载好的jdk1.8 tar包(上面网站速度太慢)
* tar -zxvf jdk-8u161-linux-x64.tar.gz--no-check-certificate
* jdk1.8.0_144 /usr/local/jdk1.8
* vi /etc/profile //最后面增加
  JAVA_HOME=/usr/local/jdk1.8/
  JAVA_BIN=/usr/local/jdk1.8/bin
  JRE_HOME=/usr/local/jdk1.8/jre
  PATH=$PATH:/usr/local/jdk1.8/bin:/usr/local/jdk1.8/jre/bin
  CLASSPATH=/usr/local/jdk1.8/jre/lib:/usr/local/jdk1.8/lib:/usr/local/jdk1.8/jre/lib/charsets.jar
* source /etc/profile;java -version //测试jdk环境设置正常

下载Tomcat8.5.28 并安装

* wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.28/bin/apache-tomcat-8.5.28.tar.gz
* tar zxvf apache-tomcat-8.5.28.tar.gz;mv apache-tomcat-8.5.28 /usr/local/tomcat
* /usr/local/tomcat/bin/startup.sh;ps -ef| grep tomcat;netstat -anutp|grep java//查看tomcat是否正常运行


### 把三个网站移入服务器

* mkdir /data/www/discuz
* mkdir /data/www/dedecms
* mkdir /data/www/tomcat
* 把下载的discuz 和dedecms 解压到 相应data目录下 //一定要根据要求改，install文件可能需要x权限
* 根据 readme给文件写权限
* 把 zrlog放在tomcat里

tomcat 创建tomcat项目

* cp -r /usr/local/tomcat/webapps/ROOT /data/www/tomcat/
* 编辑虚拟主机www.ceshizu5.com vim conf/server.conf //更改default host 为 www.ceshizu5.com

```bash
<Host name="www.ceshizu5.com" appBase="/data/www/tomcat"
        unpackWARs= "true" autoDeploy="true"
        xmlValidation="false" xmlNamespaceAware="false">
        <Context path="" docBase="/data/www/tomcat" debug="0" reloadable="true" crossContext="true"/>

     <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="ceshizu5_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
```

* /usr/local/tomcat/bin/startup.sh //启动tomcat 可以看到 /data/www/tomcat中zrlog.tar自动解包，并且访问
  curl -x192.168.200.160:8080 www.ceshizu5.com -I 访问正常
* iptables -I INPUT -p tcp --dport 8080 -j ACCEPT//然后在其他主机可以正常访问

nginx配置 discuz和dedecms

* 编辑conf/nginx.conf 添加 include vhost/* //需要把这个放在定义的末尾，不然虚拟主机加载了，
  日志定义可能加载不到虚拟主机内
* mkdir vhost;vim vhost/ceshizu5.conf

```bash
server
{
    listen 80;
    server_name www.ceshizu5.com;
    index index.html index.htm index.php;
    root /data/www;
    charset utf-8;
    
    access_log	logs/access.log	combined_realip;
    
    location ~ "zrlog*" {      

        proxy_pass http://www.ceshizu5.com:8080; 
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
 
       } 


    location ~ \.php$
    {
        include fastcgi_params;
        fastcgi_pass unix:/tmp/php-fcgi.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /data/www$fastcgi_script_name;
    }
}
//主要是开启php解析需要开启php-fpm服务，和zrlog/后缀代理到tomcat:8080 去处理，其他直接访问
```
**使用代理的时候本来是需要设置upstream(负载均衡里的)，但是因为只有一个网站代理，所以在/etc/hosts添加
192.168.200。160 www.ceshizu5.com也可以**
