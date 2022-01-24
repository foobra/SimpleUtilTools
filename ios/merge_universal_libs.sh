#!/bin/sh

mkdir -p $HOME/Desktop/merged_libs || true

folder1=$1
folder2=$2
folder3=""

if [ -z "$3" ]
  then
    folder3=""
else
    folder3=$3
fi

cd $1


arr1=()
for i in *.a; do
    [ -f "$i" ] || break
    arr1=(${arr1[@]} ${i})
done

cd $HOME/Desktop/merged_libs/


for element in ${arr1[@]}
do
    exec_cmd="lipo "
    exec_cmd+=" ${folder1}/${element} "
    exec_cmd+=" ${folder2}/${element} "
    if [ ! -z "${folder3}" ]
    then
      exec_cmd+=" ${folder3}/${element} "
    fi

    exec_cmd+=" -create -o $element"
    echo $(eval "$exec_cmd")
done


