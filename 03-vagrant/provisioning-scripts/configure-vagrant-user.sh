#!/usr/bin/env bash

VAGRANT_USER_HOME=/home/vagrant

mkdir $VAGRANT_USER_HOME/.ssh && chmod 700 $VAGRANT_USER_HOME/.ssh

curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub > $VAGRANT_USER_HOME/.ssh/authorized_keys

chmod 600 $VAGRANT_USER_HOME/.ssh/authorized_keys

chown -R vagrant:vagrant $VAGRANT_USER_HOME

groupadd docker

usermod -aG docker vagrant

cat > $VAGRANT_USER_HOME/.bash_profile << BASH_PROFILE
# .bash_profile
PS1='[\w]\n\u@\h% '

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs
PATH=\$PATH:\$HOME/bin

export PATH

# Set service account tokens as environmental variables
if [ -f ~/.credentials ]; then
  . ~/.credentials
fi
BASH_PROFILE
