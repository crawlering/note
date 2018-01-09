#nginx 访问日志

* 日志格式
 vim /usr/local/nginx/conf/nginx.conf //搜索log_format
 
 $remote_addr:  客户端IP（公网IP）
 $http_x_forwarded_for:  代理服务器IP
 $time_local:  服务器本地时间
 $host:  访问主机名(域名)
 $request_uri:  访问的uri地址
 $status:   状态码
 $http_referer:   referer
 $http_user_agent:  user_agent

```bash 
http中:
 log_format combined_realip '$remote_addr $http_x_forwarded_for [$time_local]'
```


* 除了在主配置文件nginx.conf里定义日志格式外，还需要在虚拟主机配置文件中增加
 access_log /tmp/1.log combined_realip;
 这里的combined_realip就是在nginx.conf中定义的日志格式名字
 /usr/local/nginx/sbin/nginx -t && -s reload
 curl -x127.0.0.1:80 test.com -I
 cat /tmp/1.log


##nginx 日志切割

* 自定义shell 脚本
 vim /usr/local/sbin/nginx_log_rotate.sh//写入如下内容

```bash
#! /bin/bash
## 假设nginx的日志存放路径为/data/logs/
d=`date -d "-1 day" +%Y%m%d` 
logdir="/data/logs"
nginx_pid="/usr/local/nginx/logs/nginx.pid"
cd $logdir
for log in `ls *.log`
do
    mv $log $log-$d
done
/bin/kill -HUP `cat $nginx_pid`
```

 任务计划
 0 0 * * * /bin/bash /usr/local/sbin/nginx_log_rotate.sh


##静态文件不记录日志和过期时间
 
* 配置如下

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


*注： nginx.conf 中 log_format 定义 log的格式，而如果虚拟主机中没有定义access_log 则会默认使用combined格式的log*
