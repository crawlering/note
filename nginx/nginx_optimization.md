# nginx optimization



## 隐藏版本信息

* conf/nginx.conf
  http模块下添加: server_tokens off;
  重启服务

## 隐藏nginx

* 修改源码:
   src/core/nginx.h
  // #define NGINX_VERSION  "1.6.2" 修改为想要的版本 
  // #define NGINX_VER "nginx/" NGINX_VERSION 将nginx修改为想要修改的软件名称，如xujb。
  src/http/ngx_http_header_filter_module.c
  // Server: nginx 修改 Server: xujb
  编译 安装

```BASH
HTTP/1.1 404 Not Found
Server: xujb/1.12.2
Date: Mon, 19 Mar 2018 09:42:52 GMT
Content-Type: text/html
Content-Length: 168
Connection: keep-alive
```

# 更改nginx 服务默认用户

* conf/nginx.conf
  user nginx nginx;

# 降权启动

目的开发人员测试的时候不需要root用户权限，

上面已经改了用户启动，但是 master进程还是root用户的

其实用户启动，开发需要更改的就是配置文件，所以配置文件需要被提取出来conf/nginx.conf
而这里面 定义的log pid 以及用的到的模块都是 在 /usr/local/nginx/ 目录下加载的
随意需要修改nginx.conf相关内容。

  比如:test用户测试
* 首先: mkdir config logs www
* cp /usr/local/nginx/conf/nginx.conf conf/
* vim conf/nginx.conf //修改error_log access_log pid  php解析的fastcgi_params 填写绝对路径 
                     //include /usr/local/nginx/conf/mime.types 此项也写绝对路径，依托config文件的位置的，
                    // user不用设置了，然后是server的 root /home/test/www

```BASH
#user nginx test;
error_log /home/test/logs/error1.log crit;
worker_processes 1;
pid /home/test/logs/nginx.pid;
worker_rlimit_nofile 51200;
events
{
    use epoll;
    worker_connections 6000;
}
http
{
    include /usr/local/nginx/conf/mime.types;
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
        listen 8080;
        server_name localhost;
        index index.html index.htm index.php;
        root /home/test/www;
        error_log /home/test/logs/error2.log crit;
        access_log /home/test/logs/access.log combined_realip;
        location ~ \.php$
        {
            include /usr/local/nginx/conf/fastcgi_params;
            fastcgi_pass unix:/tmp/php-fcgi.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /home/test/www$fastcgi_script_name;
        }
    }
}

```

* 然后使用 /usr/local/nginx/sbin/nginx -c /home/test/conf/nginx.conf 启动服务，
* 此时 可以查看日志文件 可以修改配置文件达到要求


## 
