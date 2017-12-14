1. gitlab install (每个用户执行一次)
    1. windows https://nodejs.org/dist/v8.9.1/node-v8.9.1-x86.msi)
    2. mac https://nodejs.org/dist/v8.9.1/node-v8.9.1.pkg
    3. npm install cli-gitlab -g
    4. 终端执行 git config --global user.name gs(这里换成自己的名字拼音, 或者拼音缩写)
    5. 终端执行 git config user.name gs(这里换成自己的名字拼音, 或者拼音缩写)
2. git config (每个项目都要执行一次)
    0. 终端执行的意思是, mac电脑打开终端应用, windows电脑打开 Git Bash.
    1. 在终端中, 先进入项目目录
    2. 设置url token
        1. 查找到自己的gitlab url 后面备用 http://10.148.68.13
        2. 终端执行 gitlab url http://10.148.68.13
        3. 网页打开 http://10.148.68.13/profile/account 查找到自己的gitlab token
        4. 终端执行 gitlab token xxxx
        5. 终端执行 git config gitlab.url http://10.148.68.13 上面查出来的url
        6. 终端执行 git config gitlab.token xxxxx  上面查出来的 token
    3. projectid assignee
        1. assignee的设置
            1. 终端执行 gitlab me | grep \\"id\\" | cut -d ":" -f2 | cut -d "," -f1 | cut -b 2-  | xargs git config gitlab.assignee
        2. projectId的设置
            1. 终端执行 cat .git/config | grep url | awk '{print $3}' | grep . -m 1 | awk -F"[/]" '{print $2}' | awk -F"[.]" '{print $1}' | xargs gitlab searchProject | grep \\"id\\" -m 1 | cut -d ":" -f2 | cut -d "," -f1 | cut -b 2- | xargs git config gitlab.projectId
3. update config (每个用户只需要执行一次)
    1. cd $HOME && git clone https://github.com/foobra/SimpleUtilTools.git && cd SimpleUtilTools && git pull
    2. echo 'source $HOME/SimpleUtilTools/profiles' >> ~/.bash_profile
    3. 如果使用zsh, 就改成.zshrc, 记得屏蔽zsh的git插件
4. daily use
    0. 上述操作执行完成之后, 关闭终端应用, 重新打开终端应用
    1. 创建新分支 gnb dev2.11(这个是主分支名字, 大家根据自己的分支名修改)
    2. 拉取代码  gl
    3. 推送代码 gh
    4. 提交代码请求 gr
    5. 公司的gitlab偶尔出问题, 无法合并pull-request, 所以可以使用下面的命令手动合并分支
    6. gmergepr gs_dev2.11 (表示把 gs_dev2.11 合并到分支 dev2.11, 请在合并前审核代码,gitlab网页审核, 或者在IDE里面审核, 然后在手动执行这个命令合并分支, 等公司gitlab彻底修好了之后, 就可以不用这个命令了)
5. 代码审核插件
    1. idea 搜索 gitlab projects
