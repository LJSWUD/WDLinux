#!/bin/bash
##############################################################
# File Name: 30-15.sh
# Version: V1.0
# Author: li jiansheng
# Blog: http://shengge520.blog.51cto.com/
# Created Time : 2017-11-06 15:56:08
# Description:
##############################################################
. /etc/init.d/functions
function Value(){
    prot=`nmap 127.0.0.1 -p  873 |awk 'NR==6{print $2}'`
    rsync_start="systemctl start rsyncd"
    rsync_stop="systemctl stop rsyncd"
    rsync_restart="systemctl restart rsyncd"
    choise=$1
}
function Start(){
    $rsync_start
    [ $? -eq 0 ] && action "启动rsync服务" /bin/true || action "启动rsync服务" /bin/false
}
function Stop(){
    $rsync_stop 
    [ $? -eq 0 ] && action "停止rsync服务" /bin/true || action "停止rsync服务" /bin/false
}
function Restart(){
    $rsync_restart
    [ $? -eq 0 ] && "重启rsync服务" /bin/true || action "重启rsync服务" /bin/false
}
function Case(){
    case "$choise" in
    start)
       Start
       ;;
    stop)
       Stop
       ;;
    restart)
       Restart
       ;;
    *)
       echo -e "\033[31m 请输入 sh $0 start|stop|restart| \033[0m"
       ;;
    esac
}
function main(){
    Value "$@"
    Case
}
main "$@"
