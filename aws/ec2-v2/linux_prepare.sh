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
echo "Testing APP for $SV" >> /var/test-$SV.txt
sudo apt-get -y update
sudo apt-get -y install nginx
echo "Testing APP for $SV" >> /var/www/index.html
sudo service nginx start