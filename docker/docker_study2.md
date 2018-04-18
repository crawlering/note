# docker

编排工具:
Kubernetes Swarm
文件构建:
Docker compose


# docker swarm

参考网站:http://dockone.io/article/662

一台主机安装docker 那么这台主机就称作 一个 docker Engine，而 docker Engine里可以创建多个容器
而swarm 其实也可以看作是一个 docker Engine，只是这个docker Engine 具有管理其他 docker Engine的
作用

* swarm 提供两种对外API :
  一种用于负责容器的管理，叫做 DOCKER API，
  >Discovery Service 服务发现模块，这个模块主要用来提供节点发现功能
  >而各个docker Engine 通过Swarm Agent 和 swarm 的 Discovery Service 通信
  >每个主机就是一个docker Engine，称作1个node，一个node下可以有多个docker container
 
 一种供swarm集群使用 CLI
  > Swarm对集群进行了抽象，抽象出了Cluster API，Swarm支持两种集群，一种是Swarm自身的集群，另外一种基于Mesos的集群

* swarm本身可以实现高可用 通过LeaderShip 模块，通过主备方式实现

* swarm 有一个scheduler 调度模块
 
  调度模块主要用户容器创建时，选择一个最优节点。在选择最优节点过程中，分为了两个阶段： 
第一个阶段，是过滤。根据条件过滤出符合要求的节点，过滤器有以下5种：
  1、Constraints，约束过滤器，可以根据当前操作系统类型、内核版本、存储类型等条件进行过滤，当然也可以自定义约束，在启动Daemon的时候，通过Label来指定当前主机所具有的特点。
  2、Affnity，亲和性过滤器，支持容器亲和性和镜像亲和性，比如一个web应用，我想将DB容器和Web容器放在一起，就可以通过这个过滤器来实现。
  3、Dependency，依赖过滤器。如果在创建容器的时候使用了--volume-from/--link/--net某个容器，则创建的容器会和依赖的容器在同一个节点上。
  4、Health filter，会根据节点状态进行过滤，会去除故障节点。
  5、Ports filter，会根据端口的使用情况过滤。

  调度的第二个阶段是根据策略选择一个最优节点。有以下三种策略：
  1、Binpack，在同等条件下，选择资源使用最多的节点，通过这一个策略，可以将容器聚集起来。
  2、Spread，在同等条件下，选择资源使用最少的节点，通过这一个策略，可以将容器均匀分布在每一个节点上。
  3、Random，随机选择一个节点。


# docker 三剑客

swarm 、machine、 docker compose	

docker compose -> swarm -> machine

使用machine在不同平台下创建docker engine，然后通过swarm 进行 管理所有的 docker engine，然后使用 docker compose进行
编排应用
用户通过yml文件描述由多个容器组成的应用，然后由Compose解析yml，调用Docker API，在Swarm集群上创建出对应的容器。

# 网络

内置跨主机的网络通信: Macvlan、Pipework、Flannel、Weave

# docker 名词介绍

docker images: 镜像 用于创建容器的模版
docker container: 容器 独立运行的一个或一组应用
docker host: 一个物理或者虚拟的机器用于执行 Docker 守护进程和容器
docker registry: docker 仓库 分为本地仓库和远程仓库(Docker Hub(https://hub.docker.com) 提供了庞大的镜像集合供使用)
docker machine: 在不同平台创建docker的一个工具
docker Engine: 是一个C/S 模型的应用
  包括:
  1、一个长时间运行的守护进程的 服务 server
  2、指定程序和守护进程通信，并指示他去做什么操作的 REST API接口
  3、一个命令行客户端接口(CLI)

  CLI 通过脚本和CLI 命令 使用 docker REST API 去控制和影响 守护进程，
  这个守护进程 创建和管理 docker 对象，如 镜像 容器 网络 和卷组

docker 特点:
* Responsive deployment and scaling: 响应部署和缩放
  Docker的基于容器的平台允许高度可移植的工作负载。Docker容器可以在开发人员的本地笔记本电脑上，数据中心的物理或虚拟机上，云提供程序上或混合环境中运行。
  Docker的可移植性和轻量级特性也使得动态管理工作负载变得非常容易，几乎实时地按业务需求扩展或拆分应用程序和服务。

* 在同一个硬件上运行更多的工作负载,Docker轻量且快速


## docker architecture 

docker架构:

* docker daemon
* docker client
* docker registers: docker 仓库
* docker objects
  images
  containers
  networks
  volumes
  plugins
* services
  通过服务，您可以跨多个Docker守护进程扩展容器，这些守护进程可以作为一个群组与多个管理人员和工作人员一起工作。swarm中的每个成员都是Docker守护进程，守护进程都使用Docker API进行通信。服务允许您定义所需的状态，例如在任何给定时间必须可用的服务的副本数量。默认情况下，该服务在所有工作节点之间进行负载平衡。对于消费者来说，Docker服务似乎是一个单一的应用程序。Docker引擎在Docker 1.12及更高版本中支持swarm模式。

underlying technology:底层技术
* namespaces:命名空间
  Docker使用一种叫做namespaces提供称为容器的独立工作空间的技术。当你运行一个容器时，
  Docker会为该容器创建一组 命名空间。
  Docker Engine uses namespaces such as the following on Linux:

  The pid namespace: Process isolation (PID: Process ID).
  The net namespace: Managing network interfaces (NET: Networking).
  The ipc namespace: Managing access to IPC resources (IPC: InterProcess Communication).
  The mnt namespace: Managing filesystem mount points (MNT: Mount).
  The uts namespace: Isolating kernel and version identifiers. (UTS: Unix Timesharing System).

* control groups:控制组
  Linux上的Docker Engine也依赖于另一种称为控制组 （cgroups）的技术。
  cgroup将应用程序限制为一组特定的资源。控制组允许Docker引擎将可用硬件资源共享给容器，
  并可选地强制实施限制和约束。例如，您可以限制可用于特定容器的内存。

* Union file systems: 联合文件系统
  联合文件系统或UnionFS是通过创建图层进行操作的文件系统，使它们非常轻巧和快速。
  Docker引擎使用UnionFS为容器提供构建块。Docker引擎可以使用多种UnionFS变体，包括AUFS，btrfs，vfs和DeviceMapper。

* Container format:容器格式
  Docker引擎将名称空间，控制组和UnionFS组合成一个名为容器格式的包装器。
  默认的容器格式是libcontainer。将来，Docker可以通过与诸如BSD Jails或Solaris Zones等技术集成来支持其他容器格式。
  


# docker 使用

由于看网上的docker 使用要不就是比较老的，要不就是一下看不懂的，没办法只能拿官网的看下了

## 安装 docker 启动docker 服务

* 首先安装  选择CE 社区版 相应平台 centos7.0，三种安装方式:
  1、使用yum 更新yum源安装
    yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
    yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo
    yum-config-manager --enable docker-ce-edge
    yum-config-manager --enable docker-ce-test // 关闭yum-config-manager --disable docker-ce-edge
    yum install docker-ce //安装最新的docker 
                          // yum list docker-ce --showduplicates | sort -r 列出docker版本最新->老的排序
                          //查看后安装指定的版本yum install <FULLY-QUALIFIED-PACKAGE-NAME>
                          //包名加上版本的第一个连接符
   比如:docker-ce.x86_64         18.04.0.ce-2.1.rc1.el7.centos          docker-ce-test
   yum install docker-ce-18.04.0.ce //第一个"-"前的
 2、或者下载 docker的.rpm包 yum install /path/to/package.rpm 使用yum安装指定包
 3、还有一种使用curl 方便模式安装:
    curl -fsSL get.docker.com -o get-docker.sh; sudo sh get-docker.sh

* 启动docker服务: systemctl start docker

## 使用docker container




