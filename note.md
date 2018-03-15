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

* zO
* zo 展开代码折叠
* zc 折叠最外层
* zC 对范围内的所有嵌套进行折叠


* zc 折叠，只折叠最外层的折叠
* zC 对所在范围内所有嵌套的折叠点进行折叠，包括嵌套的所有折叠.
* zo 展开折叠，只展开最外层的折叠.
* zO 对所在范围内所有嵌套的折叠点展开，包括嵌套折叠.
* [z 到当前打开的折叠的开始处。
* ]z 到当前打开的折叠的末尾处。
* zj 向下移动。到达下一个折叠的开始处。关闭的折叠也被计入。
* zk 向上移动到前一折叠的结束处。关闭的折叠也被
* zd 删除 (delete) 在光标下的折叠。仅当 ‘foldmethod’ 设为 “manual” 或 “marker” 时有效。
* zD 循环删除 (Delete) 光标下的折叠，即嵌套删除折叠。
* 仅当 ‘foldmethod’ 设为 “manual” 或 “marker” 时有效。
* zE 除去 (Eliminate) 窗口里“所有”的折叠。
* 仅当 ‘foldmethod’ 设为 “manual” 或 “marker” 时有效。
* zfap 将光标移到段落内，然后按zfap，就可以自动对整个段落添加折叠标签
*
* 假定你已经创建了若干折叠，而现在需要阅览全部文本。你可以移到每个折叠处，并键入”zo”。若要做得更快，可以用这个命令:zr
* zm
* 这将折叠更多 (M-ore)。你可以重复 “zr” 和 “zm” 来打开和关闭若干层嵌套的折叠，不然得一个一个的用zc来折叠.
*
* 如果你有一个嵌套了好几层深的折叠，你可以用这个命令把它们全部打开:
*
* zR
*
* 这将减少折叠直至一个也不剩。而用下面这个命令你可以关闭所有的折叠:
  zM

* 这将增加折叠，直至所有的折叠都关闭了。

* 你可以用 |zn| 命令快速禁止折叠功能。然后 |zN| 恢复原来的折叠。|zi| 切换于两者
   之间。


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
 
# ssh 在免密密钥登入输入命令

* ssh host -tt ifconfig //直接登入主机host 后返回ifconfig命令结果


# EOF 用法

*在shell编程中，”EOF“通常与”<<“结合使用，“<<EOF“表示后续的输入作为子命令或子shell的输入，直到遇到”EOF“，再次返回到主调shell，可将其理解为分界符（delimiter）。既然是分界符，那么形式自然不是固定的，这里可以将”EOF“可以进行自定义，但是前后的”EOF“必须成对出现且不能和shell命令冲突。其使用形式如下：*
*交互式程序(命令)<<EOF*
command1
command2
...
EOF

**需要注意的是，第一个EOF必须以重定向字符<<开始，第二个EOF必须顶格写，否则会报错**
 
# expect

* expect是一个能实现自动和交互式任务的解释器，它也能解释常见的shell语法命令
安装:yum -y install expect
* spawn命令：
  spawn command命令会fork一个子进程去执行command命令，然后在此子进程中执行后面的命令；

在ssh自动登陆脚本中，我们使用 spawn ssh user_name@ip_str，fork一个子进程执行ssh登陆命令；

* expect命令：
  expect命令是expect解释器的关键命令，它的一般用法为 expect "string",即期望获取到string字符串,可在在string字符串里使用 * 等通配符;

string与命令行返回的信息匹配后，expect会立刻向下执行脚本；

* set timeout命令：
  set timeout n命令将expect命令的等待超时时间设置为n秒，在n秒内还没有获取到其期待的命令，expect 为false,脚本会继续向下执行；

* send命令：
  send命令的一般用法为 send "string",它们会我们平常输入命令一样向命令行输入一条信息，当然不要忘了在string后面添加上 \r 表示输入回车；

* interact命令：
  interact命令很简单，执行到此命令时，脚本fork的子进程会将操作权交给用户，允许用户与当前shell进行交互；退出
  expect环境
* ssh 自动登入脚本事例:

    ```BASH
    #!/usr/bin/bash
    
    if [ "$1" == "-help" -o "$2" == "-help" ]
    then 
        echo "-help: Usage"
        echo "script host command"
        exit 0
    fi
    #echo "ok"
    #echo "$2"
    if [ -n "$2" ]
    then
    
        echo $1 $2
        /usr/bin/expect <<EOF 
        set timeout 3
        spawn ssh root@$1
        expect "*password:"
        send "1QAZ2wsx,.\r"
        expect "*#"
        send "$2 \r"
        expect "*#"
        interact
        expect eof
    EOF
        
    
    
    else
     
        echo "请输入正确的host 和 需要执行的命令！"
        echo "请输入-help 查看详细用法"
    
    fi
    
    ```

* expect




# vim 匹配删除行

* :g/^#/d  删除#号开始的行
* :g/^$/d  删除空行




# vim 目录树 nerd tree

* curl  -o nerdtree.zip https://www.vim.org/scripts/download_script.php?src_id=23731
* unzip nerdtree.zip -d ~/.vim/

    安装好后，命令行中输入vim，打开vim后，在vim中输入:NERDTree，你就可以看到NERDTree的效果了。
     为了方便起见，我们设置一下快捷键，在~/.vimrc 文件中添加下面内容

* " NERDTree
* map <F10> :NERDTreeToggle<CR>

 插件快捷键
       【普通模式（normal mode）】
       ▶ 文件节点映射（File node mappings）
       • 左键双击 or 回车 or o : 打开指定文件。
       • go                              : 打开指定文件，将光标留在目录树中。
       • t                                 : 在新标签中打开文件。
       • T                                : 在新标签中打开文件，保持鼠标焦点留在当前标签。
       • 鼠标中键 or i              : 在水平分屏窗口中打开指定文件。
       • gi                               : 在水平分屏窗口中打开指定文件，将光标留在目录树中。
       • s                                : 在垂直分屏窗口中打开指定文件。
       • gs                              : 在垂直分屏窗口中打开指定文件，将光标留在目录树中。
 
       ▶ 目录节点映射（Directory node mappings）
       • 左键双击 or 回车 or o : 打开指定目录。
       • O                                : 递归打开指定目录。
       • x                                 : 关闭当前节点的父节点。
       • X                                : 递归关闭当前节点的所有子节点。
       • 鼠标中键 or e              : 浏览指定目录。
 
       ▶ 书签表映射（Bookmark table mappings）
       • 左键双击 or 回车 or o : 打开指定书签。
       • t                                 : 在新标签中打开书签。
       • T                                : 在新标签中打开书签，保持鼠标焦点留在当前标签。
       • D                                : 删除指定书签。
       ▶ 树形导航映射（Tree navigation mappings）
       • p                                : 跳转到根节点。
       • P                                : 跳转到当前节点的父节点。
       • K                                : 跳转到当前目录的第一个子节点。
       • J                                 : 跳转到当前目录的最后一个子节点。
       • Ctrl + K                     : 跳转到当前节点的上一个兄弟节点。
       • Ctrl + J                      : 跳转到当前节点的下一个兄弟节点。
       ▶ 文件系统映射（Filesystem mappings）
       • C                                : 将当前选择的目录做为树形目录的根节点，即切换当前根目录节点为选择的目录节点。
       • u                                : 将当前视图中的树根节点上移一层目录，即拿当前树根目录的父目录做为新的根目录。
       • U                                : 将当前视图中的树根节点上移一层目录，即拿当前树根目录的父目录做为新的根目录，并且保持原树目录状态不变。
       • r                                 : 递归刷新当前目录。
       • R                                : 递归刷新当前节点。
       • m                               :  显示菜单。
       • cd                              : 将CWD切换到当前选择节点的目录。
       ▶ 树形过滤器映射（Tree filtering mappings）
       • I                                 : 是否显示隐藏文件开关。
       • f                                 : 是否启用文件过滤器开关。
       • F                                 : 是否显示文件开关。
       • B                                : 是否显示书签表的开关。
       ▶ 树形过滤器映射（Tree filtering mappings）
       • q                                 : 关闭树形目录树窗口。
       • A                                 : 缩放树形目录树窗口。
       • ?                                  : 显示帮助文档的开关。
• 常用配置选项
" 打开鼠标更改窗口宽度功能
set mouse=a



# 命令审计

* 编辑添加以下内容:/etc/profile

```BASH
if [ ! -d  /usr/local/records/${LOGNAME} ]
then
mkdir -p /usr/local/records/${LOGNAME}
chmod 300 /usr/local/records/${LOGNAME}
fi
export HISTORY_FILE="/usr/local/records/${LOGNAME}/bash_history"export PROMPT_COMMAND='{ date "+%Y-%m-%d %T ##### $(who am i |awk "{print \$1\" \"\$2\" \"\$5}") #### $(history 1 | { read x cmd; echo "$cmd"; })"; } >>$HISTORY_FILE'
readonly PROMPT_COMMAND
```

* readonly PROMPT_COMMAND:把变量变成只读变量，防止用户 在命令端对PROMPT_COMMAND赋值，导致命令保存失效
