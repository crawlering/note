# nginx  代理的理解

* 反向代理
* 负载均衡
* 正向代理


反向代理和负载均衡是同一个东西

反向代理和正向代理:

    客户端  ->        代理      ->  服务器
           <---                <---
反向代理:
不需要再客户端配置，直接访问一个网站的域名，然后DNS 查到这个域名的服务器 服务器接受到信息后转发给 
对应的web服务器，
这些web服务器可以是局域网内的 也可以是 internet的，中间环节需要一个 域名解析的服务器去解析

正向代理:
直接在网页或者哪的客户端 直接 填写 代理服务器的ip或地址，所有的信息都发往这个服务器去处理，进行转发

      正向代理  指定服务器既是 代理服务器  去转发所有的  信息(当然指定了端口的)
               
                客户端 -- 指定--> 代理服务器--- internet 或者其他局域网信息都可以
                google  -------->            ---->internet---> google   
                百度    -------->            ----->internet--- 百度

      反向代理: 访问域名或者ip   代理服务器(就是上个域名解析出的ip)   把这个请求 转发到指定的服务器查看信息
                                          
	        客户端            代理服务器(www.123.com)     局域网服务器   或者  internet
		www.123.com ----->                       ---->  可以返回 www.test.com 的信息


从以上分析可以知道:正向代理 访问的域名 就是 客户端实际要访问的域名地址
                 而反向代理  访问的域名 是代理服务器的域名 然后通过url信息分配 特定网站(ip)的信息给他
		 
# 配置 正向代理上网

http https

首先 nginx只能解析 http的请求 所以客户端只能用http请求
那么客户端如果想要访问https请求怎么办
还是用http请求需求，然后在nginx服务器代理上进行https请求转发就行了

```BASH
server{    
    listen 443 default;
    resolver 114.114.114.114;
    access_log logs/2.log combined_realip;
    charset utf-8;
location /
    {
        proxy_pass https://$host$request_uri;
     }

    location ~ \.php$
    {
        include fastcgi_params;
        fastcgi_pass unix:/tmp/php-fcgi.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /data/www/test02/abc$fastcgi_script_name;
    }

}



```
以上 本来访问百度为自动跳转到https://www.baidu.com.
但是这样访问时返回不到结果的 因为 nginx不知道你访问的是什么 所以也转发不了
但是 你强制访问 http://www.baidu.com 然后经过nginx服务器 去转发返回的结果就是 https://www.baidu.com的信息
后面搜索的内容是 https的都改成http就可以访问了


若果需要 http上网和https都要上网怎么办
只能客户端手动改端口进行选择性访问

```BASH
server
{
    listen 80;
    access_log /tmp/1.log combined_realip;
    location /
    {
        resolver 114.114.114.114;
        proxy_pass http://$http_host$request_uri;
    }
}
    
server{
    listen 443 default;
    resolver 114.114.114.114;
    access_log logs/2.log combined_realip;
    charset utf-8;
    
   location /
{
        proxy_pass https://$host$request_uri;
}
    location ~ \.php$
    {
        include fastcgi_params;
        fastcgi_pass unix:/tmp/php-fcgi.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /data/www/test02/abc$fastcgi_script_name;
    }

```

* 需要在 浏览器代理的地方设置 80端口才能访问http的网站

* google浏览器 chrome://net-internals/#hsts 处 delete处删除 www.baidu.com 才能 不自动转变成https
