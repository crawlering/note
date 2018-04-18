# docker container 基本命令

* 查看docker版本:
  docker --version/version/info
* 运行dokcer镜像:
  dokcer run hello-world

* 列出下载好的镜像:
  docker image list
* 列出docker 容器:
  列出正在运行的容器: docker container ls 
  列出所有的容器: docker container ls --all
                : dokcer container ls -aq //只显示container ID


# container

* 创建一个dockerfile
* 根据dockerfile生成一个可用的镜像
* 运行镜像 生成容器
* 分享 镜像文件 //注册docker hub id(需要能访问google)

定义一个容器 dockerfile

vim Dockerfile

```bash
# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
```

* vim  requirements.txt

```bash
Flask
Redis
```

* vim app.py

```bash
from flask import Flask
from redis import Redis, RedisError
import os
import socket

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```

* 构建应用程序:
  docker built -t friendhello . // 在根目录下运行

* docker run -p 60001:80 friendlyhello //阿里云下需要 在安全组打开 60001 端口

* 测试访问web 60001端口: curl ip:60001

* docker ps //查看正在运行的容器 
  docker container stop container-ID //停止运行 某个容器
		
**以上根据 dockerfile 创建了一个 image(镜像)**

现在把该镜像上传到docker 公共仓库

* 登入docker hub: docker login 
* 把镜像tag更改，因为是按照tag进行上传
  docker tag image username/repository:tag
  docker tag friendhello xujb/friendhello:part1 //原来的镜像(tag)还存在，相当于创建了个软连接
  //把friendhello 

* 然后可以在任何一台主机上运行:
  docker run -p 60001:80 xujb/friendhello:part1 //会自动下载xujb/friendhello:part1 到本机然后运行


此章用到的命令总结:
docker build -t friendlyhello .  # Create image using this directory's Dockerfile
docker run -p 4000:80 friendlyhello  # Run "friendlyname" mapping port 4000 to 80
docker run -d -p 4000:80 friendlyhello         # Same thing, but in detached mode 后台运行
docker container ls                                # List all running containers
docker container ls -a             # List all containers, even those not running
docker container stop <hash>           # Gracefully stop the specified container
docker container kill <hash>         # Force shutdown of the specified container
docker container rm <hash>        # Remove specified container from this machine
docker container rm $(docker container ls -a -q)         # Remove all containers
docker image ls -a                             # List all images on this machine
docker image rm <image id>            # Remove specified image from this machine
docker image rm $(docker image ls -a -q)   # Remove all images from this machine
docker login             # Log in this CLI session using your Docker credentials
docker tag <image> username/repository:tag  # Tag <image> for upload to registry
docker push username/repository:tag            # Upload tagged image to registry
docker run username/repository:tag                   # Run image from a registry

# services

docker-compose是一个 YAML 文件，定义了 docker 容器在生产中的行为方式

* vim docker-compose.yml

```BASH
version: "3"
services:
  web:
    # replace username/repo:tag with your name and image details
    image: xujb/friendhello:part1
    deploy:
      replicas: 5
      resources:
        limits:
          cpus: "0.1"
          memory: 50M
      restart_policy:
        condition: on-failure
    ports:
      - "60001:80"
    networks:
      - webnet
networks:
  webnet:
```

拉取刚刚上传的 镜像文件
运行该图像的5个实例作为所调用的服务web，限制每个实例使用最多10％的CPU（跨所有核心）和50MB的RAM。
如果一个失败，立即重启容器。
将主机上的端口80映射到web端口80。
web通过称为负载平衡的网络指示容器共享端口80 webnet。（在内部，容器自身发布到 web的端口80在一个短暂的端口）。
webnet使用默认设置定义网络（这是一个负载平衡覆盖网络）。

运行新的负载平衡应用程序:

* 初始化SWARM：docker swarm init 
* docker stack deploy -c docker-compose.yml getstartedlab//应用名称被设置为 getstartedlab
* docker service ls [-q]//获取服务的服务ID 


```bash
ID                  NAME                MODE                REPLICAS            IMAGE                    PORTS
x1d8d4h4n6mz        getstartedlab_web   replicated          6/6                 xujb/friendhello:part1   *:60001->80/tcp
```


* 列出服务的任务: 
  docker service ps getstartedlab_web
  docker container ls [-q] //只列出系统中的所有容器，但也不会显示服务过滤的任务，任务也会显示出来
* 结果输出

```bash
ID                  NAME                  IMAGE                    NODE                      DESIRED STATE       CURRENT STATE     ERROR               PORTS
tpfpwzd2j48u        getstartedlab_web.1   xujb/friendhello:part1   izj6c93fq79b96dd5j90uoz   Running             Running 2 hours ago
lvc8dz70h5po        getstartedlab_web.2   xujb/friendhello:part1   izj6c93fq79b96dd5j90uoz   Running             Running 2 hours ago
rooux73shvsx        getstartedlab_web.3   xujb/friendhello:part1   izj6c93fq79b96dd5j90uoz   Running             Running 2 hours ago
ygu47pncmw2y        getstartedlab_web.4   xujb/friendhello:part1   izj6c93fq79b96dd5j90uoz   Running             Running 2 hours ago
6e5jppd0xheg        getstartedlab_web.5   xujb/friendhello:part1   izj6c93fq79b96dd5j90uoz   Running             Running 2 hours ago
tln68phcdz2d        getstartedlab_web.6   xujb/friendhello:part1   izj6c93fq79b96dd5j90uoz   Running             Running 15 minutes ago 
```

扩展应用程序:

* 可以通过更改其中的replicas值docker-compose.yml，保存更改并重新运行该docker stack deploy命令来缩放应用程序：
  docker stack deploy -c docker-compose.yml getstartedlab
  //docker执行一个更新，不需要先放下堆栈或杀死任何容器。

* docker stack rm getstartedlab //去除app应用

```BASH
Removing service getstartedlab_web
Removing network getstartedlab_webnet
```

* docker swarm leave --force  //离开swarm群

```bash
Node left the swarm.
```

备忘:

docker stack ls                                            # List stacks or apps
docker stack deploy -c <composefile> <appname>  # Run the specified Compose file
docker service ls                 # List running services associated with an app
docker service ps <service>                  # List tasks associated with an app
docker inspect <task or container>                   # Inspect task or container
docker container ls -q                                      # List container IDs
docker stack rm <appname>                             # Tear down an application
docker swarm leave --force      # Take down a single node swarm from the manag


**创建了swarm后，涉及的容器使用docker rm contain-id 删除后几秒钟后 自动创建新的容器可能和restart_policy参数有关**


# swarm 群集

swarm 是一组运行 docker	并加入到集群的机器，集群的机器 可以是 物理的或虚拟的，加入群体后，他们被称为 节点。


建立群集:

一个群体由多个节点组成，可以是物理机器或虚拟机器。基本概念很简单：运行docker swarm init以启用群模式，并使您的当前机器成为群管理器，然后docker swarm join在其他机器上运行 ，让它们作为工人加入群体

创建一个集群:

安装 docker-machine

base=https://github.com/docker/machine/releases/download/v0.14.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo install /tmp/docker-machine /usr/local/bin/docker-machine

安装:VirtualBox
  
  yum -y install libGL SDL-devel libXcursor libXinerama libXmu libXrender libvpx
  wget https://download.virtualbox.org/virtualbox/5.2.8/VirtualBox-5.2-5.2.8_121009_el7-1.x86_64.rpm
  rpm -ivh VirtualBox-5.2-5.2.8_121009_el7-1.x86_64.rpm
  //报需要安装kernel-devel，然后yum -y install kernel-devel;sudo /sbin/vboxconfig

创建集群:

* docker-machine create --driver virtualbox myvm1
  
创建失败:Error with pre-create check: "This computer doesn't have VT-X/AMD-v enabled. Enabling it in the BIOS is mandatory"

* docker-machine create --driver generic --generic-ip-address=207.246.96.252 myvm1
  docker-machine create --driver generic --generic-ip-address=207.246.96.252 myvm2

**docker-machine 可以远程进行创建虚拟机 --generic-ip-address 定义远程或者本地的ip地址，要创建成功必须需要执行
主机拥有在远程主机的root用户的登入密钥:ssh-copy-id -i ~/.ssh/id_rsa.pub root@ip**
然后执行上面操作才会成功//需要执行ssh root@ip 进行测验

* docker-machine create --driver generic --generic-ip-address=47.75.74.16 myvm4 
  // 阿里云ECS需要开放2376 端口 才可以进行 创建成功
* docker-machine ls //查看machine

```BASH
NAME    ACTIVE   DRIVER    STATE     URL                         SWARM   DOCKER            ERRORS
myvm1   -        generic   Running   tcp://207.246.96.252:2376           v18.03.0-ce
myvm2   -        generic   Running   tcp://207.246.96.252:2376           v18.03.0-ce
myvm3   -        generic   Running   tcp://207.246.96.252:2376           v18.03.0-ce
myvm4   -        generic   Running   tcp://47.75.74.16:2376              v18.04.0-ce-rc1
```

初始化集群并添加节点


* docker-machine ssh myvm1 "docker swarm init --advertise-addr 207.246.96.252" //把myvm1(管理ip 207.246.96.252)
  设置成 manage 

```BASH
Swarm initialized: current node (kce81y3qvprfbhl0xsevlj0u9) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-42fiqrl33j1zp0el2st2vqzetzqdkw2mqaql2aca07fv0pp9iy-f44gty6kqpc7zmq6aj2rrlgl2 207.246.96.252:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

```

* 查看worker令牌:docker swarm join-token worker
  查看manage令牌:docker swarm join-token manager
  生成新的令牌:docker swarm join-token --rotate

* docker-machine ssh myvm4 "docker swarm join --token SWMTKN-1-42fiqrl33j1zp0el2st2vqzetzqdkw2mqaql2aca07fv0pp9iy-f44gty6kqpc7zmq6aj2rrlgl2 207.246.96.252:2377"
  // 把myvm4设置成worker

```BASH
This node joined a swarm as a worker.
```
* 把myvm4 设置成manage有两中方法:
  1、在manage主机上执行:docker swarm join-token manager 会提示使用命令，给出前面不一样的令牌
     docker-machine ssh myvm4 "docker swarm join --token SWMTKN-1-42fiqrl33j1zp0el2st2vqzetzqdkw2mqaql2aca07fv0pp9iy-536a6yz8hpnjn2yzjp0dgbzcr 207.246.96.252:2377"
     需要上述执行成功，需要先把myvm4从原来的worker组删除，如果在最原始还未添加的状态则不用
  2、或者在 manage主机中进行降权和升权: docker node promote/demote node-id //docker node ls查看id

 **始终运行docker swarm init并docker swarm join使用端口2377（群管理端口），或根本没有端口，并让它采用默认值。
 
 docker-machine ls包含端口2376 返回的计算机IP地址，即Docker守护程序端口。请勿使用此端口，否则 可能会遇到错误。**

* docker node ls

```bash
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
kce81y3qvprfbhl0xsevlj0u9 *   myvm1               Ready               Active              Leader              18.03.0-ce
zf67yzr7ppjo8tibfc0wyuxcs     myvm4               Ready               Active                                  18.04.0-ce-rc1
```

* docker-machine ssh myvm4 "docker swarm leave" //去除myvm4 加入swarm 
* docker node rm myvm4 //在swarm manage中去除 myvm4 的 node


运行docker-machine env myvm1以获取命令来配置您的shell进行通信myvm4：

* docker-machine env myvm4

```BASH
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://47.75.74.16:2376"
export DOCKER_CERT_PATH="/root/.docker/machine/machines/myvm4"
export DOCKER_MACHINE_NAME="myvm4"
# Run this command to configure your shell:
# eval $(docker-machine env myvm4)
```

* 运行:eval $(docker-machine env myvm4)	取消当前shell环境变量:eval $(docker-machine env -u)
* docker-machine ls //"*" 号的表示 正在活动的

```BASH
NAME    ACTIVE   DRIVER    STATE     URL                         SWARM   DOCKER            ERRORS
myvm1   -        generic   Running   tcp://207.246.96.252:2376           v18.03.0-ce
myvm4   *        generic   Running   tcp://47.75.74.16:2376              v18.04.0-ce-rc1
```

在swarm管理器上部署应用程序:

* docker stack deploy -c docker-compose.yml getstartedlab //docker-comose.yml设置了3个app

```BASH
version: "3"
services:
  web:
    # replace username/repo:tag with your name and image details
    image: xujb/friendhello:part1
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: "0.1"
          memory: 50M
      restart_policy:
        condition: on-failure
    ports:
      - "60001:80"
    networks:
      - webnet
networks:
  webnet:
```

* docker stack ps getstartedlab

```BASH
ID                  NAME                      IMAGE                    NODE                DESIRED STATE       CURRENT STATE  ERROR               PORTS
zxxvt1vslwc2        getstartedlab_web.1       xujb/friendhello:part1   myvm1               Running             Running 2 hours ago
7eupmkjsutvh        getstartedlab_web.2       xujb/friendhello:part1   myvm1               Running             Running 2 hours ago
wlja8kxc7k8m         \_ getstartedlab_web.2   xujb/friendhello:part1   myvm4               Shutdown            Shutdown 2 hours ago
wpvpd455y8of        getstartedlab_web.3       xujb/friendhello:part1   myvm4               Running             Running 5 minutes ago
```

?  此时测试 myvm1 myvm4 并没有形成负载均衡，是独立的 //后来在自己虚拟机上是正常的能实现负载均衡
//经 查看网络情况: docker network ls; docker network inspect getstartedlab_webnet-id
可以看到swarm轮询的是 manage ip和 worker的ip，但是worker 是阿里云主机，ifconfig没有上网的ip只有内网ip，故
轮询的是其内网ip而 根据其内网ip在外网是访问不了的。
后来查资料加上 --advertise-addr ip:docker swarm join --token SWMTKN-1-175einkvbik9dxi11umjyetvfogg5cg4lrmmij625fqmo8nvlb-aaaquas413i4ab2z2kelp5ei9 --advertise-addr 47.75.74.16 207.246.96.252:2377
docker network inspect getstartedlab_webnet-id 查看的ip是变了，但是不能转发，每次轮训到worker就卡住获取不到数据，访问worker的ip则相反，轮询到manage的主机就会没有结果卡住，很明显是转发的问题，通信问题
**1、是否可以加个代理网络 ? 未解决**
**后来打开udp 4789端口(阿里云 端口都禁用的) 成功访问，使用--advertise-addr进行设置发布ip**

备忘:

docker-machine create --driver virtualbox myvm1 # Create a VM (Mac, Win7, Linux)
docker-machine create -d hyperv --hyperv-virtual-switch "myswitch" myvm1 # Win10
docker-machine env myvm1                # View basic information about your node
docker-machine ssh myvm1 "docker node ls"         # List the nodes in your swarm
docker-machine ssh myvm1 "docker node inspect <node ID>"        # Inspect a node
docker-machine ssh myvm1 "docker swarm join-token -q worker"   # View join token
docker-machine ssh myvm1   # Open an SSH session with the VM; type "exit" to end
docker node ls                # View nodes in swarm (while logged on to manager)
docker-machine ssh myvm2 "docker swarm leave"  # Make the worker leave the swarm
docker-machine ssh myvm1 "docker swarm leave -f" # Make master leave, kill swarm
docker-machine ls # list VMs, asterisk shows which VM this shell is talking to
docker-machine start myvm1            # Start a VM that is currently not running
docker-machine env myvm1      # show environment variables and command for myvm1
eval $(docker-machine env myvm1)         # Mac command to connect shell to myvm1
& "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env myvm1 | Invoke-Expression   # Windows command to connect shell to myvm1
docker stack deploy -c <file> <app>  # Deploy an app; command shell must be set to talk to manager (myvm1), uses local Compose file
docker-machine scp docker-compose.yml myvm1:~ # Copy file to node's home dir (only required if you use ssh to connect to manager and deploy the app)
docker-machine ssh myvm1 "docker stack deploy -c <file> <app>"   # Deploy an app using ssh (you must have first copied the Compose file to myvm1)
eval $(docker-machine env -u)     # Disconnect shell from VMs, use native docker
docker-machine stop $(docker-machine ls -q)               # Stop all running VMs
docker-machine rm $(docker-machine ls -q) # Delete all VMs and their disk images




