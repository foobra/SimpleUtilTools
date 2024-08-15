#!/bin/sh

if [ -z "$1" ]; then
	echo "Usage: convert_feishu_word.sh md_path"
	return
fi


 # 获取当前工作目录
 script_dir=$(pwd)

    # 提取文件名和路径
    filename=$(basename "$1")
    dirname=$(dirname "$1")
    
    # 去掉文件名的扩展名（如果有的话）
    filename_no_ext="${filename%.*}"

    mkdir -p $script_dir/$dirname/pandoc_generated/

    
    # 使用 pandoc 转换，并指定资源路径为文件夹路径
    pandoc  "$1" -o "$script_dir/$dirname/pandoc_generated/$filename_no_ext.docx" --resource-path="$script_dir/$dirname"

    

