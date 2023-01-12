#!/usr/bin/env bash

OLDIFS="$IFS"
IFS=$'\n'
SPACE_CHAR="[[:space:]]"

while read line
do
    file=`echo ${line} | grep -o -e ".* filter=lfs" | grep -o -e "\([^ ]\+\) "`
    file2=`pwd`/${file}
    file3=$(echo "$file2" | xargs) 
    file4=${file3//"$SPACE_CHAR"/ }

    if test -f "$file4"; then
        echo ${line} >> .gitattributes.bak
    fi
done < .gitattributes

if [ -f .gitattributes.bak ];then
  rm -rf .gitattributes
  mv .gitattributes.bak .gitattributes
fi



