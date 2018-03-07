#URL 和 URI 区别

URL 是 URI的子集，
URL： uniform resource locator URL
URI:  uniform resource identifier URI


网上解释://www.zhihu.com/question/21950864/answer/66779836

    URI 是统一**资源标识符**，而 URL 是统一**资源定位符**。
因此，笼统地说，每个 URL 都是 URI，但不一定每个 URI 都是 URL。
    这是因为 URI 还包括一个子类，即统一资源名称 (URN)，它命名资源但不指定如何定位资源。
上面的 mailto、news 和 isbn URI 都是 URN 的示例。 URI 和 URL 概念上的不同反映在此类和 URL 类的不同中。
     此类的实例代表由 RFC 2396 定义的语法意义上的一个 URI 引用。URI 可以是绝对的，也可以是相对的。
对 URI 字符串按照一般语法进行解析，不考虑它所指定的方案（如果有）不对主机（如果有）执行查找，
也不构造依赖于方案的流处理程序。相等性、哈希计算以及比较都严格地根据实例的字符内容进行定义。
换句话说，一个 URI 实例和一个支持语法意义上的、依赖于方案的比较、规范化、解析和相对化计算的结构化字符串差不多。
 作为对照，URL 类的实例代表了 URL 的语法组成部分以及访问它描述的资源所需的信息。URL 必须是绝对的，
即它必须始终指定一个方案。URL 字符串按照其方案进行解析。通常会为 URL 建立一个流处理程序，
实际上无法为未提供处理程序的方案创建一个 URL 实例。相等性和哈希计算依赖于方案和主机的 Internet 地址（如果有）；
没有定义比较。换句话说，URL 是一个结构化字符串，它支持解析的语法运算以及查找主机和打开到指定资源的连接之类的网络 I/O 操作。


# man 查看函数帮助

yum -y install man-pages 
man pthread_join #函数帮助

# man 怎么把源码安装的软件的man帮助信息安装到 系统的man里

* 以nginx为例 查看man/nginx.8 把此文件拷贝到 /usr/share/man/man8/ 中
* 然后执行 mandb 进行man 条目的更新 
* 然后man nginx 就可以查看的到


# top ps

* top -Hp pid #查看进程的线程运行情况
* ps -Lfp #同上相似


# vimgrep

* vimgrep /匹配模式/[g][j] 要搜索的文件/范围 
* g：表示是否把每一行的多个匹配结果都加入
* j：表示是否搜索完后定位到第一个匹配位置
* vimgrep /pattern/ %           在当前打开文件中查找
* vimgrep /pattern/ *             在当前目录下查找所有
* vimgrep /pattern/ **            在当前目录及子目录下查找所有
* vimgrep /pattern/ *.c          查找当前目录下所有.c文件
* vimgrep /pattern/ **/*         只查找子目录 #**
* cn                                          查找下一个
* cp                                          查找上一个
* copen                                    打开quickfix
* cw                                          打开quickfix
* cclose                                   关闭qucikfix
* help vimgrep                       查看vimgrep帮助

# route 


Destination	目标网段或者主机
Gateway	网关地址，”*” 表示目标是本主机所属的网络，不需要路由
Genmask	网络掩码
Flags	标记。一些可能的标记如下：
 	U — 路由是活动的
 	H — 目标是一个主机
 	G — 路由指向网关
 	R — 恢复动态路由产生的表项
 	D — 由路由的后台程序动态地安装
 	M — 由路由的后台程序修改
 	! — 拒绝路由
Metric	路由距离，到达指定网络所需的中转数（ **linux 内核中没有使用** ）
Ref	路由项引用次数（linux 内核中没有使用）
Use	此路由项被路由软件查找的次数
Iface	该路由表项对应的输出接口

route add default gw 192.168.0.1 netmask 0.0.0.0 dev ens33 #添加默认网关 如果添加失败则 service NetworkManager stop 停止NetworkManager
route add -host 192.168.0.2  dev ens33 #添加目的地址是一个主机 netmask会变成255.255.255.255
route add -net 192.168.31.0 netmask 255.255.255.0 dev ens33 #添加母的主机是一个网络
route add -host 192.168.31.2 gw 192.168.31.1 dev ens33 # 目的主机192.168.31.2 走 192.168.31.1

 # vim 插入 shell命令返回的结果

 vim中插入命令行的输出结果:

 *  :r！command ， command命令的结果插入光标下一行
 * :nr! command,  command命令的结果插入n行后。


# vim 多窗口实现同步滚动

* 两个窗口都设置: :set scrollbind
* 取消同步滚动: :set noscrollbind


# 反向代理和代理的理解

* 反向代理 多个叫负载均衡，客户端是直接去访问反向代理服务器 反向代理服务器告诉客户端你应该去访问另外个服务器(A或者B服务器
* 代理 客户端通过访问 代理服务器 ，代理服务器再去访问另 一个 服务器的网页后者其他服务，然后结果返回给代理服务器，
  代理服务其在给客户端，是一个间接访问

 
# sudo 设置不需要终端可以执行sudo命令

Defaults:zabbix !requiretty
* 让zabbix 用户无需登录tty就可以执行sudo命令


# vim 插入命令行输出结果

:r ! command  #将结果插入到光标下一行
:nr ! command #将命令的结果插入n行后
:m,n ! command #在 m,n行之间插入

# 命令深度补全

* yum -y install bash-completion
* 退出重进终端就可以了

# vim markdown

* zo 展开代码折叠
* zc 折叠

# mount 挂载 windows

* mount -t cifs -o username=share,password=123456 //192.168.31.95/nba /mnt/share


# vmware -cl1-000001.vmdk' or one of the snapshot disks it depends on

* 原因是异常关机，找到虚拟机文件 删除.lck 文件就可以了


# scp 命令传输文件

* scp 传输文件基于ssh登录
* scp src_add des_add //源地址为 远端IP则此命令为 从远程拷贝，目的地址为远端IP 则此命令为推送到远端
* scp root@192.168.31.20:/usr/src/test.txt /usr/src/local/test.txt //此命令为拷贝


# 删除带横线开头的文件

* rm -- -r //删除-r文件
