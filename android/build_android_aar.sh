#!/bin/sh

SDK_NAME=$1
CONF=""
if [[ "$2" == "Debug"  || "$2" == "debug" ]] ;then
    echo "build debug framework"
    CONF="Debug"
else
    echo "build release framework"
    CONF="Release"
fi

PROJECT_FULL_PATH=$3

MODULE_FULL_PATH=""
if [ -z "$4" ]
  then
    MODULE_FULL_PATH=$3
else
	MODULE_FULL_PATH=$4
fi



SDK_PATH=$HOME/Desktop/android_aars/$SDK_NAME


rm -rf $SDK_PATH || true
mkdir -p $SDK_PATH || true
mkdir -p $SDK_PATH/aar/


cd $PROJECT_FULL_PATH
rm -rf $MODULE_FULL_PATH/$SDK_NAME/build/ || true
chmod +x gradlew
./gradlew :$SDK_NAME:clean && ./gradlew :$SDK_NAME:assemble${CONF}

cp -f $MODULE_FULL_PATH/$SDK_NAME/build/outputs/aar/*.aar $SDK_PATH/aar/


