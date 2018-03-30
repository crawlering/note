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


