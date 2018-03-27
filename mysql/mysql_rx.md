# mysql 读写分离

知识点:

缓解***X锁，S锁争用*

作用:无非就是缓解主服务器性能压力，把读的请求分摊到从服务器
使用场景:当读取操作较多的时候

原因:当性能达到瓶颈的时候，select 很多的时候，update delete操作会被select 操作阻塞，而当有较多
 insert update delete 操作的时候会影响 读的操作

用法:
1、从代码方向实现
在代码中通过 insert 或者 select操作进行分类
2、通过中间代理来实现
mysql-proxy /Amoeba for mysql :代理服务器进行接收请求然后进行转发到后端数据库，可以进行负载均衡处理


# 下载安装jdk

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

# 

# 安装 Mycat


# 配置Mycat 读写分离

<dataHost name="localhost1" maxCon="1000" minCon="10" balance="1" writeType="0" dbType="mysql" dbDriver="native"> 
<heartbeat>select user()</heartbeat>
 <!-- can have multi write hosts --> 
<writeHost host="hostM1" url="localhost:3306" user="root" password="123456"> 
<!-- can have multi read hosts --> 
<readHost host="hostS1" url="localhost2:3306" user="root" password="123456" weight="1" /> 
</writeHost> 
</dataHost>

8066 9066

show @@heartbeat;
