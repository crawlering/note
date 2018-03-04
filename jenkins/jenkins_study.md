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

  
