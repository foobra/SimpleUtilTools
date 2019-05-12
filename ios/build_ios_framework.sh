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

TARGET_NAME=""
if [ "$#" -eq 4 ]; then
    TARGET_NAME=$4
else
    TARGET_NAME=$SDK_NAME
fi


# PROJECT_PATH=`echo $PROJECT_FULL_PATH | grep -o '^.*[/]'`
# PROJECT_NAME=`echo $PROJECT_FULL_PATH | grep -o '[^/]*$' | cut -d '.' -f1`


SDK_PATH=$HOME/Desktop/ios_frameworks/$SDK_NAME


rm -rf $SDK_PATH || true
mkdir -p $SDK_PATH || true
mkdir -p $SDK_PATH/universal/



xcodebuild clean build -project $PROJECT_FULL_PATH -scheme $SDK_NAME -configuration $CONF -sdk iphonesimulator -arch x86_64 BUILD_DIR=${SDK_PATH}
xcodebuild clean build -project $PROJECT_FULL_PATH -scheme $SDK_NAME -configuration $CONF -sdk iphoneos -arch armv7 -arch arm64 BUILD_DIR=${SDK_PATH}



ARM_SDK_PATH=""
X86_SDK_PATH=""

if [ -d "${SDK_PATH}/${CONF}-iphoneos/${SDK_NAME}/${TARGET_NAME}.framework" ]; then
   ARM_SDK_PATH=${SDK_PATH}/${CONF}-iphoneos/${SDK_NAME}/${TARGET_NAME}.framework
else
   ARM_SDK_PATH=${SDK_PATH}/${CONF}-iphoneos/${TARGET_NAME}.framework
fi

if [ -d "${SDK_PATH}/${CONF}-iphonesimulator/${SDK_NAME}/${TARGET_NAME}.framework" ]; then
   X86_SDK_PATH=${SDK_PATH}/${CONF}-iphonesimulator/${SDK_NAME}/${TARGET_NAME}.framework
else
   X86_SDK_PATH=${SDK_PATH}/${CONF}-iphonesimulator/${TARGET_NAME}.framework
fi

cp -R ${ARM_SDK_PATH} $SDK_PATH/universal/




cd $SDK_PATH/universal/
path=`echo *.framework`
name=`echo *.framework | cut -d "." -f1`

lipo -create $ARM_SDK_PATH/$TARGET_NAME \
             $X86_SDK_PATH/$TARGET_NAME \
             -output $SDK_PATH/$TARGET_NAME
cp -f $SDK_PATH/$TARGET_NAME $SDK_PATH/universal/$TARGET_NAME.framework/$TARGET_NAME

rm -rf $SDK_PATH/$TARGET_NAME || true
