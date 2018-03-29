python3.0
# urllib 

* urllib.request for opening and reading URLs
* urllib.error containing the exceptions raised by urllib.request
* urllib.parse for parsing URLs
* urllib.robotparser for parsing robots.txt files


python2x 和 python3x的变化:
* python2:          ->             python3:
  urllib.urlencode(data)      urllib.parse.urlencode(data)
  import urllib2              import urllib.request
  urllib2.urlopen()           urllib.request.urlopen()
  urllib2.Request()           urllib.request.Request() 
  urllib2.URLError            urllib.error.URLError

urllib.request.urlopen:

urllib.request.urlopen(url, data=None, [timeout, ]*, cafile=None, capath=None, cadefault=False, context=None)




GET:
http://www.baidu.com/s?test=xx
* url="http://www.baidu.com/s"
* values = {"test":"xx"} //请求数据
* data = urllib.parse.urlencode(values).encode('utf-8')   //转换字符，把字典转换成请求字符 -> 'test=xx'
* url_data = url + "?" + data
* response = urllib.request.urlopen(url_data) //发送GET请求
* result = response.read() //读取回应
* print(result)


POST:

url="http://www.baidu.com"
values={"test":"xx"} //请求数据
user_agent='Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
header = { 'User-Agent' : user_agent }
data = urllib.parse.urlencode(values).encode('utf-8') //对请求字符转换
req = urllib.request.Request(url, data, heards) //对请求头部进行自定义-伪装,和数据重组
response = urllib.request.urlopen(req) //发送POST请求
result = response.read() //接收完整回应信息


json:
json.dumps() 
json.dump() //格式流到文件
json.loads()
json.load() //从文件流读出

import json

data = json.dumps("hello python").encode('utf-8')
print(data)
json.loads(data.decode('utf-8'))

with open('text.txt', 'w+') as f:
   data=json.dump("hello python",f)
cat text.txt

with open('text.txt', 'r') as f:
   json.load(f)     //把刚刚寸的json内容从文件内容读出



