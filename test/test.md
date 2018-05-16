# 测试用例编写要点

需求分析:
根据客户要求 项目经理一般会给出要求 研发也会给出开发文档(其实测试用例根据开发进行延伸)

业务需求: 锁测试的系统整体是否 满足业务需求
功能需求: 关注各个功能模块是否满足所设计的 功能方向
用户需求: 关注设计的系统是否满足用户使用习惯
        : 个人主观叫强 会议上会商讨，而且等软件基本成型了会让公司内部人员 第一次体验使用


然后是根据测试 需求 提取出测试点 

然后进行测试点整理 编写测试用例  

测试用例写完后 进行评审

测试用例包括的东西:
用例编号 用例名称
测试环境
测试步骤  输入数据 预期结果 实际结果 状态 优先级 备注

测试添加项


# 测试要点

接口测试:

当客户端或者 web前端没完全成型之前 使用 GET POST 方式上传 数据测试

使用wireshark抓包 TCP stream 查看数据信息 一般是json格式保存
可以使用fiddler 抓取浏览器的数据
http: 请求 响应
一般可以看到 user_agent 代理 content_lenth 一般注意 数据 POST GET 发送方式
connection: keep-alived 保持  图片缓存，是否开启了此功能

HEAD 只返回首部 验证返回状态
GET 验证信息会在URL里面 有安全问题
POST 验证信息存在body里面

tcp:

用户数据      
首部 用户数据  -> 应用数据       应用程序
TCP首部 应用数据  ->TCP段   TCP
IP首部 TCP段      ->ip数据报   IP
以太网首部 IP数据报 -> 以太网帧  以太网
以太网帧
传输层叫做段（segment），在网络层叫做数据报（datagram），在链路层叫做帧（frame）

tcp三次握手四次挥手

tcp 面向连接的可靠传输

客户端 请求连接 SYN syn_send     服务端收到发送一个ACK+syn 置于syn_received
客户端收到ack以后就置于ESTABLISED 状态 然后发送ACK给服务端， 
服务端收到ack以后也置于ESTABLISED状态 
syn_send syn_recieved
ESTABLISHED 

tcp四次挥手

客户端发送 FIN 置于 fin_wait1   服务端收到FIN信号 然后发送 ACK 让客户端知道自己已经收到断开连接请求 CLOSE-WAIT
首先客户端收到ACK 以后 客户端置于 fin-wait2 状态 等待server端的断开请求
一会儿 服务端发送FIN断开请求 置于 LAST-ACK 等待客户端回应
当客户端收到服务端的FIN信号后马上 置于 time-wait状态 发送ACK 	服务端收到客户端ack信号后 closed
2MSL时间后 没有收到任何信息就closed

总结: 握手 谁发起谁先ESTABLISHED
      挥手 谁先发起谁后CLOSED


SOCKET

socket.AF_INET
socket.SOCK_STREAM
socket.SOCK_DGRAW
socket.setsockopt()
s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind
s.listen
s.accept
s.send
s.connect(IP)
s.recieve()

像我曾经用socket做过的测试工具，升级工具，开始根据web升级，上传文件来做的，但是后来升级问题，socket传输，传输文件频率，这方面需要注意就是为我们嵌入式设备配置较低 内存只有16M 设备正常运行状态一般是在2M-10几兆范围 
还做了为了测试喇叭声音和喇叭的可靠性，需要一直播放，所以当时用了cool edit这个软件对下载的音频文件进行格式转化raw原始音频文件，然后就socket传输，让设备循环播放，也是需要注意传输频率，这个是问过开发人员，处理速度

java
jvm 
jstat -gc pid 查看进程垃圾挥手情况





性能测试
测试环境
像我们公司 做性能测试 一般是项目的基础功能基本完善后开始做，公司是做视频监控，主要就做 拉视频流 支持4路，延时200MS以内
修改视频参数 频率 500ms ，主要修改是否成功 是否有内存溢出现象 free是否太低异常，后者cpu达到90%以上 95%超过5次

