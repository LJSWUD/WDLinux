#!/bin/bash
##############################################################
# File Name: /server/scripts/user.sh
# Version: V1.0
# Author: li jiansheng
# Blog: http://shengge520.blog.51cto.com/
# Created Time : 2017-11-01 11:29:59
# Description:
##############################################################
#!/bin/bash
###测试权限###
ls /root/ &> /dev/null
[ $? -ne 0 ]&&echo -e "\e[1;31m需要root权限~\e[0m"&&exit
###创建用户###
while true
do
    read -p "请输入新建用户名:" user
    if [ -z $user ];then
        continue
    fi
    echo $user|egrep [^a-Z0-9_-]+ > /dev/null 2>&1
    if [ $? == 1 ];then
        read -p "批量创建用户数(0或1为单用户):" num
        while true
        do
            echo $num|egrep [^0-9]+ > /dev/null 2>&1
            if [ $? == 1 ];then
                if [ $num == 0 -o $num == 1 ];then
                    for p in `awk -F ":" '{print $1}' /etc/passwd`
                    do
                        if [ $p == $user ];then
                        clear
                        echo "用户已存在，请重新输入!"
                        break 2 
                        fi
                    done
                    useradd $user > /dev/null 2>&1
                    echo -e "\e[1;31m用户创建成功!\e[0m"
                    while true
                    do
                        read -p "是否需要创建密码?(y/n)" yn
                        if [ $yn == "y" ];then
                            read -p "(1)手动个人密码;(2)系统随机密码:" m
                            if [ $m == 1 ];then
                                read -sp "请输入你的密码:" pd
                                echo "$pd" | passwd --stdin $user > /dev/null 2>&1
                                echo
                                echo -e "\e[1;31m密码创建成功!\e[0m"
                                echo "$user:$pd" >> /root/userpasswd.txt
                                exit
                            elif [ $m == 2 ];then
                                spd=`openssl rand -hex 4`
                                echo "$spd" | passwd --stdin $user > /dev/null 2>&1
                                echo -e "\e[1;31m密码创建成功!\e[0m"
                                echo -e "\e[1;31m你的随机密码为:$spd,请注意保存!\e[0m"
                                echo "$user:$spd" >> /root/userpasswd.txt
                                exit
                            fi
                        elif [ $yn == "n" ];then
                            echo "退出!"
                            exit
                        fi
                    done
                else 
                    for i in `seq -w $num`
                    do
                        ur1=`echo $user$i`
                        for ur2 in `awk -F ":" '{print $1}' /etc/passwd`
                        do
                            if [ $ur1 == $ur2 ];then
                                echo -e "\e[1;31m${ur1}已存在!\e[0m"
                                read -p  "是否还继续创建用户(任意键继续/n退出):" nn
                                if [ $nn == n  ];then
                                    break 3
                                fi
                            fi
                        done
                        useradd $ur1 > /dev/null 2>&1
                    done
                    echo -e "\e[1;31m批量用户创建成功!\e[0m"   
                    read -p "是否需要创建密码?(y/n)" ny
                        if  [ $ny == "y" ];then
                            read -p "(1)手动批量密码;(2)系统随机密码:" pm 
                            if [ $pm == 1 ];then
                                read -sp "请输入批量密码:" dd
                                    for j in `seq -w $num`
                                    do
                                        us=`echo $user$j`
                                        echo "$dd" | passwd --stdin $us > /dev/null 2>&1
                                        echo "$us:$dd" >> /root/userpasswd.txt
                                    done
                                echo -e "\e[1;31m密码创建成功!\e[0m"
                                exit
                            elif [ $pm == 2 ];then
                                for l in `seq -w $num`
                                do
                                    spdd=`openssl rand -hex 4`
                                    us1=`echo $user$l`
                                    echo "$spdd" | passwd --stdin $us1 > /dev/null 2>&1
                                    echo "$us1:$spdd" >> /root/userpasswd.txt
                                done
                                echo -e "\e[1;31m密码创建成功!\e[0m"
                                exit
                            fi
                        fi
                    fi
                    break 2
                else
                    read -p  "请出入正确数字:" num
                fi
            done
    else
        clear
        echo "含有特殊字符，请重新输入！"
    fi
done
