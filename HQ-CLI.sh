#!/bin/bash

hostnamectl set-hostname hq-cli.au-team.irpo;

#Создание пользователя sshuser и настройка sshd конфига
useradd sshuser -u 1010
echo "sshuser:P@ssw0rd" | chpasswd
usermod -aG wheel sshuser

touch /etc/sudoers
cat <<EOF /etc/sudoers
sshuser ALL=(ALL) NOPASSWD:ALL
EOF


CONFIG_FILE="/etc/ssh/sshd_config"  

# Изменить SSH-порт с 22 на 2024  
sed -i 's/^#Port 22$/Port 2024/' "$CONFIG_FILE"  

# Уменьшить MaxAuthTries с 6 до 2  
sed -i 's/^#MaxAuthTries 6$/MaxAuthTries 2/' "$CONFIG_FILE"  


echo "Allow users = sshuser" >> "$CONFIG_FILE" 

# Разрешить аутентификацию по паролю 
sed -i 's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' "$CONFIG_FILE"  

touch /etc/openssh/bannermotd
cat <<EOF /etc/openssh/bannermotd

----------------------
Authorized access only
----------------------
EOF
systemctl restart sshd

