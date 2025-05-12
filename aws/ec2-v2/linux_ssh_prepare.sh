#! /bin/bash

PASSWORD="1qaz@WSX"
USERNAME="vndeployer"
SV="$(hostname)"

if id -u "$USERNAME" >/dev/null 2>&1; then
    userdel -r -f $USERNAME
    useradd -m -p $PASSWORD -s /bin/bash $USERNAME
    usermod -a -G sudo $USERNAME
    echo $USERNAME:$PASSWORD | chpasswd
    echo "$USERNAME  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers

else
    useradd -m -p $PASSWORD -s /bin/bash $USERNAME
    usermod -a -G sudo $USERNAME
    echo $USERNAME:$PASSWORD | chpasswd
    echo "$USERNAME  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers
fi
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service ssh restart
