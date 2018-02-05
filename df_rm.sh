#!/bin/bash
d=`date +%Y%m%d%H%M`
##将日期命令的执行结果赋值给变量$d
 
f_size=`du -sk $1 |awk '{print $1}'`
##du -sk $1 是以kb为单位列出$1的大小总和.结果为 大小  文件名 如:4   1.txt
##所以只打印管道符前命令的结果的第一段,也就是  大小 文件名的第一段,  大小
##将运行结果赋值给变量$f_size
 
disk_size=`LANG=en; df -k |grep -vi filesystem |awk '{print $4}' |sort -n |tail -n1`
##LANG=en为显示语言为英文，df -k是查看已挂载磁盘的总容量，使用容量，剩余容量
##awk '{print $4}'打印第四段，因df -k 显示的排序为 文件系统（filesystem），块，已用，可用
##sort -n 使用纯数字排序，从小到大
##tail -n1 打印最后一行
##整段代码的含义就是，将最大的可用内存打印出来，赋值给变量disk_size
 
big_filesystem=`LANG=en; df -k |grep -vi filesystem |sort -n -k4 |tail -n1 |awk '{print $NF}'`
##LANG=en显示语言为英文，df -k 查看已挂载磁盘的总容量，使用容量，剩余容量
##grep -vi 不区分大小写打印不包括 filesystem的行
##tail -n1 打印最后一行
##打印最后一个段，也就是挂载点名称
##h整段代码是将最大可用内存的挂载点名称打印出来，赋值给变量$big_filesystem
 
if [ $f_size -lt $disk_size]
##判断$f_size的值 是否小于 $disk_size的值，如果小于则执行
then
   read -p "Are you sure delete the file or directory:$1? y|n:" c
##将输入的内容赋值给变量$c
   if [ $c == "y"] || [ $c == "Y"]
##判断 $c的值是否全等于 y或Y
   then
      mkdir -p $big_filesystem/.$d && rsync -aR $1 $big_filesystem/.$d/ && /bin/rm -rf $1
##mkdir -p 级联创建目录，最大剩余挂载点/日期，rsync -R是连同目录一同同步，
##整段就是在最大挂载点下创建以日期为名称的文件夹，使用rsync命令一同同步，最后删除$1文件
   elif [ $c == "n"] || [ $c == "N"]
##判断变量$c的值是n或N，则退出
   then
      exit 0
   else
        echo "please input y or n"
##如果$c的值不等于y，Y，n，N，则输出 please input y or n
   fi
else
   echo "the disk size is not enough to backup the files $1"
##变量$f_size的值不小于$disk_size的值，则执行下面命令
   read -p "Do you want to delete $1? y|n:" c
   if [ $c == "y"] || [ $c == "Y"]
##$c=y|Y
   then
      echo "it will delete $1 after 10 seconds whitout bachup."
##则输出
      for i in `seq 1 10`
##for循环，1到10，10次循环
      do
      echo -ne "="
##echo -ne不换行输出 =
      sleep 1
##sleep 1延迟1秒
      done
   echo
     /bin/rm -rf $1
##删除$1文件
   elif [ $c == "n"] || [ $c == "N"]
##$c =n|N
   then
     echo "it will not delete $1"
##则输出 it will not delete。。
     exit 0
##退出
   else
##以上情况不存在，则输出
      echo "Please input y or n"
   fi
fi
