# php-fpm slow log

* 在nginx 虚拟机配置中 配置 php解析

```BASH
location ~ \.php$
        {
            include fastcgi_params;
          fastcgi_pass unix:/tmp/php-fcgi.sock;

            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /data/www/discuz$fastcgi_script_name;
        }
```

* 配置中有定义sock: /tmp/php-fcgi.sock;

* 然后在php 配置 池: /usr/local/php-fpm/etc/php-fpm.d/www:

```bash
[www]
listen = /tmp/php-fcgi.sock
listen.mode = 666
user = php-fpm
group = php-fpm
pm = dynamic
pm.max_children = 50
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
rlimit_files = 1024

;slow log##
request_slowlog_timeout = 2
slowlog = /var/log/www-slow.log

```

# nginx 关闭 静态文件访问记录:

* 编辑nginx虚拟机配置文件 /usr/local/nginx/conf/vhost/bbs.conf 添加内容

```bash 
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
    {
          expires      7d; #有效时间
          access_log off; #关闭日志
    }

location ~ .*\.(js|css)$
    {
          expires      12h;
          access_log off;
    }
    
```



