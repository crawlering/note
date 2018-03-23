# gpg 验证

过程:
* 生成密钥对(私钥和公钥):并把公钥发到默认服务器上或者你的对象用户
* 数字签名一个文件
* 客户在默认服务器上导入公钥 
* 下载文件签名文件 和 原始文件
* 验证文件 合法性


1、gpg --gen-key：按照提示设置 都是默认 name:xujbo 密码为1-8，等待... //生成密钥对
   gpg --list-keys //查看公钥信息 看的到公钥ID 后面用
2、gpg -a --output key.public --export xujbo //导出公钥
   cat key.public//查看公钥内容
   gpg --keyserver keys.gnupg.net --send-key ID //把公钥发布到 服务器上
3、创建一个测试文件 echo "test pgp" > test.txt
   gpg -a -b test.txt //签名一个文件 会多生产 一个 test.txt.asc 文件
4、把.asc 和 test.txt 源文件 发送给 客户
5、客户 在默认服务器上 搜索下载公钥:
   gpg --keyserver keys.gnupg.net --recv-key 公钥ID
   或者你直接把公钥key.public 传给用户,用户直接用导入该密钥:gpg --import key.public

6、下载 签名文件和原始文件: 把.asc 和 test.txt 源文件下载
7、验证下载文件的完整性:
    gpg --fingerprint //验证公钥的指纹 防止公钥被伪造
    gpg --sign-key ID //签收公钥  gpg --delete-keys ivarptr 删除公钥
    gpg --verify test.txt.asc //验证文件完整
    测试 修改test.txt内容:然后再次验证，是失败的

*在生成密钥的时候可能会卡住解决办法:
yum -y install  rng-tools && rngd -r /dev/urandom 即可恢复*

 
