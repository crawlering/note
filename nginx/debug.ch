目录

介绍
配置NGINX二进制调试
配置NGINX Plus二进制
编译NGINX开源二进制
NGINX和调试符号
在NGINX配置中启用调试日志
将调试日志写入文件
将调试日志写入内存
调试所选IP的日志
每个虚拟主机调试日志
启用核心转储
配置操作系统
设置NGINX配置
从核心转储中获取回溯
从运行过程中转储NGINX配置
寻求帮助
介绍

如果出现错误，调试有助于识别程序代码中的错误。它通常用于开发或测试第三方或实验模块。

NGINX的调试功能包括调试日志和创建一个核心转储文件与进一步的回溯。

配置NGINX二进制调试

首先，您需要启用NGINX二进制调试。NGINX Plus已经为您提供了nginx-debug二进制文件，而NGINX Open Source则需要重新编译。

配置NGINX Plus二进制

从版本8开始，NGINX Plus将nginx-debug二进制文件与标准二进制文件一起发布。要在NGINX Plus中启用调试，您需要从nginx切换到nginx-debug二进制文件。打开终端并运行命令：

$ service nginx stop && service nginx-debug start
完成后，在配置文件中启用调试日志。

编译NGINX开源二进制

要在NGINX开源中启用调试，您需要使用--with-debug配置脚本中指定的标志重新编译它。

编译NGINX开源与调试支持：

下载并解压NGINX源文件，转到带有源文件的目录。请参阅下载来源。
获取NGINX配置参数的列表。运行命令：
$ nginx -V 2>&1 | grep arguments
将该--with-debug选项添加到configure命令列表中并运行configure脚本：
$ ./configure --with-debug <other configure arguments>
编译并安装NGINX：
$ sudo make
$ sudo make install
重新启动NGINX。
NGINX和调试符号

调试符号有助于获取调试的其他信息，如函数，变量，数据结构，源文件和行号信息。

默认情况下，NGINX是用包含调试符号的“ -g ”标志编译的。

但是，如果在运行回溯时遇到“无符号表信息可用”错误，则表示缺少调试符号，您将需要重新编译支持调试符号的NGINX。

编译器标志的确切集合取决于编译器。例如，对于GCC编译器系统：

包含带“ -g ”标志的 调试符号
通过使用“ -O0 ”标志禁用编译器优化，使调试器输出更易于理解：
$ ./configure --with-debug --with-cc-opt='-O0 -g' ...
在NGINX配置中启用调试日志

调试日志记录错误和任何调试相关的信息，默认情况下是禁用的。要启用它，请确保编译NGINX以支持调试（请参阅配置NGINX二进制调试），然后使用debug该error_log指令的参数在NGINX配置文件中启用它。调试日志可以写入文件，内存中分配的缓冲区，stderr输出或syslog。

建议在NGINX配置的“ 主要 ”级别上启用调试日志，以全面了解发生了什么事情。

将调试日志写入文件

将调试日志写入文件可能会降低高负载下的性能。另外请注意，该文件可能会变得非常大，并迅速吃掉磁盘空间。为了减少负面影响，可以将调试日志配置写入内存缓冲区，也可以设置特定IP地址的调试日志。有关详细信息，请参阅将调试日志写入选定IP的内存和调试日志。

要将调试日志写入文件，请执行以下操作：

确保您的NGINX配置了--with-debug配置选项。运行命令并检查输出是否包含该--with-debug行：
$ nginx -V 2>&1 | grep -- '--with-debug'
打开NGINX配置文件：
$ sudo vi /etc/nginx/nginx.conf
查找error_log默认情况下位于main上下文中的指令，并将日志记录级别更改为debug。如有必要，请将路径更改为日志文件：
error_log  /var/log/nginx/error.log debug;
保存配置并退出配置文件。
将调试日志写入内存

调试日志可以使用循环缓冲区写入内存。优点是在高负载下登录调试级别不会对性能产生重大影响。

要启用将调试日志写入内存：

确保您的NGINX配置了--with-debug配置选项。运行命令并检查输出是否包含该--with-debug行：
$ nginx -V 2>&1 | grep -- '--with-debug'
在NGINX配置文件中，error_log使用main上下文中指定的指令启用调试日志记录的内存缓冲区：
error_log memory:32m debug;
...
http {
    ...
}
从内存中提取调试日志

日志可以使用GDB调试器中执行的脚本从内存缓冲区中提取。

从内存中提取调试日志：

获取NGINX工作进程的PID：
$ ps axu |grep nginx
启动GDB调试器：
$ sudo gdb -p <nginx PID obtained at the previous step>
复制脚本，粘贴到GDB，然后按“Enter”。该脚本将把日志保存在当前目录下的debug_log.txt文件中：
set $log = ngx_cycle->log

while $log->writer != ngx_log_memory_writer
    set $log = $log->next
end

set $buf = (ngx_log_memory_buf_t *) $log->wdata
dump binary memory debug_log.txt $buf->start $buf->end
按CTRL + D退出GDB。
打开位于当前目录中的文件“ debug_log.txt ”：
$ sudo less debug_log.txt
所选IP的调试日志

可以为特定的IP地址或一系列IP地址启用调试日志。记录特定IP在生产环境中可能有用，因为它不会对性能产生负面影响。IP地址debug_connection在events块内的指令中指定; 该指令可以被定义不止一次：

error_log /path/to/log;
...
events {
    debug_connection 192.168.1.1;
    debug_connection 192.168.10.0/24;
}
每个虚拟主机的调试日志

一般来说，error_log指令是在main上下文中指定的，因此适用于包括server和的所有其他上下文location。但是，如果error_log在特定块server或location块中指定了另一个指令，全局设置将被覆盖，此error_log指令将自行设置日志文件的路径和日志级别。

要为特定虚拟主机设置调试日志，请在error_log特定server块内添加指令，在该块中设置日志文件的新路径和debug日志记录级别：

error_log /path1/to/log debug;
...
http {
    ...
    server {
    error_log /path2/to/log debug;
    ...
    }
}
要禁用每个特定虚拟主机的调试日志，请error_log在特定server块内指定指令，并仅指定日志文件的路径：

error_log /path/to/log debug;
...
http {
    ...
    server {
    error_log /path/to/log;
    ...
    }
}
启用核心转储

核心转储文件有助于识别和修复导致NGINX崩溃的问题。请注意，核心转储文件可能包含密码和私钥等敏感信息，因此请确保以安全的方式对其进行处理。

核心转储可以通过两种不同的方式启用：

在操作系统中
在NGINX配置文件中
在操作系统中启用核心转储

在您的操作系统中执行以下步骤：

指定保存核心转储文件的工作目录，例如“ / tmp / cores ”：
$ mkdir /tmp/cores
确保目录可以被NGINX工作进程写入：
$ sudo chown root:root /tmp/cores
$ sudo chmod 1777 /tmp/cores
禁用核心转储文件最大大小的限制：
$ ulimit -c unlimited
如果操作以“无法修改限制：操作不允许”结束，请运行命令：

$ sudo sh -c "ulimit -c unlimited && exec su $LOGNAME"
为setuid和setgid进程启用核心转储。
对于CentOS 7.0，Debian 8.2，Ubuntu 14.04，运行命令：

$ echo "/tmp/cores/core.%e.%p" | sudo tee /proc/sys/kernel/core_pattern
$ sudo sysctl -w fs.suid_dumpable=2
$ sysctl -p
对于FreeBSD，运行命令：

$ sudo sysctl kern.sugid_coredump=1
$ sudo sysctl kern.corefile=/tmp/cores/%N.core.%P
在NGINX配置中启用核心转储

如果您已经在操作系统中配置了核心转储文件的创建，请跳过这些步骤。

在NGINX配置文件中启用核心转储：

打开NGINX配置文件：
$ sudo vi  /usr/local/etc/nginx/nginx.conf
定义一个将保存working_directory指令的核心转储文件的目录。该指令在主配置级别上指定：
working_directory /tmp/cores/;
确保该目录存在并可由NGINX工作进程写入。打开终端并运行命令：
$ sudo chown root:root /tmp/cores
$ sudo chmod 1777 /tmp/cores
使用worker_rlimit_core指令指定核心转储文件的最大可能大小。该指令也在main配置级别上指定。如果核心转储文件大小超过该值，则不会创建核心转储文件。
worker_rlimit_core 500M;
例：

worker_processes   auto;
error_log          /var/log/nginx/error.log debug;
working_directory  /tmp/cores/;
worker_rlimit_core 500M;

events {
    ...
}

http {
    ...
}
使用这些设置，将在“ / tmp / cores / ”目录中创建一个核心转储文件，并且只有其大小不超过500兆字节。

从核心转储文件中获取回溯

Backtraces从核心转储文件提供程序崩溃时出现错误的信息。

从核心转储文件获取回溯：

使用以下模式使用GDB调试器打开核心转储文件：
$ sudo gdb <nginx_executable_path> <coredump_file_path>
键入“ backtrace命令从崩溃时间获取堆栈跟踪：
(gdb) backtrace
如果“ backtrace ”命令带有“无符号表信息可用”消息，则需要重新编译NGINX二进制文件以包含调试符号。请参阅NGINX和调试符号。

从运行过程中转储NGINX配置

您可以从内存中的主进程中提取当前的NGINX配置。当您需要时，这可能是有用的：

验证哪个配置已经被加载
如果磁盘上的版本被意外删除或覆盖，则恢复以前的配置
只要您的NGINX有调试支持，配置转储就可以用GDB脚本获得。

确保你的NGINX是用调试支持（--with-debug配置参数列表中的配置选项）构建的。运行命令并检查输出是否包含该--with-debug行：
$  nginx -V 2>&1 | grep -- '--with-debug'
获取NGINX工作进程的PID：
$ ps axu | grep nginx
启动GDB调试器：
$ sudo gdb -p <nginx PID obtained at the previous step>
复制并粘贴脚本到GDB，然后按“Enter”。该脚本将把配置保存在当前目录的nginx_conf.txt文件中：
set $cd = ngx_cycle->config_dump
set $nelts = $cd.nelts
set $elts = (ngx_conf_dump_t*)($cd.elts)

while ($nelts-- > 0) 

set $name = $elts[$nelts]->name.data
printf "Dumping %s to nginx_conf.txt\n", $name
append memory nginx_conf.txt \
      $elts[$nelts]->buffer.start $elts[$nelts]->buffer.end
end
按CTRL + D退出GDB 。
打开位于当前目录中的文件nginx_conf.txt：
$ sudo vi nginx.conf.txt
寻求帮助

在寻求调试帮助时，请提供以下信息：

NGINX版本，编译器版本和配置参数。运行命令：
$ nginx -V
目前完整的NGINX配置。请参阅在运行过程中转储NGINX配置
调试日志。请参阅在NGINX配置中启用调试日志
获得的回溯。请参阅启用核心转储，获取回溯
也可以看看

使用新的调试功能来探究NGINX内部
使用调试服务器捕获5xx错误
记录和监视
