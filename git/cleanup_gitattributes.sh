#!/usr/bin/env bash

while read line
do
    file=`echo ${line} | grep -e "\(.\+\.\w\+\) " -o`
    file2=`pwd`/${file}

    if [ -f $file2 ];then
        echo ${line} >> .gitattributes.bak
    fi
done < .gitattributes

rm -rf .gitattributes

mv .gitattributes.bak .gitattributes

