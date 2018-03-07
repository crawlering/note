# jenkins 

产品设计成型-开发人员开发代码-测试人员测试功能-运维人员发布上线

持续继承(Continuous integration CI)
持续交付(Continuous delivery)
持续部署(Continuous deployment)


## jenkins 安装

* 最低配置： 不少于256M，不低于1G磁盘，jdk版本>=8
* 安装jdk1.8
* yum install -y java-1.8.0-openjdk
* wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
* rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key //导入密钥
* yum install -y jenkins
* systemctl start jenkins
* less /var/log/jenkins/jenkins.log //查询admin密码 或者 /var/lib/jenkins/secrets/initialAdminPassword
* 访问 http://ip:8080/ 进行安装


## jenkins 相关目录

* rpm -ql jenkins
* 安装目录 /var/lib/jenkins
* 配置文件 /etc/sysconfig/jenkins
* /var/log/jenkins/ //日志目录


## 开始jenkins

* 插件安装选择 默认安装
* 填写 用户名密码
* 检查插件
  系统管理: 已安装-publish over ssh 和  git plugin
  安装没有安装的软件

* 配置 ssh
  在服务器端 生成 公私密钥: ssh-keygen -t rsa // 可以设置密码，也可以不设置
  把id_rsa.pub 文件拷贝到客户机 /home/root/authorized_keys 中，authorized_key 文件需要是600权限 .ssh文件夹 700权限
  把服务器公钥拷贝到 web中key:  --增加 ssh service 填写 name hostname username remote directory: / 
  点击测试: 返回success 后 apply

* 新建任务-输入名称 xujb_test 
           选择 构建一个自由风格的软件项目
            确定
* 描述:
  源码管理:选择 git
  Repository URL 选择 git的一个clone地址
  其他不选择
  点击构建- sendfile or execute commands over ssh
  source files: **/**
  remote direcotry: /tmp/jenkins/
  exec commmand: chown nobody:nobody -R /tmp/jenkins/
  点击保存
* 在工作页面点击立即构建 -在build 历史可以选择 控制台输出 查看发布结果 success表示成功


## jenkins 邮件通知

1、
* 系统管理-系统设置- 系统管理员邮件地址: 123xujiangbo@163.com
* 邮件通知处填写服务器: 
  SMTP： smtp.163.com
  用户名: 123xujiangbo@163.com 密码:
  SMTP端口: 25
  其他保持默认或者不填
  点击通过发送测试邮件测试配置: test-email recipient:123xujiangbo@163.com  返回 successful 则配置成功
* 然后点击我的视图-选择项目-配置-构建后操作选择: EMAIL notification 
* 在recipients: 123xujiangbo@163.com //收件人
此设置是只针对 错误的时候发送邮件提醒

2、
* 查看  插件名字Email Extension Plugin，默认已经安装
* 已安装后 系统设置，取消上方设置的stmp选项，勾选 extended E-mail Notification项
  填写:SMTP server：smtp.163.com
  username: 123xujiangbo@163.com password:
  SMTP port:25
  default triggers: 选择 Always
  应用 保存
* 配置 项目设置:
* 删除上面设置的 构建后操作的 E-mail Notification选项
  增加: Editable Email Notification
  project recipient list: 123xujiangbo@163.com //其他不变增加这个
  Advanced settings-可以选择其他触发方式，也可以不设置-上面默认已经设置了always
* 测试发送邮件: 失败和成功各做测试
参考网页: http://www.cnblogs.com/zz0412/p/jenkins_jj_01.html


## jenkins 破解管理员密码

* /var/lib/jenkins/user/admin/config.xml
  <passwordHash> xxx </passwordHash>
  xx 改为: #jbcrypt:$2a$10$PYJMwThN41lsCD08UCowveA0g1JcHaYSkIdUtGvhR2HC4mS/ynhcS 
* 重启jenkins
* 新密码为 admin


## jenkins 部署java项目 创建私有仓库

* 在github中把服务器SSH公钥设置好 //可以自己创建gitlab私有库
* 然后创建新的项目
  然后按照提示信息初始化一遍
  echo "# test-java2" >> README.md
  git init
  git add README.md
  git commit -m "first commit"
  git remote add origin https://github.com/crawlering/test-java2.git
  git push -u origin master
  git remote add origin https://github.com/crawlering/test-java2.git
  //修改一下readme文件
  // 添加 git add -A 修改的提交到库
  //git status 查看提交状态
  git push -u origin master


### 创建一个项目
  
* java项目是需要编译和打包的
* 编译和打包用 maven 完成，所以需要安装 maven
* 下载 测试源码: zrlog源码: 
  wget https://codeload.github.com/94fzb/zrlog/zip/master 
  unzip master;mv zrlog test/ //test/ 为git项目的目录
  git -m commit "javatest01 commit"
  git add -A 
  git status
  git push //上传到git仓库

* 安装tomacat:
* vim /usr/local/tomcat/conf/tomcat-users.xml 末尾添加:
  <role rolename="admin"/>
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <role rolename="manager"/>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>
  <user name="admin" password="admin" roles="admin,manager,admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status" />

* vim webapps/manager/META-INF/context.xml //在allow处填写可以访问的IP

```bash
<Context antiResourceLocking="false" privileged="true" >
        <!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
        <Valve className="org.apache.catalina.valves.RemoteAddrValve"
            allow="127\.0\.0\.1|192\.168\.31\.95|192\.168\.31\.\d+"/>
    <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context> 
//不加"192\.168\.31\.\d+" 后面发布的时候会把报错"The username you provided is not allowed to use the text-based Tomcat Manager (error 403)"

```

* 启动tomcat


* 安装 maven: 
  wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz
  tar -zxvf apache-maven-3.5.2-bin.tar.gz
  mv apache-maven-3.5.2-bin.tar.gz /usr/local/
* web设置jenkins
  点击全局工具配置-Maven configuration: Default setting privider 选择 setting file in filesystem:

                                                                       file path:/usr/local/apache-maven-3.5.2/conf/setting.xml
			                Default glogbal settings provider 选择 Global settings file on filesystem
					file path: /usr/local/apache-maven-3.5.2/conf/setting.xml
  Maven: maven name: maven-3.5.2
         MAVEN_HOME: /usr/local/apache-maven-3.5.2
  SAVE 保存


### 添加 maven 项目
 
* 检查是否已经安装 Maven Integration plugin 和 Deploy to container Plugin，若没有安装则需要安装这两个插件
// 一个是增加maven项目 一个是 Deploy to container Plugin需要通过属于manager-script组的Tomcat管理用户将war包发布到Tomcat服务器上，默认没有这样的用户，需要在TOMCAT_HOME/conf/tomcat-users.xml添加manager-script组和相应的用户，增加如下两行：
<role rolename="manager-script"/>
<user username="deploy" password="deploy123456" roles="manager-script"/>
注：配置好后需要重启Tomcat才能生效

* 重启jenkins服务

* 然后新建任务:java-test 选择 构建一个maven项目
* 配置
  源码管理: GIT
  Repository url:   git@github.com:crawlering/test-java2.git       //git ssh url
  Credentials add
  kind 选择 SSH username with pprivate key
  username: git //因为url可以看出来是git用户
  Private key: Enter directly
  key:  //把服务器A发布到git仓库的 私有密钥拷贝至此
  密码没有设置就不用填

  build: Root pom:zrlog-master/pom.xml //此项是git中的pom.xml文件，
  Goals and options : clean install -D maven.test.skip=true
  *前面的步骤设置好后，jenkins 运行后就会去git仓库拉取数据并打包成.war文件*
  *后面的操作就是和发布有关了*
  *主要就两个操作，一个是发布有关的一个是邮件通知*
  构建后操作:
  
  增加 Deploy war/ear to container，然后设置
  WAR/EAR files: **/*.war      //设置war位置，此设置可以上传所有war包，/var/lib/jenkins/workspace/test-java/zrlog-master/target
                              //一般文件是在上述路径target中**
  containers: credetials: ADD 选择要发布的tomcat服务器版本然后配置
  username:admin password:admin //为tomcat登入 manager所需要的密码。上面rolename设置过
  在直接add
  credentials:选择刚刚设置的 admin配置


  tomcat url: http://192.168.31.20  //服务器IP
  然后配置 邮件:添加 Editable Email Notification,在project recipient list收件箱列表增加;,123xujiangbo@163.com

  然后保存，进行构建,在控制端进行查看输出，哪里有错误会报出，进行调整


**jenkins发布代码过程:首先把代码上传到git仓库，
  然后通过设置maven项目，可以把git仓库的代码拉到服务器上进行打包war，通过插件"Deploy to container Plugin"
  上传到客户端的tomcat服务器上(期间有些环境设置例如tomcat登录账户 服务器git登入的密钥 以及java环境的设置等)**


