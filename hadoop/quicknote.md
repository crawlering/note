# hadoop

apache item , java language development

HDFS: store data
mapreduce: analyze data, calculation data

module: 
Common: 为其他组建提供常用工具支持
YARN: 作业调度和集群管理框架

Ambari: apache software foundation 中的一个项目，创建 管理 监视hadoop 的集群，
        hadoop(hive hbase zookeeper等)，Ambari就是为了让hadoop以及相关的大数据软件更容易使用的一个工具

Avro: Avro 是 hadoop中的一个子项目 也是apache中的一个独立项目 Avro 是一个基于 **二进制数据** 传输高性能的中间件
      hadop的其他项目中 如 hbase(Ref)和 hive(Ref)的Client端与服务端的数据也采用了这个工具
      Avro 是一个数据序列化系统 Avro 可以将数据结构或对象转换成便于存储或传输的格式，
      Avro 设计之初是用来支持 数据密集型应用， 适合于远程和本地大规模数据的存储和交换

Cassandra: 可扩展的多主数据库，不存在单点故障

Chukwa: 是数据收集系统用于监控和分析大型 分布式系统的 数据

HBase: 是一个分布式面向列的数据库

Hive: 最早有facebook设计，是建立在hadoop 基础之上 的数据仓库， 它提供了一些 用于数据整理、特殊查询和分析在
      hadoop文件中数据集工具。

Mahout: 可扩展的机器学习和数据挖掘库

Pig: 是一种高级语言和并行计算可执行框架，他是一个对大型数据库集分析和评估的平台

Spark: 一个快速和通用计算的Hadoop数据引擎，和 mapreduce 类似，但要比 mapreduce快，提供了一个简单而丰富的编程模型，
       支持多种应用，包括 ETL， 机器学习 数据流处理 图形计算

Tez: 是apache最新的支持DAG作业的开源计算框架， 
     可以将多了有依赖的作业转换成一个作业 从而 大幅度提升DAG 作业的性能
     Tez 并不直接面向最终用户，他允许开发者为最终用户构建 性能更快 扩展性更好的 **应用程序**
     Hadoop 传统上是一个大量数据 批处理平台，但是 有很多用例需要近乎实时查询处理 性能
     还有些工作则不适合 Mapreduce,例如 机器学习， Tez 目的就是帮助hadoop解决处理这些用例场景

 ZooKeeper: 是一组工具，用来配置和 支持分布式调度
            一个重要功能就是对所有节点进行配置的同步，他能处理分布式应用的 部分失败 问题
	    部分失败 是分布式处理系统的固有特性，即发送这无法知道接受者是否收到消息，
	    这种情况的出现可能是 网络传输的问题 接收进程意外死掉等问题 引起
	    Zookeeper是hadoop生态系统的一部分，但有远不止如此，他能支持更多类似的分布式平台和系统
	    如: Jubatus 、Cassender 等等

# HDFS

HDFS 设计四巷源于 google的 GFS，是GFS的开源实现

HDFS 解决的问题:
* 存储超大文件 比如TB级别
* 防止文件丢失

HDFS的特点:
* 可以存储超大文件
* 只允许对一个已经打开的文件顺序写入， 还可以在现有文件的末尾追加，
  要想修改一个文件(追加内容除外)，只能删除后在重写
* 可以使用廉价的硬件平台搭建， 通过容错策略来保证数据的高可用，默认存储3分数据，任何一份丢失可以自动恢复

HDFS缺点:
* 数据访问延迟比较高，因为它的设计场景是用于大吞吐量数据，HDFS是单master，所有文件都要经过它，
  当请求数据量大的时候，延迟就增加了
* 文件数受限，和NameNode有关系
* 不支持多用户写入，也不支持文件的任意修改

HDFS的概念:
* 数据块(block): 大文件会被分隔成多个block进行存储，block 大小默认为 64MB，每一个block会在多个datanode上存储
  多份副本，默认是3份(2个副本1个原件) (支持一个block存多个文件)
* namenode: namenode 负责管理文件目录、文件和block的对应关系 以及 block和datanode的对应关系
* SecondaryNameNode: 分担namenode的工作量，他的主要工作是 合并 fsimage(元数据镜像文件)和 fsedits(元数据操作日志)
  然后再发给namenode
* datanode: datanode就负责存储，大部分容错机制都是在datanode上实现的
* rack 是指 机柜的意思，一个 block 的三个副本通常会保存到两个或两个一行的机柜中(当然是机柜中的服务器)，这样做的
  目的是防灾容错，因为发生一个机柜掉电或者一个机柜的交换机挂了的概率还是有的


HDFS写文件流程:

* Client向远程Namenode 发起RPC请求；
* Namenode 会检查 要创建的文件是否已经存在， 创建这是否有权限进行操作，成功则会为文件创建一个记录，
  否则会让客户端抛出异常
* 当客户端开始写入文件的时候，会将文件切分成多个packets，并向namenode申请blocks，获取合适的datanode列表
  申请好后，会形成一个pipline用来传输 packet
* packet 以流的方式写入第一个datanode，该datanode把packet存储之后，在将其传递给下一个datanode，直到最后一个datanode
* 最后一个datanode成功存储后(默认是3份)，会返回一个ack传递给客户端，在客户端，客户端确认ack后继续写入下一个packet
* 如果传输过程中，有某个datanode出现故障，那么当前的pipline会被关闭，出现故障的datanode会从当前的pipline中移除
  剩余的block会从剩下的datanode中继续以pipline的形式传输，同时namenode会分配一个新的datanode
  (？传输是packet 1份1份传输，传输中间 1个datanode出现问题后，产生一个新的datanode后，是从其他的datanode复制，
  还是整体需要等待这个新的datanode 从开始1个packet重新传输)

HDFS读文件流程:

* Client项远程的Namenode发起RPC请求
* Namenode会视情况返回文件部分或者全部block列表，对于每个block，namenode都会返回有该block拷贝的datanode地址
* client会选取离自己最接近的datanode来读取block
* 读取完当前block的数据后关闭与当前的datanode连接，并且为读取下一个block寻找最佳的datanode
* 当读完列表的block后，且文件读取还没有结束，client会继续项namenode获取下一批的block列表
* 读取完block会进行checksum验证，如果读取datanode时出现错误，客户端会通知namenode，然后再从下一个拥有该block副本的
  datanode继续读


# MapReduce

MapReduce 是大规模数据(TB级)计算的利器，Map 和Reduce是他的主要思想，来源于函数式编程语言

Map 负责将数据打散
Reduce 负责对数据进行聚集
用户只需要实现map和reduce两个接口，即可完成TB集数据的计算
* 常见的应用包括: 日志分析和数据挖掘等数据分析应用，另外 还可用于科学数据计算，如圆周率PI的计算等
* 当我们提交一个计算作业时，MapReduce 首先把计算拆分 成若干个Map任务
  然后分配到不同的节点上去执行，每一个Map任务处理输入数据中的一部分，当Map任务完成后，他会生成一些中间文件，
  这些中间文件将会作为Reduce任务的输入数据， reduce任务的主要目标就是把前面若干个Map的输出汇总到一起并输出


MapReduce执行过程

Mapper:
* 每个mapper任务是一个java进程，他会读取HDFS中的文件，解析成很多个键值对，经过我们map方法处理后，
  转换为很多的键值对 再输出
* 每个Mapper任务运行过程分为六个阶段
  1 把输入文件按照一定的标准分片(inputsplit) 每个输入片的大小是固定的
  2 对输入片中的记录按照一定的规则解析成键值对
  3 调用mapper类中的map方法
  4 按照一定规则对第三阶段输出的键值对 进行分区
  5 对每个分区中的键值进行排序
  6 读数据进行归纳处理，也就是reduce处理，键相等的键值对会调用一次reduce方法

reduce任务执行过程:
* 每个reduce任务是一个java进程，reducer任务接收mapper任务的输出，归纳处理后写入到HDFS中
* 分为三个阶段:
  1 reducer任务会主动从mapper任务复制其输出的键值对，mapper任务可能会有很多，因此reducer会复制多个mapper的输出
  2 把复制到reducer本地数据，全部进行合并，即把分散的数据合并成一个大的数据。在对合并后的数据排序
  3 对排序后的键值对调用reduce方法。键值相等的键值对调用一次reduce方法，每次调用会产生零个或者多个键值对
    最后把这些输出的键值对写入到HDFS文件中


