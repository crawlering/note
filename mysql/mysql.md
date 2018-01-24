# mysql

##mysql 更改密码

* mysqladmin 执行出现 mysql.sock找不到则 增加

    ```bash    
    [mysqladmin] 
    socket=/tmp/mysql.sock
    ```

* 第一次设置密码：mysqladmin -uroot password "123456"
* 更改密码:mysqladmin -uroot -p123456 password 123456abc
* 忘记密码修改配置文件进行密码修改: [mysqld]中增加 skip-grant #意思是忽略授权
* use mysql
  update user set password=password("123456") where user="root";

##mysql 错误

* mysql -uroot #登入出现错误

    ```BASH
    ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)
    ```
    vim /etc/my.cnf  #添加
    
    ```bash
    [mysql]
    socket=/tmp/mysql.sock  #mysqld 服务器定的 sock位置
    ```

* /etc/init.d/mysqld start #启动mysql出现错误"Starting MySQL..The server quit without updating PID file ([失败]ysql.pid)."

    ```BASH
    是my.cnf 中 datadir=/data/mysql 
    没有 data数据参数 ll /data/mysql;-> 
    "auto.cnf  ibdata1  ib_logfile0  ib_logfile1  mysql  performance_schema  test"
    如果没有可以 ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
    去生成data文件
    ```

* mysql -uroot -h192.168.31.20 -P3306 -p #本机乃至远程主机访问数据库显示错误
    "ERROR 1130 (HY000): Host '192.168.31.21' is not allowed to connect to this MySQL server"
    原因:是用户root没有开通远程访问，只开同了本机访问，127.0.0.1 是可以访问的
    解决: 
    1、创建test用户:
    GRANT ALL PRIVILEGES ON *.* TO test@localhost IDENTIFIED BY 'test' WITH GRANT OPTION; #开通主机访问
    GRANT ALL PRIVILEGES ON *.* TO test@"%" IDENTIFIED BY 'test' WITH GRANT OPTION; #带"%"为开通远程访问
   2、可能还需要开通 iptables 3306

