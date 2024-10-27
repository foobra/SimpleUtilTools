#!/bin/bash

# 检查是否提供了目录参数
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# 设置输入目录
input_dir="$1"

# 切换到输入目录
cd "$input_dir" || { echo "Directory not found: $input_dir"; exit 1; }

#!/bin/bash

# 使用 Python 读取 Git 追踪的文件和 LFS 文件，并计算差集
non_lfs_files=$(python3 - <<EOF
import subprocess

# 获取 Git 追踪的文件列表
tracked_files = set(subprocess.check_output(['git', 'ls-files']).decode().splitlines())

# 读取 .gitattributes 文件并提取 LFS 文件路径
lfs_files = set()
with open('.gitattributes', 'r') as f:
    for line in f:
        if ' filter=lfs diff=lfs merge=lfs -text' in line:
            # 仅添加文件路径部分
            lfs_files.add(line.split()[0])

# 计算差集：tracked_files - lfs_files
non_lfs_files = tracked_files - lfs_files

# 输出每个非 LFS 文件路径在新行上
print("\n".join(non_lfs_files))
EOF
)

# 每行输出一个文件
# echo "$non_lfs_files" | while IFS= read -r file; do
#   echo "$file"
# done



# 获取 CPU 核心数量
cpu_cores=$(nproc)

# 并发检查非 UTF-8 编码文件
python3 - <<EOF
import subprocess
from concurrent.futures import ThreadPoolExecutor

# 定义检查函数
def check_non_utf8(file):
    try:
        # 执行 iconv 检查
        subprocess.run(['iconv', '-f', 'utf-8', '-t', 'utf-16', file],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except subprocess.CalledProcessError:
        print(f"{file} - is non-UTF8!")

# 从 Bash 传入的文件列表
files = """$non_lfs_files""".splitlines()

# 使用线程池进行并发检查
with ThreadPoolExecutor(max_workers=$cpu_cores) as executor:
    executor.map(check_non_utf8, files)
EOF
