# docker



* 镜像，一个只读模版，通过镜像来完成各种应用的部署
* 容器，镜像类似操作系统，而容器类似于虚拟机本身，可以被启动，开始，停止，删除，每个容器相互隔离
* 仓库，存放镜像的一个产所，最大公开仓库是 Docker hub，国内公开仓库 dockerpool.com

功能: 可以把特定的服务打包在一个容器内 导出一个可以被利用的 镜像 下次相同环境就不需要重启配置，
      所以容器的作用可以用来快速部署环境。

## 镜像管理

* docker pull ubuntu //下载ubuntu 镜像
* vi /etc/docker/daemon.json 可以加速 去阿里云申请加速器
 vi /etc/docker/daemon.json//加入如下内容
 {
   "registry-mirrors": ["https://dhq9bx4f.mirror.aliyuncs.com"]
   }


* docker images // 查看本地下载的 镜像
* docker search xxx //搜索镜像
* docker tag centos xxx //给镜像打标签 相当于别名
  docker tag centos xxx:yyy //yyy修改的是TAG

* docker run -itd centos bash//把镜像启动为容器 -i 表示让容器标准输入打开，-t 表示分配一个伪终端 -d 表示后台启动，要把 -i -t -d放到
  镜像名字前面
  并且 docker run -tid centos 可以多次运行同一个镜像，就像虚拟机开了多个 虚拟主机，每次配置的环境是一次性的需要保存才行

* docker ps //查看运行的容器，加上-a 可以查看所有容器，包括未运行的
* docker rmi centos //用来删除指定的镜像 其中后面的参数是tag，删除的是该tag 当后面参数为镜像id时，会彻底删除整个镜像，所有标签
  一同删除，删除的时候有容器存在则返回失败，强制删除需要加 -f
* docker exec -it CONTAINER_ID bash # 进入终端
*docker ps -a 可以查看所有运行和未运行的容器，镜像和容器意思是不一样的，当用户使用镜像开启容器后，此容器就脱离了容器独自成为一个
运行的应用，一个镜像可以被多次运行，同一个镜像可以启动很多个容器，每个容器有一个CONTAINER ID是其独自拥有的*

* docker rm CONNTAINER_ID //删除 容器 删除的时候需要stop 容器，如果不stop 需要加-f强制删除


### docker 容器创建镜像 

*创建镜像后可以被其他主机使用，相当于是打包环境*

方法1:
* docker commit -m "install test" -a "xujb" CONTAINER_ID test_system //生成了新的镜像
* docker save -o test_system.tar test_system //把镜像打包可以传输到另外台主机
* docker load -i test_system.tar 或者 deocker load *<* test_system.tar //在同一台主机相当于恢复可以使用此命令 此处"**"是强调作用
* docker import test_system.tar test_system1 //可以在不同主机

方法2:
* docker export -o test2.tar CONTAINTER_ID //不生成新的镜像文件，直接打包
* 到其他主机 导入和上述方法相同


### docker 仓库 管理

* docker pull registry //下载registry 镜像，registry docker官方提供的镜像，作用是可以用来创建本地的 docker私有库
* docker run -d -p 5000:5000 docker.io/registry 
  //以registry镜像启动容器，-p会把容器的端口映射到宿主机上，:左边为宿主机监听端口，:右边为容器监听端口
* curl 127.0.0.1:5000/v2/_catalog //可以看到私有仓库镜像
* docker tag name 192.168.31.20:5000/ubuntu_test //标记tag 必须要带有私有仓库的 ip:port
* 然后编辑 vim /etc/docker/daemon.json

```BASH
{
        "registry-mirrors": ["https://dhq9bx4f.mirror.aliyuncs.com"],
	"insecure-registries":["192.168.31.20:5000","192.168.0.20:5000"]
}
```
//开放IP，修改后需要重启docker服务，记得需要再一次启动 registry容器
* docker push 192.168.31.20:5000/ubuntu_test //把镜像上传到本地仓库
* curl 127.0.0.1:5000/v2/_catalog //可以看到私有仓库镜像 
* docker pull 192.168.31.20:5000/ubuntu_test //下载本地仓库 镜像


### docker 数据管理

* docker run -tid -v /data/:/data centos bash //挂载本地目录到容器里
* docker run -tid --volumes-from old_container_name new_container_name bash //创建一个新的容器 并且使用old容器的数据卷，
  //不用重新指定 挂载/data/:/data

### docker 网络模式

* host模式: 使用 docker run --net=host 指定 //使用的网络实际上和宿主机一样，在容器内看到的网卡ip是宿主机ip
* container模式 使用 --net=container:container_id/container_name，多个容器使用共同的网络，看到的ip是一样的
* none 模式 --net=none //这种模式下，不会配置任何网络
* bridge 模式 --net=bridge //默认模式 这种模式会为每个容器分配一个独立的Network Namespace。
  //类似于vmware的nat网络模式。同一个宿主机上的所有容器会在同一个网段下，相互之间是可以通信的

### docker网络管理 外部访问

* docker run -itd -p 60000:22 tag_name bash // 把docker容器的ssh端口映射到主机60000端口

### docker 网络管理 配置桥接网络

把容器网卡桥接上主机网卡:

* git clone https://github.com/jpetazzo/pipework // 下载pipwork 工具进行 设置桥接网络
* cd /etc/sysconfig/network-script/; cp ifcfg-ens37 ifcfg-br0
* vim ifcfg-ens37 // 增加 BRIDGE=br0 删除IPADDR NETMASK GATEWAY DNS1
* vim ifcfg-br0 // 修改 TYPE=“Bridge” DEVICE=br0 NAME=br0
* systemctl restart network // 重启网络 如果报错"网桥支持不可用：未找到 brctl",安装插件:yum -y install bridge-utils，然后重启
* pipwork br0 CONTAINER_ID 192.168.0.30/24@192.168.0.1 // 0.30为容器IP，@后面的为网关
* docker exec -it CONTAINER_ID bash // ifconfig 可以查看配置网络已经生成，用其他主机ping容器IP也可以ping通


### operation not permitted

新建的容器，启动nginx或者httpd服务的时候会报错
 Failed to get D-Bus connection: Operation not permitted
 这是因为dbus-daemon没有启动，解决该问题可以这样做
 启动容器时，要加上--privileged -e "container=docker" ，并且最后面的命令改为/usr/sbin/init
 docker run -itd --privileged -e "container=docker" centos_with_nginx /usr/sbin/init

### docker dockerfile

dockerfile: 快速创建自定义Docker镜像

dockerfile有四部分组成:

* 基础镜像信息
* 维护者信息
* 镜像操作指令
* 容器启动时执行指令


#### 基础镜像信息指令

* FROM 指令

指定基于哪个基础镜像创建镜像，可以使用多个FROM 指令(每个镜像一次)
FROM centos[:latest]

#### 维护者信息指令

* MAINTAINER

指定作者信息: MAINTAINER xujb xujb@linux.com

#### 镜像操作指令

* RUN

镜像操作指令
格式为: RUN command 或者 RUN ["executable","param1","param2"]
前一个格式是在shell终端上运行，即/bin/sh -C,
后一个格式使用exec运行 // exec可以调用其他命令，如果在当前终端中使用该命令，则当指定的命令执行完成后会立即退出终端
example:
RUN yum install httpd
RUN ["/bin/bash","-c","echo hello"]


#### 容器启动时执行指令

* CMD
* ENTRYPOINT entrypoint
* EXPOSE
* ENV
* ADD
* COPY
* VOLUME
* USER
* WORKDIR
* ONBUILD


1、CMD

CMD 用来指定容器启动时用到的命令，会被RUN命令覆盖
有三种格式:
CMD command param1 param2 //在/bin/sh 上执行
CMD ["executable","param1", "param2"] //使用exec执行，推荐
CMD[”param1“,"param2"] //提供给ENTRYPOINT 做默认参数
**每个容器只能执行一条CMD命令，多个CMD命令时，只最后一条被被执行**

2、ENTRYPOINT

配置容器启动后执行的命令，不会被docker RUN命令覆盖
两种格式:

ENTRYPOINT command param1 param2 //在shell /bin/sh 上执行
ENTRYPOINT ["executable","param1","param2"] //在exec上执行
**每个容器只能执行一条ENTRYPOINT命令，多个该命令时，只最后一条被被执行**

3、EXPOSE

告诉docker服务端容器暴露的端口号，在启动docker的时候需要使用 -P或者-p来把相应的端口映射出来
-P 为所有暴露的端口号随机在主机分配映射的端口号 -p 则自定义主机上的端口号(-p 50000:22)

example:
EXPOSE 22 80 8433

4、ENV
指定后面运行指令的环境变量

格式:
ENV a 123

5、ADD

将本地的文件或者目录拷贝到容器的某个目录里
格式:
ADD src dest //src为该dockerfile的所在路径，src也可以是一个相对路径，或者URL

6、COPY

COPY 和 ADD 命令功能相同但是不支持URL

7、VOLUME

创建在本地主机提供一个给其他容器挂载的挂载点，
格式:
VOLUME ["/data"]
?是否是容器自动挂载这个挂载点，还是只是提供了一个 可以挂载的 挂载点 和 run -v有什么区别待验证

8、USER 
指定运行容器的用户或UID
当服务不需要管理员权限时，可以通过该命令指定运行用户。并且可以在之前创建所需要的用户，例如： RUN groupadd -r postgres && useradd -r -g postgres postgres 。要临时获取管理员权限可以使用 gosu ，而不推荐 sudo 。
格式:
USER daemon

9、WORKDIR

为后续的RUN CMD ENTRYPOINT 指令配置工作目录
格式为:
WORKDIR /path/to/workdir

多条该指令会重新设置，最后一条生效，但是如果后面的指令指定的是相对命令，则是会叠加 和linux cd命令切换目录原理相同

10、ONBUILD

配置当所创建的镜像作为 另外个dockerfile的基础镜像时，所执行的操作指令，本dockerfile是不执行的
格式为:
ONBUILD mirror_image

### 创建镜像

通过 docker build 创建镜像

格式为:
docker build [选项] 路径 
-t 选项 可以生成镜像的标签

命令读取指定路径下(包括子目录)的所有dockfile，并且把目录所有内容发送到服务端，有服务端创建镜像，
可以创建 .dockerignore 文件(每一行为一个匹配) 让docker忽略指定目录或者文件

docker build -t build_repo/my_images /tmp/docker_build/

### example

* wget www.apelearn.com/study_v2/.nginx_conf
* vim dockerfile 内容如下:

 ```BASH
 ## Set the base image to CentOS
 FROM centos
 # File Author / Maintainer
 MAINTAINER xujb 1193630409@qq.com
 # Install necessary tools
 RUN yum install -y pcre-devel wget net-tools gcc zlib zlib-devel make openssl-devel
 # Install Nginx
 ADD http://nginx.org/download/nginx-1.8.0.tar.gz .
 RUN tar zxvf nginx-1.8.0.tar.gz
 RUN mkdir -p /usr/local/nginx
 RUN cd nginx-1.8.0 && ./configure --prefix=/usr/local/nginx && make && make install
 RUN rm -fv /usr/local/nginx/conf/nginx.conf
 COPY .nginx_conf /usr/local/nginx/conf/nginx.conf
 # Expose ports
 EXPOSE 80
 # Set the default command to execute when creating a new container
 ENTRYPOINT /usr/local/nginx/sbin/nginx && tail -f /etc/passwd
 # 创建镜像：
 # docker build -t centos_nginx  . 
 ```

### docker compose 部署
 
 docker compose可以方便我们快捷高效地管理容器的启动、停止、重启等操作，它类似于linux下的shell脚本，基于yaml语法，在该文件里我们可以描述应用的架构，比如用什么镜像、数据卷、网络模式、监听端口等信息。我们可以在一个compose文件中定义一个多容器的应用（比如jumpserver），然后通过该compose来启动这个应用。
  安装compose方法如下
   curl -L https://github.com/docker/compose/releases/download/1.17.0-rc1/docker-compose-Linux-x86_64  > /usr/local/bin/docker-compose
    chmod 755 !$
     docker-compose version 查看版本信息
      Compose区分Version 1和Version 2（Compose 1.6.0+，Docker Engine 1.10.0+）。Version 2支持更多的指令。Version 1没有声明版本默认是"version 1"。Version 1将来会被弃用。
        
vim docker-compose.yml //内容到https://coding.net/u/aminglinux/p/yuanke_centos7/git/blob/master/25docker/docker-compose.yml 查看
 docker-compose up -d 可以启动两个容器
  docker-compose --help
   docker-compose ps/down/stop/start/rm 
    关于docker-compose语法的参考文档 http://www.web3.xin/index/article/182.html

