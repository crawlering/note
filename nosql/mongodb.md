# mongodb

* 官网www.mongodb.com， 当前最新版3.4
* C++编写，基于分布式的，属于NoSQL的一种
* 在NoSQL中是最像关系型数据库的
* MongoDB 将数据存储为一个文档，数据结构由键值(key=>value)对组成。
  MongoDB 文档类似于 JSON 对象。字段值可以包含其他文档、数组及文档数组。
* 关于JSON http://www.w3school.com.cn/json/index.asp
* 因为基于分布式，所以很容易扩展
* JSON

```BASH
{
"employees": [
{ "firstName":"Bill" , "lastName":"Gates" },
{ "firstName":"George" , "lastName":"Bush" },
{ "firstName":"Thomas" , "lastName":"Carter" }
]
}
```


|sql术语概念|mongodb术语概念|解释说明
|-----------|---------------|--------
|database   |database       |数据库
|tables|collection|数据库表/集合
|row|document|数据记录行/文档
|column|filed/数据字段/域
|index|index| 索引
|table joins| |表连接,mongodb不支持
|primary key|primary key|主键mongodb自动将_id字段设置为主键


