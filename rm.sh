#!/bin/bash
d=`date +%Y%m%d%H%M`
read -p "Are you sure delete the file or directory $1? y|n:"  c
if [ $c == "y" ] || [ $c == "Y"]
then
      mkdir /data/.$d
      rsync -aR $1/   /data/.$d
      /bin/rm -rf $1
elif [ $c == "n"] || [ $c == "N"]
then
      exit 0
else
     echo "Please input y or n"
fi
