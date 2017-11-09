#!/bin/bash
##############################################################
# File Name: /server/scripts/lvs_server.sh
# Version: V1.0
# Author: li jiansheng
# Organization: http://shengge520.blog.51cto.com/
# Created Time : 2017-11-09 19:10:47
# Description:
##############################################################
. /etc/init.d/functions
VIP=(
10.0.0.3
)
RS=(
10.0.0.7:80
10.0.0.8:80
)
VIRS=10.0.0.3:80
#create function  测试用户权限够不够
function Jurisdiction(){
    if [ $UID -ne 0 ];then
       echo "没有权限，请增加权限或者切换root"
       exit 1
    else 
       action "权限足够" /bin/true
    fi
}
#create function 测试ipvsadm是否存在
function IPvs(){
    lsmod |grep ip_vs &>/dev/null
    [ $? -eq 0 ] && echo "ipvsadm已安装" || yum -y install ipvsadm
    return 1
}
#create function 在网卡0中绑定VIP地址
function IP_add(){
    ip a |grep 10.0.0.3/24 &>/dev/null
    if [ $? -ne 0 ] ;then
      ip addr add $VIP dev eth0
      action "添加VIP $VIP 成功" /bin/true
    else
      echo "$VIP 已经存在" 
    fi
}

#create function 清除当前所有LVS规则
function clean(){
    ipvsadm -C &>/dev/null
    if [ $? -eq 0 ] ;then
       action "清除当前所有的LVS规则" /bin/true
    else
       action "清除当前所有的LVS规则" /bin/false
       exit
    fi
}
#create function 设置tcp、tcpfin、udp链接超时时间
function Set(){
    ipvsadm --set 30 5 60 &>/dev/null
    if [ $? -eq 0 ] ;then
      action "设置时间成功" /bin/true
    else
      action "设置时间成功" /bin/false
    fi
}  

#create function 添加虚拟服务
function VS(){
    lvs_tab=$(ipvsadm -ln|grep "VIRS"|wc -l) &>/dev/null
    if [ ${lvs_tab} -eq 1 ];then
       echo "虚拟服务已经存在"
    else
       ipvsadm -A -t $VIRS -s wrr -p 20 &&\
       action "虚拟服务添加成功" /bin/true
       return 2
    fi
}
#create function 将虚拟服务关联到真实服务上(-a)
function Relation(){
    for ip in ${RS[@]}
    do
      RS1=`ipvsadm -ln|grep "$ip"|wc -l`
      if [ ${RS1} -eq 1 ]; then
        echo "$ip已存在"
      else
        ipvsadm -a -t $VIRS -r $ip -g -w 1 &&\
        action "关联$ip成功" /bin/true
      fi
    done
}
#create function start LVS
function start(){
	Jurisdiction
	IPvs
	IP_add
	clean
	Set
	VS
	Relation
}
#create function 删除eth0网卡绑定VIP地址
function IP_del(){
    ip a|grep 10.0.0.3/24 &>/dev/null
    if [ $? -ne 0 ]；then
       echo "without vip $VIP"
    else
       ip addr del $VIP dev eth0
       action "清除VIP$VIP成功" /bin/true
    fi
}
#create function清除当前所有LVS规则
function Clean(){
    ipvsadm -C &>/dev/null
    if [ $? -eq 0 ]; then
      action "清除当前所有LVS规则" /bin/true
    else
      action "清除当前所有LVS规则" /bin/false
      exit
    fi
}
#create function  关闭LVS服务
function stop(){
	IP_del
	Clean
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    stop
    sleep 2
    start
    ;;
*)
    echo -e "\033[31m USAGE: sh $0 start|stop|restart| \033[0m"
    ;;
esac
