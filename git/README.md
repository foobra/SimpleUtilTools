1. gitlab install
    1. windows https://nodejs.org/dist/v8.9.1/node-v8.9.1-x86.msi)
    2. mac https://nodejs.org/dist/v8.9.1/node-v8.9.1.pkg
    3. npm install cli-gitlab -g
2. git config
    1. 先进入项目
    2. username
        1. git config --global user.name gs(这里换成自己的名字拼音, 或者拼音缩写)
        2. git config user.name gs(这里换成自己的名字拼音, 或者拼音缩写)
    3. url token
        1. 查找到自己的gitlab url 后面备用 http://10.148.68.13
        2. gitlab url http://10.148.68.13
        3. http://10.148.68.13/profile/account 查找到自己的gitlab token
        4. gitlab token xxxx
        5. git config gitlab.url http://10.148.68.13 上面查出来的url
        6. git config gitlab.token xxxxx  上面查出来的 token
    4. projectid assignee
        1. 设置自己的assignee
            1.1 gitlab me | grep \\"id\\" | cut -d ":" -f2 | cut -d "," -f1 | cut -b 2-  | xargs git config gitlab.assignee
        2. 设置自己的 projectId
            2.1 git remote get-url origin | cut -d "/" -f2 | cut -d "." -f1 | xargs  gitlab searchProject | grep \\"id\\" -m 1 | cut -d ":" -f2 | cut -d "," -f1 | cut -b 2- | xargs git config gitlab.projectId
3. update config
    1. cd $HOME && git clone https://github.com/foobra/SimpleUtilTools.git && cd SimpleUtilTools && git pull
    2. echo 'source $HOME/SimpleUtilTools/profiles' >> ~/.bashrc
    3. 如果使用zsh, 就改成.zshrc, 记得屏蔽zsh的git插件
4. daily use
    1. 创建新分支 gnb dev2.11
    2. 拉取代码   gl
    3. 推送代码 gh
    4. 提交代码请求 gr
5. 代码审核插件
    1. idea 搜索 gitlab projects
