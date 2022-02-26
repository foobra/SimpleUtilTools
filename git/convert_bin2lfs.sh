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
    "json"|"csv")
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


FILES=`find . -type f -not -path "./.git/*"`

for FILE in $FILES  
do
    non_text_file=`find_wrong_files "${FILE}"`
    if [[ ! -z $non_text_file ]]; then
      REAL_FILE=`git check-ignore $FILE`
      if [ -z "$REAL_FILE" ]; then
          TRACKED=`git check-attr --all -- $FILE | grep "filter: lfs"`
          if [ -z "$TRACKED" ];then
              git lfs track $FILE
          fi
      fi
    fi
done  
