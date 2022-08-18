#!/bin/bash


OLDIFS="$IFS"
IFS=$'\n'



function find_wrong_files() {
  for FILE in "$@"; do
    local FILE_TYPE
    FILE_TYPE=$(file --mime-type "$FILE" | grep -o -e ": .\+$" | cut -b 3-)
    if ! is_text "$FILE_TYPE"; then
      echo "$FILE"
    fi
  done
}

function is_text() {
  FILE_TYPE=$1
  local MAIN_TYPE=${FILE_TYPE%%/*}
  local SUB_TYPE=${FILE_TYPE##*/}

  case "$MAIN_TYPE" in
  "text")
    return 0
    ;;
  "inode")
    case "$SUB_TYPE" in
    "x-empty"|"directory"|"symlink")
      return 0
      ;;
    esac
    ;;
  "application")
    case "$SUB_TYPE" in
    "json"|"csv"|"xml"|"xhtml+xml"|"x-sh")
      return 0
      ;;
    esac
    ;;
  "image")
    case "$SUB_TYPE" in
    "svg+xml")
      return 0
      ;;
    esac
    ;;
  esac
  return 1
}


FILES=()
declare -a BIN_FILES
BIN_FILES=("")

if [ -z "$1" ]; then
  FILES=`git ls-files`
else
  FILES=`git ls-files | grep $1`
fi


for FILE in $FILES  
do
  non_text_file=`find_wrong_files "${FILE}"`
  if [[ ! -z $non_text_file ]]; then
    BIN_FILES=("${BIN_FILES[@]}" $non_text_file)
  fi
done  



for FILE in ${BIN_FILES[@]}
do
  TRACKED=`git check-attr --all -- $FILE | grep "filter: lfs"`
  if [ -z "$TRACKED" ];then
    git lfs track $FILE
  fi
done  
