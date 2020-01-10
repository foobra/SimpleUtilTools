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



SDK_PATH=$HOME/Desktop/ios_frameworks/$SDK_NAME

if [ -d "$SDK_PATH" ]; then
  rm -rf $SDK_PATH
fi

mkdir -p $SDK_PATH || true




xcodebuild build -project $PROJECT_FULL_PATH -scheme $SDK_NAME -configuration $CONF -sdk iphonesimulator -arch x86_64 BUILD_DIR=${SDK_PATH}
xcodebuild build -project $PROJECT_FULL_PATH -scheme $SDK_NAME -configuration $CONF -sdk iphoneos -arch armv7 -arch arm64 BUILD_DIR=${SDK_PATH}



ARM_SDK_PATH=""
X86_SDK_PATH=""


if [ -d "${SDK_PATH}/${CONF}-iphoneos/${SDK_NAME}" ]; then
  cd "${SDK_PATH}/${CONF}-iphoneos/${SDK_NAME}"
  TARGET_NAME=`basename $(find . -name \*.framework -type d -maxdepth 1 -print | head -n1) | cut -d "." -f1`
  cd -
fi


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





# cd $X86_SDK_PATH/..
# path=`echo *.framework`
# name=`echo *.framework | cut -d "." -f1`

# plutil -insert CFBundleSupportedPlatforms.1 -string iPhoneOS $X86_SDK_PATH/Info.plist

if [ -d "${ARM_SDK_PATH}/Modules/${TARGET_NAME}.swiftmodule" ]; then
   cp -R ${ARM_SDK_PATH}/Modules/${TARGET_NAME}.swiftmodule/* $X86_SDK_PATH/Modules/${TARGET_NAME}.swiftmodule/
fi

lipo -create $ARM_SDK_PATH/$TARGET_NAME \
             $X86_SDK_PATH/$TARGET_NAME \
             -output $SDK_PATH/$TARGET_NAME

cp -f $SDK_PATH/$TARGET_NAME $X86_SDK_PATH/$TARGET_NAME
rm -rf $SDK_PATH/$TARGET_NAME


mkdir -p $SDK_PATH/universal
cp -R ${X86_SDK_PATH} $SDK_PATH/universal/
cp -R ${X86_SDK_PATH}/../*.bundle $SDK_PATH/universal/
cp -R ${ARM_SDK_PATH}/Info.plist $SDK_PATH/universal/${TARGET_NAME}.framework/Info.plist

