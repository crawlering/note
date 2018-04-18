# docker

docker use port:

2377: docker swarm init,docker swarm join 创建集群或者加入集群时用的到的端口(manage主机端口用到) 集群管理端口
2376: docker-machine ls 创建虚拟机的时候用到的 docker 守护进程端口
7946: 传输数据 udp/tcp 用于控制平面的端口
4789： UDP 端口 用于传输VXLAN网络数据的端口 用户网络分配 
映射端口: 用户端口映射

docker-machine: 创建各个主机的虚拟机 在manage 主机(任意一个主机)上，方便部署 
                可以使用 docker-machine env myvm1
		或者 docker-machine ssh myvm1 "docker command"
docker swarm: 集群管理 创建集群node 加入集群 移除集群
docker stack: 创建集群应用 移除集群应用 docker stack deploy -c docker-compose.yml getstartedlab
docker compose:   docker-compose.yml 编排应用	
docker service:  redis web等
docker node:

Dockerfile: docker built -t friendhello .  //用 Dockerfile 创建image 

项目过程，使用

编写 Dockerfile， 创建出 image
上传 image 到 仓库 私有库，docker hub
docker-machine 创建 虚拟机
在操作主机上 swarm初始化 创建 swarm 集群的 manage
在操作主机上使用docker-machine 去操作虚拟主机(间接操作其他主机node) 创建 worker节点，加入到swarm集群
创建完成后 使用 docker stack 对各个节点 进行 用用部署
部署完成后 进行 curl 测试

问题点:

1、swarm 和swarm的群集 ?
2、node点挂了后，其中的container 会自动在其他 node上重新部署，等node重新上线后，不会恢复?
3、


# docker 

有关集群的docker命令如下：

docker swarm：集群管理，子命令有init, join,join-token, leave, update
docker node：节点管理，子命令有demote, inspect,ls, promote, rm, ps, update
docker service：服务管理，子命令有create, inspect, ps, ls ,rm , scale, update
docker stack/deploy：试验特性，用于多应用部署



# docker volume

* docker run -it -v /test:soft centos /bin/bash //启动的时候挂载
* docker run -it -h NEWCONTAINER --volumes-from container-test debian /bin/bash //数据共享
