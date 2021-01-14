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



#SDK_PATH=$HOME/Desktop/mac_frameworks/$SDK_NAME
SDK_PATH=$HOME/Desktop/mac_frameworks
SDK_FULL_PATH=$HOME/Desktop/mac_frameworks/$SDK_NAME

if [ -d "$SDK_FULL_PATH" ]; then
  rm -rf $SDK_FULL_PATH
fi

mkdir -p $SDK_PATH || true
mkdir -p $SDK_PATH/$SDK_NAME || true
mkdir -p $SDK_FULL_PATH || true




xcodebuild build -project $PROJECT_FULL_PATH -scheme $SDK_NAME -configuration $CONF -arch x86_64 BUILD_DIR=${SDK_PATH}

if [ $? -ne 0 ]; then
    echo "compile failed"
    exit 1
fi




# X86_SDK_PATH=""


# if [ -d "${SDK_PATH}/${CONF}/${SDK_NAME}" ]; then
#   cd "${SDK_PATH}/${CONF}/${SDK_NAME}"
#   TARGET_NAME=`basename $(find . -name \*.framework -type d -maxdepth 1 -print | head -n1) | cut -d "." -f1`
#   cd -
# fi



# if [ -d "${SDK_PATH}/${CONF}/${SDK_NAME}/${TARGET_NAME}.framework" ]; then
#    X86_SDK_PATH=${SDK_PATH}/${CONF}/${SDK_NAME}/${TARGET_NAME}.framework
# else
#    X86_SDK_PATH=${SDK_PATH}/${CONF}/${TARGET_NAME}.framework
# fi





# cd $X86_SDK_PATH/..
# path=`echo *.framework`
# name=`echo *.framework | cut -d "." -f1`

# plutil -insert CFBundleSupportedPlatforms.1 -string iPhoneOS $X86_SDK_PATH/Info.plist

# if [ -d "${X86_SDK_PATH}/Modules/${TARGET_NAME}.swiftmodule" ]; then
#    cp -R ${X86_SDK_PATH}/Modules/${TARGET_NAME}.swiftmodule/* $X86_SDK_PATH/Modules/${TARGET_NAME}.swiftmodule/
# fi

