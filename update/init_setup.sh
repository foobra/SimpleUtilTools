#!/bin/sh
if [ -e ~/.zshrc ]
then
    echo "puts scripts in zshrc"
    echo 'source $HOME/SimpleUtilTools/profiles' >> ~/.zshrc
    zsh
    source ~/.zshrc
elif [ -e ~/.bashrc ]
then
    echo "puts scripts in bashrc"
    echo 'source $HOME/SimpleUtilTools/profiles' >> ~/.bashrc
    source ~/.bashrc
elif [ -e ~/.bash_profile ]
then
    echo "puts scripts in bash_profile"
    echo 'source $HOME/SimpleUtilTools/profiles' >> ~/.bash_profile
    source ~/.bash_profile
elif [ -e ~/.profile ]
then
    echo "puts scripts in profile"
    echo 'source $HOME/SimpleUtilTools/profiles' >> ~/.profile
    source ~/.profile
fi
