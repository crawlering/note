#!/bin/bash
#请创建/data/backup文件夹和挂载文件夹/data/nfstest
# logile: /tmp/messages
# 
#
#

time_data=`date +%Y%m%d%H%M%S`
file_tar="/home/nfstest"
log_file="/tmp/messages"
backup_site="/data/backup"
host_nfs="192.168.200.165"
remote_nfs_file="/home/nfsdir"
local_nfs_file="/data/nfstest"
function mount_Judge()

{
    judge_nfs=`df -h | grep nfsdir | wc -l`
    if (($judge_nfs))
    then
        echo "${time_data}:1 nfs already mount" >> ${log_file}
        return 1
    fi
    return 0

}

# mount成功后执行下一步，不成功每分钟执行一次mount 10次后 停止mount并且提示检查mount，后面的打包任务终止
# mount 之前做服务在线监测，不在线不进行mount直接计数
function mount_Nfs()
{
    judge_counts=1
    while((1))
    do
        
        ping ${host_nfs} -W1 -c1 2>&1 > /dev/null
    
        if [ $? -eq 0 ] 
        then
            mount -t nfs ${host_nfs}:${remote_nfs_file} ${local_nfs_file}
    	    if [ $? -eq 0 ]
    	    then
    	        echo "${time_data}:0 nfs mount success" >> ${log_file}
    	        return 0
    	    fi
        fi
    let judge_counts+=1
    
    if [ $judge_counts  -eq 10 ];then
        echo "${time_data}:1 many mount faild,please check!!! " >> ${log_file}
        exit 1
    
    fi

    sleep 60
    done

    
}

#最后一步 执行umount操作，如果umount成不成功不做监测
function unmount_Nfs()
{
    umount /data/nfstest
}

function compression_File()
{
    cd /data/
    tar -zcvf ${backup_site}/${time_data}.nfs.tar.gz nfstest/
    [ $? -eq 0 ] && echo "${time_data}: tar file success" >> $log_file || echo "${time_data}: tar file failed" \
>> ${log_file}
    
}


#程序 执行

##监测mount情况
mount_Judge
if [ $? -eq 0 ]
then
    mount_Nfs
fi
compression_File
unmount_Nfs

