#!/usr/bin/sh

array=()

cd $1

mkdir -p merged-ios/lib || true



cd arm-ios/lib
for i in *.a; do
	array+=("$i")    
done


cd -




PATHS=()
PATHS+=(`pwd`"/arm-ios/lib")
PATHS+=(`pwd`"/arm64-ios/lib")
PATHS+=(`pwd`"/x64-ios/lib")



for(( i=0;i<${#array[@]};i++)) do
	CMD="lipo -create "
	for(( j=0;j<${#PATHS[@]};j++)) do
		CMD+="${PATHS[j]}"
		CMD+="/"
		CMD+="${array[i]}"
		CMD+=" "
	done

	CMD+=" -output `pwd`/merged-ios/lib/${array[i]} "
	eval $CMD
done;



