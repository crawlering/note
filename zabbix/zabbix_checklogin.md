# zabbix 监控登入情况

目的在于只要有人登入后，就需要报警通知。

查看有键值 vfs.file.cksum 作用是 检查文件数据返回一个整数，文件改变返回数值就变化
而判断/var/log/wtmp 文件，当用户退出也会改变值所以不行

* 编辑 vim /etc/profile //普通用户先登入会创建文件失败，所以可以手动创建 records 和 login.log  文件
  并属性赋值

```bash
if [ ! -d  /usr/local/records ]
then
        mkdir -p /usr/local/records
        chmod 777 /usr/local/records
fi
if [ ! -e /usr/local/records/login.log ]
then
    touch /usr/local/records/login.log
    chmod 666 /usr/local/records/login.log
fi
export LOGIN_FILE="/usr/local/records/login.log"
export PROMPT_LOGIN=`who am i |awk '{print $0}' >>$LOGIN_FILE`
readonly PROMPT_LOGIN

```

* 然后在 zabbix 创建监控项，键值为:vfs.file.cksum[/usr/local/records/login.log] 时间10s更新
* 创建 触发器 表达式 选择前一个不等于现值
  事件成功迭达选择 无 //不然 有用户登入后，几秒中又会发一个 恢复信息，实际也不确认 用户有没有退出，没这个状态值判断
  问题时间生成模型: 多重 //如果选择单个 而 时间成功迭达又选择无，触发一次报警后，后面就不会触发，而选择多重就是会连续触发，前后值不一样，就会触发
* 然后按照设置邮件报警操作，如果设置了邮件报警则不用设置·
