
# shell 编程

* shell 变量
* shell 函数
* shell 文件包含


## shell 变量

* 基本变量
* 数组
* 运算
* echo
* printf
* test
* date


### 基本变量

* 引用某个命令的结果时，用变量代替 n=`wc-l test.txt`
* 写交互脚本时 read -p "input a number:" n; echo $n
* 内置变量 $0 表示脚本本身 $1 第一个参数 $2 第二个参数 $# 表示参数个数


### 数组

* 数组定义: 数组名=(v1 v2 v3) # 用括号来表示数组，数组元素用"空格"符号分隔
  单独定义数组的各个分量: array_name[0]=v1 array_name[1]=v2

读取数组

* ${数组名[下标]} echo ${name[1]}
* 获取出所有数组值: echo ${name[@]} 或者 echo ${name[*]}

获取数组长度

* length=${#name[@]} 或 length=${#name[*]}
* lengthn=${#name[n]} n=0123... #获取数组单个元素长度

删除数组

* unset name[1] 删除数组第一个值
* unset name 删除整个数组

数组数据提取

* echo ${name[*]:n1:n2}  n1为不显示前面n1个 n2为显示前面n2个
exp: nn=(0 1 2 3 4 5)
echo ${nn[*]:0:1} => 0
echo ${nn[*]:0:2} => 0 1 #显示前面面2个
echo ${nn[*]:0 => 0 1 2 3 4 5
echo ${nn[*]:1} => 1 2 3 4 5
echo ${nn[*]:2} => 2 3 4 5 #不显示前面2个
echo ${nn[*]:0:1} => 0 #显示第0个
echo ${nn[*]:1:1} => 1 #显示第1个

* echo ${name[n]:n:1} = echo ${name[n]}

数组字符串删除 
"#" 表示首字母匹配
“%” 表示尾字符匹配

* echo ${name[0]#f} #第0个元素删除"f“的首字母，首字母如果不是f则不操作
* echo ${name[0]%f} #第0个元素删除"f“的尾字母，尾字母如果不是f则不操作
* echo ${name[0]%f*} # 第0个元素中 从尾部开始删除 第一个遇到"f"字母
* echo ${name[0]#*f} # 第0个元素中 从首部开始删除 第一个遇到"f"字母的所有字符

字符串替换

* echo ${name[0]/o/m} #把第一个o换成m
* echo ${name[0]//o/m} #把所有的o换成m

### 运算

整数运算
* ((i=$j+$k)) # + - *  / %(取余)  相当于 i=`expr $j + $k` 空格注意 *（乘 需要加\ 进行转译） 
* let i=k+j #如果有空格需要引号 let “i = i + 1”
* 两个"*" 为平方
浮点运算

bc 进行浮点运算

* scale=2 设置小数位数，默认是用的运算中最长的小数位数，scale可以设置多保留几位
* ibase=2 obase=2 输入为2进制数 obase 输出为2进制数 默认是十进制
example:
 echo "scale=3;4.00*2.1" |bc ==> 8.400
  echo "obase=2;4.00*2.1" |bc ==>1000.0110011
  echo "ibase=2;110*10" |bc ==>12


### echo 和 printf

echo
* -e 对 \n \t 进行解析
* -n 不加换行符
printf
可以对字符串进行格式化输出
%c：ASCII字符，如果参数给出字符串，则打印第一个字符 
%d：10进制整数 
%i：同%d 
%e：浮点格式（[-]d.精度[+-]dd） 
%E：浮点格式（[-]d.精度E[+-]dd） 
%f：浮点格式（[-]ddd.precision） 
%g：%e或者%f的转换，如果后尾为0，则删除它们 
%G：%E或者%f的转换，如果后尾为0，则删除它们 
%o：8进制 
%s：字符串 
%u：非零正整数 
%x：十六进制 
%X：非零正数，16进制，使用A-F表示10-15 
%%：表示字符"%"

#### test

运算符:

算数运算符:
+ - * /  加 减 乘 除
% 取余
= 赋值
== 相等 != 不想等

关系运算符:

-eq  检测两个是否相等 相等返回 true
-ne 检测连个是否相等 不想等返回 true
-gt  大于            左边大于右边 返回 true
-lt  小于            左边小于右边 返回 true
-ge  大于等于
-le  小于等于

布尔运算符:

!  非运算 表达式为 true 则 !exp 则返回 false
-o 或运算 有一个表达式为 true 则返回 true
-a 与运算 两个表达式为 true 才返回true

逻辑运算符:

&& 逻辑AND   两个(所有)为true 才为true
|| 逻辑OR    所有 为 false 才为 false 否则返回 true(有一个为true就是true)

command1  && command2
&&左边的命令（命令1）返回真(即返回0，成功被执行）后，&&右边的命令（命令2）才能够被执行；换句话说，“如果这个命令执行成功&&那么执行这个命令”。
command1 || command2
||则与&&相反。如果||左边的命令（命令1）未执行成功，那么就执行||右边的命令（命令2）；或者换句话说，“如果这个命令执行失败了||那么就执行这个命令。

字符串运算符:

= 检测两个字符串是否相等，相等返回 true
!= 不想等 返回true
-z 检测字符串长度是否为0 为0则返回 true
-n 字符串长度不为0 则返回true
str 检测字符串是否为空 不为空则返回 true [ $a ]

文件测试运算符:

-b file	检测文件是否是块设备文件，如果是，则返回 true。	[ -b $file ] 返回 false。
-c file	检测文件是否是字符设备文件，如果是，则返回 true。	[ -c $file ] 返回 false。
-d file	检测文件是否是目录，如果是，则返回 true。	[ -d $file ] 返回 false。
-f file	检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true。	[ -f $file ] 返回 true。
-g file	检测文件是否设置了 SGID 位，如果是，则返回 true。	[ -g $file ] 返回 false。
-k file	检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true。	[ -k $file ] 返回 false。
-p file	检测文件是否是有名管道，如果是，则返回 true。	[ -p $file ] 返回 false。
-u file	检测文件是否设置了 SUID 位，如果是，则返回 true。	[ -u $file ] 返回 false。
-r file	检测文件是否可读，如果是，则返回 true。	[ -r $file ] 返回 true。
-w file	检测文件是否可写，如果是，则返回 true。	[ -w $file ] 返回 true。
-x file	检测文件是否可执行，如果是，则返回 true。	[ -x $file ] 返回 true。

-s file	检测文件是否为空（文件大小是否大于0），不为空返回 true。	[ -s $file ] 返回 true。
-e file	检测文件（包括目录）是否存在，如果是，则返回 true。	[ -e $file ] 返回 true。

**test**
test -s file 和 [ -s $file ] 功能相同 注意[] 前后有空格
[ "$a" = "$b" ] 判断字符串a是否和字符串b相同
### date

*用途 文件命名日期*
* date +%Y-%m-%d, date +%y-%m-%d 年月日
* date +%H:%M:%S=date +%T 时间
* date +%s 时间戳
* date -d @1519535435 时间戳转换成 日期
  date -d @1519535435 +%F\ %T 时间戳转换成日期然后在格式化
* date -d"+1day" 一天后
  date -d"-1day" 一天前
  date -d"+1month" 一个月后
  date -d“+1min” 一分钟后
  date -d"+1sec" 一秒钟后
  date +%w 0-6 代表星期几 0为星期天
  date +%W 0-53 现在是今年的第几个星期


## shell 函数
 
* 函数传参
* if 语句
* while 语句
* for 循环语句
* case 语句
* 结束语句 break continue exit


### 函数

定义函数:
function test()
{
    command1 $1
    command2 $2
    [return x]
}
test 1 2 3

$1 就是1 $2就是2 $3就是3 $0就是脚本本身 **当参数大于10后 需要使用${n}来获取参数**
$? 为命令退出后返回值 0表示没有错误 其他表示有错误 
$# 脚本参数个数
$@ 脚本的所有参数列表
$$ 脚本运行的当前进程ID号
* return 为函数结束返回的值 不设置则将最后一条命令运行结果作为返回值

### if 语句

* if 语句
  if 表达式
  then
      command1
      command2
  fi
* if else语句
  if 表达式
  then
     command1
     command2
  else
     command3
  fi
* if elif 语句
  if 表达式
  then
      command1
      command2
  elif 表达式2
  then
      command3
  else
      command4
  fi


* 快捷if  [ -f "/etc/shadow" ] && echo "exist" #/etc/shadow为文件就打印exist

### while 语句

while 表达式
do
    command1
done

while[[1]]
do
    echo "test"
done

### for 循环

```BASH
* for i in 1 2 3
  do
      echo $i
  done

* for i in `seq 1 5`
  do
      echo $i
  done

* for((i=0;i<=5;i++))
  do 
      echo $i
  done

```

### case 语句
 
case $a in
[a-z]|[A-Z])
echo "character"
;;
[0-9])
echo "num"
;;
*)
echo "$1"
esac

## 结束语句

break:结束并退出循环

continue:在循环中不执行continue下面的代码，转而进入下一轮循环

exit：退出脚本，
常带一个整数给系统，如 exit 0

return
在函数中将数据返回
或返回一个结果给调用函数的脚本

## 文件包含

* 输入输出重定向
* 文件包含

### 输入输出重定向

command > file	将输出重定向到 file。
command < file	将输入重定向到 file。
command >> file	将输出以追加的方式重定向到 file。
n > file	将文件描述符为 n 的文件重定向到 file。
n >> file	将文件描述符为 n 的文件以追加的方式重定向到 file。
n >& m	将输出文件 m 和 n 合并。
n <& m	将输入文件 m 和 n 合并。
"<< tag	将开始标记 tag 和结束标记 tag 之间的内容作为输入。"

example:
 command > file 2>&1 标准输出和错误输出到file中
 command > /dev/null 2>&1


### 文件包含

定义:
. filename
或者
source filename
然后就可以在filename1文件引用filename文件的内容
