#!/bin/bash
xtime=`date +%D\ %T`	
ip_nfs="192.168.200.167"

judge_nfs=`df -h | grep nfsdir | wc -l`
if (($judge_nfs))
then
    echo "${xtime} nfs already mount" >> /tmp/messages
    exit 0
fi

while((1))
do
    xtime=`date +%D\ %T` 
    ping $ip_nfs -W1 -c1 2>&1 > /dev/null

    if [ $? -eq 0 ] 
    then
        mount -t nfs 192.168.200.165:/home/nfsdir /data/nfstest
	if [ $? -eq 0 ]
	then
	    echo "${xtime} nfs mount success" >> /tmp/messages
	    exit 0
	fi
    fi
sleep 60
done
