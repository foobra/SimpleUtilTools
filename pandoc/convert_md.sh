#!/bin/sh

# echo "Please Install pandoc, word, docx2pdf"

if [ -z "$1" ]; then
    echo "Usage: convert_md md_path"
    return
fi


BASEDIR=$(dirname "$1")
echo $BASEDIR

filename_full=$(basename -- "$1")
# extension="${filename##*.}"
filename="${filename_full%.*}"
echo $filename

mkdir -p $BASEDIR/pdf || true
mkdir -p $BASEDIR/docx || true

pandoc -i "$1" --reference-doc ~/SimpleUtilTools/pandoc/templ.docx -o $BASEDIR/docx/$filename.docx -N --resource-path $BASEDIR