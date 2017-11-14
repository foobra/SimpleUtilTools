1. gitlab install
    1. windows https://nodejs.org/dist/v8.9.1/node-v8.9.1-x86.msi)
    2. mac https://nodejs.org/dist/v8.9.1/node-v8.9.1.pkg
    3. npm install cli-gitlab -g
2. git config
    1. 先进入项目
    2. username
        1. git config --global user.name gs
        2. git config user.name gs
    3. url token
        1. 查找到自己的gitlab url 后面备用 http://10.148.68.13
        2. gitlab url http://10.148.68.13
        3. http://10.148.68.13/profile/account 查找到自己的gitlab token
        4. gitlab token xxxx
        5. git config gitlab.url http://10.148.68.13 上面查出来的url
        6. git config gitlab.token xxxxx  上面查出来的 token
    4. projectid assignee
        1. gitlab me 查看自己的id
        2. gitlab projects 查看自己项目的projectId
        3. git config gitlab.projectId xx (上面查出来的projectId)
        4. git config gitlab.assignee 471 (上面查出来的自己的id)
3. update config (只执行一次 windows)
    1. mac
        1. cd $HOME && git clone https://github.com/foobra/SimpleUtilTools.git && cd SimpleUtilTools && git pull
        2. echo 'source $HOME/SimpleUtilTools/profiles' >> ~/.zshrc (.zshrc 需要注释掉 plugins=(git))
4. daily use
    1. 创建新分支 gnb dev2.11
    2. 拉取代码   gl
    3. 推送代码 gh
    4. 提交代码请求 gr
