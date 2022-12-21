#!/bin/sh

# $1 json schema
# $2 json type name
# $3 ue module name
# $4 json cpp location

sedi=(-i)
case "$(uname)" in
  # For macOS, use two parameters
  Darwin*) sedi=(-i "")
esac


OLD_PWD=`pwd`

cat ~/SimpleUtilTools/ue-json/template.yaml > ~/Desktop/temp_ue_json.yaml

echo "\n    $2:\n" >> ~/Desktop/temp_ue_json.yaml


node /usr/local/lib/node_modules/@openapi-contrib/json-schema-to-openapi-schema/bin/json-schema-to-openapi-schema.js \
convert  "$1" | yq -P | sed 's/^/      /' >> ~/Desktop/temp_ue_json.yaml


mkdir -p "$4" || true

openapi-generator generate -i ~/Desktop/temp_ue_json.yaml  \
--additional-properties cppNamespace=,unrealModuleName=$3 \
--global-property models \
-g cpp-ue4 -o "$4"

cd $4

cd Public

CURRENT=`pwd`
for i in *.h; do
    [ -f "$i" ] || break
    FILE_NAME="${i%.*}"
    FULL_PATH="$CURRENT/$i"

    vi \
    -c ":%s/\t/    /g" \
    -c ":%s/: public Model/: public UJsonModelUE" \
    -c ":%s/ \*\/\nclass/ \*\/\rUCLASS\(BlueprintType\)\rclass" \
    -c ":%s/namespace/#include \"$FILE_NAME.generated.h\"\r\rnamespace" \
    -c ":%s/namespace *\n{//g" \
    -c ":%s/double/float/g" \
    -c ":%s/OpenAPIBaseModel\.h/OpenAPIHelpers.h" \
    "+wq" "$FULL_PATH"

    vi \
    -c ":%s/\([^\"]\)OpenAPI\(\w\+\)/\1UOpenAPI\2*/g" \
    -c ":%s/\* : public UJsonModelUE/ : public UJsonModelUE/g" \
    -c ":%s/\/UOpenAPITools\*\//\/OpenAPITools\//g" \
    -c ":%s/\~\(\w\+\)\*() {}/\~\1() {}/g" \
    "+wq" "$FULL_PATH"


    vi \
    -c ":%s/public:/GENERATED_BODY\(\)\r\rpublic:" \
    -c ":%s/^\( \+[a-zA-Z0-9_<>\*]\+ \w\+;\)$/\r    UPROPERTY\(EditAnywhere, BlueprintReadWrite\)\r\1/g" \
    -c ":%s/^\( \+[a-zA-Z0-9_<>\*]\+ \w\+ = \w\+;\)$/\r    UPROPERTY\(EditAnywhere, BlueprintReadWrite\)\r\1/g" \
    -c ":%s/UPROPERTY(EditAnywhere, BlueprintReadWrite) *\n \+TOptional/TOptional/g" \
    -c ":%s/UPROPERTY(EditAnywhere, BlueprintReadWrite) *\n \+TSharedPtr/TSharedPtr/g" \
    -c ":%s/TOptional<\(.*\)> \+\(.*\);/TOptional<\1> \2;\r    UFUNCTION(BlueprintCallable)\r \r    \1 GetOptional\2(bool \&ret) \r    {\r      return GetOptionalValue(ret, \2);\r    };\r /g" \
    -c ":%s/ \+UFUNCTION(BlueprintCallable)\n\/\/ clang-format off\n \+TSharedPtr<FJsonObject>.*$/\/\/ clang-format off/g" \
    -c ":%s/ \+UFUNCTION(BlueprintCallable)\n\/\/ clang-format off\n \+TSharedPtr<FJsonValue>.*$/\/\/ clang-format off/g" \
    "+wq" "$FULL_PATH"





    sed "${sedi[@]}" '$ d' "$FULL_PATH"
    sed "${sedi[@]}" '$ d' "$FULL_PATH"

done

cd ../Private


CURRENT=`pwd`
for i in *.cpp; do
    [ -f "$i" ] || break
    FILE_NAME="${i%.*}"
    FULL_PATH="$CURRENT/$i"

    vi \
    -c ":%s/#include \"$3Module.h\"/" \
    -c ":%s/namespace *\n{//g" \
    -c ":%s/\([^\"]\)OpenAPI/\1UOpenAPI/g" \
    -c ":%s/&= TryGetJsonValue\(.*\));$/\&= TryGetJsonValue\1, this);/g" \
    "+wq" "$FULL_PATH"

    sed "${sedi[@]}" '$ d' "$FULL_PATH"
    sed "${sedi[@]}" '$ d' "$FULL_PATH"

done


cd "$OLD_PWD"