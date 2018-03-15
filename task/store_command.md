# 命令审计

* 编辑添加以下内容:/etc/profile

```BASH
if [ ! -d  /usr/local/records/${LOGNAME} ]
then
mkdir -p /usr/local/records/${LOGNAME}
chmod 300 /usr/local/records/${LOGNAME}
fi
export HISTORY_FILE="/usr/local/records/${LOGNAME}/bash_history"
export PROMPT_COMMAND='{ date "+%Y-%m-%d %T ##### $(who am i |awk "{print \$1\" \"\$2\" \"\$5}") #### $(history 1 | { read x cmd; echo "$cmd"; })"; } >>$HISTORY_FILE'
readonly PROMPT_COMMAND
```

* readonly PROMPT_COMMAND:把变量变成只读变量，防止用户 在命令端对PROMPT_COMMAND赋值，导致命令保存失效
