#!/usr/bin/env bash

OLDIFS="$IFS"
IFS=$'\n'

while read line
do
    file=`echo ${line} | grep -o -e ".* filter=lfs" | grep -o -e "\([^ ]\+\) "`
    file2=`pwd`/${file}

    if [ -e "$file2" ];then
        echo ${line} >> .gitattributes.bak
    fi
done < .gitattributes

if [ -f .gitattributes.bak ];then
  rm -rf .gitattributes
  mv .gitattributes.bak .gitattributes
fi



