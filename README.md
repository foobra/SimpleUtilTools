1. gitlab install
    1. brew install npm
    2. npm install cli-gitlab -g
    3. git lab url http://10.148.68.13
    4. http://10.148.68.13/profile/account   gitlab token xxxxx
    5. gitlab me 查看自己的id
    6. gitlab projects 查看自己项目的projectId
2. git config
    1. git config --global user.name gs
    2. git config user.name gs
    3. git config gitlab.projectId xx (上面查出来的projectId)
    4. git config gitlab.assignee 471 (上面查出来的自己的id)
3. update config
    1. cd $HOME && git clone git@github.com:foobra/SimpleGitTools.git && cd SimpleGitTools && git pull
    2. echo 'source $HOME/SimpleGitTools/.mg_tools.sh' >> ~/.zshrc (.zshrc 需要注释掉 plugins=(git))
4. daily use
    1.  创建新分支 gnb dev2.11
    2. 拉取代码   gl
    3. 推送代码 gh
    4. 提交代码请求 gr
