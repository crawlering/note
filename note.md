#URL 和 URI 区别

URL 是 URI的子集，
URL： uniform resource locator URL
URI:  uniform resource identifier URI


网上解释://www.zhihu.com/question/21950864/answer/66779836

    URI 是统一**资源标识符**，而 URL 是统一**资源定位符**。
因此，笼统地说，每个 URL 都是 URI，但不一定每个 URI 都是 URL。
    这是因为 URI 还包括一个子类，即统一资源名称 (URN)，它命名资源但不指定如何定位资源。
上面的 mailto、news 和 isbn URI 都是 URN 的示例。 URI 和 URL 概念上的不同反映在此类和 URL 类的不同中。
     此类的实例代表由 RFC 2396 定义的语法意义上的一个 URI 引用。URI 可以是绝对的，也可以是相对的。
对 URI 字符串按照一般语法进行解析，不考虑它所指定的方案（如果有）不对主机（如果有）执行查找，
也不构造依赖于方案的流处理程序。相等性、哈希计算以及比较都严格地根据实例的字符内容进行定义。
换句话说，一个 URI 实例和一个支持语法意义上的、依赖于方案的比较、规范化、解析和相对化计算的结构化字符串差不多。
 作为对照，URL 类的实例代表了 URL 的语法组成部分以及访问它描述的资源所需的信息。URL 必须是绝对的，
即它必须始终指定一个方案。URL 字符串按照其方案进行解析。通常会为 URL 建立一个流处理程序，
实际上无法为未提供处理程序的方案创建一个 URL 实例。相等性和哈希计算依赖于方案和主机的 Internet 地址（如果有）；
没有定义比较。换句话说，URL 是一个结构化字符串，它支持解析的语法运算以及查找主机和打开到指定资源的连接之类的网络 I/O 操作。


# man 查看函数帮助

yum -y install man-pages 
man pthread_join #函数帮助

# man 怎么把源码安装的软件的man帮助信息安装到 系统的man里

* 以nginx为例 查看man/nginx.8 把此文件拷贝到 /usr/share/man/man8/ 中
* 然后执行 mandb 进行man 条目的更新 
* 然后man nginx 就可以查看的到
