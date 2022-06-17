#!/usr/bin/sh

array=()

cd $1
for i in *.a; do
	array+=("$i")    
done
cd -


PATHS=()
for path in $*                     
do
	PATHS+=("$path")
done



for(( i=0;i<${#array[@]};i++)) do
	CMD="lipo -create "
	for(( j=0;j<${#PATHS[@]};j++)) do
		CMD+="${PATHS[j]}"
		CMD+="/"
		CMD+="${array[i]}"
		CMD+=" "
	done

	CMD+=" -output $HOME/Desktop/${array[i]} "
	eval $CMD
done;



