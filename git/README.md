终端执行的意思是, mac/linux电脑打开终端应用, windows电脑则是在资源管理器中, 右键, 选择 Git Bash.

0. Windows用户先安装 Git for Windows, https://git-scm.com/download/win. 现在最新的git, 都直接包含 git lfs. 如果需要使用单独git lfs, 请安装lfs https://github.com/git-lfs/git-lfs/releases
1. git配置 (每个用户执行一次)
    1. 终端执行 git config --global user.name gs(这里换成自己的名字拼音, 或者拼音缩写 例如gaoshan or gs)
    2. 终端执行 git config --global user.email xxx@xxx.com (自己的邮箱)
    3. 如果 user.name 包含中文等非ASCII字符, 需要额外设置: git config --global user.alias gs (设置一个ASCII别名, 用于分支命名)
2. update config (每个用户只需要执行一次)
    1. cd $HOME && (git clone https://github.com/foobra/SimpleUtilTools.git || true) && cd SimpleUtilTools && git pull && sh $HOME/SimpleUtilTools/update/init_setup.sh
    2. 如果使用zsh, 记得屏蔽zsh的git插件
3. daily use
    1. 创建新分支 gnb master(这个是主分支名字, 大家根据实际的分支名修改)
    2. 拉取代码  gl
    3. 推送代码 gh (每次gh的时候系统会自动打开浏览器, 发起一个merge request, 这个时候只需要点击create按钮就可以了, 如果报错不用管直接忽略)
    4. 以后升级脚本, 就执行终端命令 update_tools

