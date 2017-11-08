#!/bin/bash
##############################################################
# File Name: 30-3.sh
# Version: V1.0
# Author: li jiansheng
# Blog: http://shengge520.blog.51cto.com/
# Created Time : 2017-11-06 15:19:17
# Description:
##############################################################
. /etc/init.d/functions
dbfile=/tmp/dbfile
[ -f /$dbfile ] || touch dbfile
for i in oldboy{01..10}
do
    useradd $i &>/dev/null
    if [ $? -eq 0 ];then
      action "创建新用户$i" /bin/true
    else
      action "创建新用户$i" /bin/false
      continue
    fi
    uuid=`uuidgen|cut -c -8`
    echo $uuid|passwd --stdin $i &>/dev/null
    echo "$i:$uuid" >>$dbfile
done
