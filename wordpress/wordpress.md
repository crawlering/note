# 配置 wordpress

* 安装nginx,如果安装了就不用安装，如果安装了没有安装ssl模块则重新编译
  1、/usr/local/nginx/sbin/nginx -V 查看编译参数 记录参数 后面编译的时候 不要忘记前面的参数

  > --prefix=/usr/local/nginx

  2、这里在添加一个echo-nginx-module模块:wget -O https://github.com/openresty/echo-nginx-module/archive/master.zip
     然后解压

  3、这里我们需要多添加两个模块:
     在nginx源码重新编译:先 make clean; make distclean
     ./configure --prefix=/usr/local/nginx \
     --with-http_ssl_module \
     --add-module=/usr/local/src/echo-nginx-module-master 

  4、make; //不能make install 会覆盖原来设置的文件
     make完之后在objs目录下就多了个nginx，这个就是新版本的程序
     然后备份旧的nginx程序
     cp /usr/local/nginx/sbin/nginx/usr/local/nginx/sbin/nginx.bak
     把新的nginx程序覆盖旧的
     cp objs/nginx /usr/local/nginx/sbin/nginx
     测试 /usr/local/nginx/sbin/nginx -t
     平滑启动nginx:/usr/local/nginx/sbin/nginx -s reload
 
# nginx vhost配置

```BASH
server
{
    listen 443 default;
    server_name www.xxx.com;
    index index.html index.php;
    root /data/www/wordpress;
    ssl on;
    ssl_certificate test.crt;
    ssl_certificate_key test.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    error_page   500 502 503 504  50x.html;
    access_log	/var/log/nginx/access.log	combined_realip;

    location = /50x.html {
        root   /data/www/wordpress;
    }
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
    {
          expires      7d;
          access_log off;
    }
    location ~ .*\.(js|css)$
    {
          expires      12h;
          access_log off;
    }
    location ~ \.php$
    {
        include fastcgi_params;
        fastcgi_pass unix:/tmp/php-fcgi.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /data/www/wordpress$fastcgi_script_name;
    }

}

server
{
        listen 80;
        server_name www.xxx.com;
        index index.html index.htm index.php;
        root /data/www/wordpress;
        location ~ \.php$
        {
            include fastcgi_params;
            fastcgi_pass unix:/tmp/php-fcgi.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /usr/local/nginx/html$fastcgi_script_name;
        }

        location = /50x.html {
        root   /data/www/wordpress;
        }

        location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
        {
          expires      7d;
          access_log off;
        }
        location ~ .*\.(js|css)$
        {
          expires      12h;
          access_log off;
        }

}

```

# php7 修改

* /usr/local/php7/etc/php-fpm.conf //include 需要加载pid等设置后面 [www] 可以写在 php-fpm.d文件中

```bash
[global]
pid = /tmp/php-fpm.pid
error_log=/var/log/php-fpm/php-fpm.log
include=/usr/local/php7/etc/php-fpm.d/*.conf
[www]
php_admin_value[open_basedir]=/data/www/wordpress:/tmp/
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


# ssl 配置 加密更改

google 对 sha1加密认为不安全。
掠过:直接使用:
cd /usr/local/nginx/conf
openssl genrsa -des3 -out tmp.key 2048//key文件为私钥
openssl rsa -in tmp.key -out test.key //转换key，取消密码
rm -f tmp.key #可以不删除
openssl req -new -key test.key -out test.csr//生成证书请求文件，需要拿这个文件和私钥一起生产公钥文件
openssl x509 -req -days 365 -in test.csr -signkey test.key -out test.crt
这里的test.crt为公钥

ssl 使用 let's encrypt 进行ssl认证:
* 访问网站： https://letsencrypt.org/
             https://certbot.eff.rg/
* 根据网站提示:
  yum -y install yum-utils
  yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
  yum install certbot-nginx
  certbot --nginx certonly //提示无法import urllib3，卸载pip uninstall urllib3，pip install urllib3==1.21.1
  //然后执行报错pyopenssl版本太低:pip install --upgrade pyOpenSSL,还是没有用
  yum remove certbot && pip uninstall pyOpenSSL
  yum install -y python-devel
  yum install -y openssl-devel
  yum install certbot-nginx
  certbot --nginx certonly
  //报错:# Saving debug log to /var/log/letsencrypt/letsencrypt.log
  // The nginx plugin is not working; there may be problems with your existing configuration.
  //The error was: NoInstallationError()
  找不到配置文件:nginx是源码安装，仿照 yum安装路径
  ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
  ln -s /usr/local/nginx/conf/ /etc/nginx

  配置 邮箱-然后按照提示走
 
 ```BASH
 Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/www.xxx.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/www.xxx.com/privkey.pem
   Your cert will expire on 2018-06-28. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

  ```

* 修改nginx  ssl配置: /usr/local/nginx/conf/vhost/wordpress.conf

```bash
ssl on;
ssl_certificate /etc/letsencrypt/live/www.xxx.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/www.xxx.com/privkey.pem;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

```

# wordpress 安装插件

* 插件 安装markdown editor
* 提示需要ftp服务器:wp-config.php,添加以下代码
  define("FS_METHOD","direct");
  define("FS_CHMOD_DIR", 0777);
  define("FS_CHMOD_FILE", 0777);

* 提示无法创建目录:
  chmod -R 777 /data/www/wordpress/wp-content/plugins/
  //find /data/www/wordpress -type f -exec chmod 644 {} \;  //设置文件权限为644  前面把所有文件都设置成777了，可以
                                                            //用此命令改回来
  //find /data/www/wordpress -type d -exec chmod 755 {} \;  //设置目录权限为755
 
# wordpress 安装主题
 
* 网上下载一个主题
* 把主题解压放到 /data/www/wordpress/wp-content/themes/中
* chown -R nginx:nginx /data/www/wordpress

设置 上传图片文件权限:
* mkdir /data/www/wordpress/wp-content/uploads; chmod -R 777 /data/www/wordpress/wp-content/uploads;
* chown -R !$
*
