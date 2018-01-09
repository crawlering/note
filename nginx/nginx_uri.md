#nginx 针对请求的uri来代理

场景：1台nginx去代理4台apache
需求：根据不同的请求uri 代理到不同的apache

```bash
upstream aa.com {         
                      server 192.168.0.121;
                      server 192.168.0.122;  
     }
    upstream bb.com {  
                       server 192.168.0.123;
                       server 192.168.0.124;
        }
    server {
        listen       80;
        server_name  www.abc.com;
        location ~ aa.php
        {
            proxy_pass http://aa.com/;
            proxy_set_header Host   $host;
            proxy_set_header X-Real-IP      $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
         location ~ bb.php
        {
              proxy_pass http://bb.com/;
              proxy_set_header Host   $host;
              proxy_set_header X-Real-IP      $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          }
}

```


# nginx代理--根据访问的目录来区分后端的web

我的需求： 当请求的目录是 /aaa/ 则把请求发送到机器a，当请求的目录为/bbb/则把请求发送到机器b，除了目录/aaa/与目录/bbb/外，其他的请求发送到机器b

```bash
upstream aaa.com
{
            server 192.168.111.6;
}
upstream bbb.com
{
            server 192.168.111.20;
}
server {
        listen 80;
        server_name li.com;
        location /aaa/
        {
            proxy_pass http://aaa.com/aaa/;
            proxy_set_header Host   $host;
            proxy_set_header X-Real-IP      $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location /bbb/
        {
            proxy_pass http://bbb.com/bbb/;
            proxy_set_header Host   $host;
            proxy_set_header X-Real-IP      $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location /
        {
            proxy_pass http://bbb.com/;
            proxy_set_header Host   $host;
            proxy_set_header X-Real-IP      $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}


```

*location /bbb/ 可以写到 location / 中 已经被其包括*
