#!/bin/bash

hostnamectl set-hostname hq-cli.au-team.irpo;

useradd sshuser -u 1010
echo "sshuser:P@ssw0rd" | chpasswd
usermod -aG wheel sshuser

touch /etc/sudoers
cat <<EOF /etc/sudoers
sshuser ALL=(ALL) NOPASSWD:ALL
EOF

CONFIG_FILE="/etc/openssh/sshd_config"

echo "AllowUsers sshuser" | tee -a /etc/openssh/sshd_config
awk -i inplace '/^#?Port[[:space:]]+22$/ {sub(/^#/,""); sub(/22/,"2024"); print; next} {print}' "$CONFIG_FILE"
awk -i inplace '/^#?MaxAuthTries[[:space:]]+6$/ {sub(/^#/,""); sub(/6/,"2"); print; next} {print}' "$CONFIG_FILE"
awk -i inplace '/^#?PasswordAuthentication[[:space:]]+(yes|no)$/ {sub(/^#/,""); sub(/no/,"yes"); print; next} {print}' "$CONFIG_FILE"
awk -i inplace '/^#?PubkeyAuthentication[[:space:]]+(yes|no)$/ {sub(/^#/,""); sub(/no/,"yes"); print; next} {print}' "$CONFIG_FILE"

touch /etc/openssh/banner 
cat <<EOF > /etc/openssh/banner
Authorized access only  
EOF  
systemctl restart sshd  

echo "default_realm = AU-TEAM.IRPO" | sudo tee -a /etc/krb5.conf
echo "nameserver 192.168.0.30" | sudo tee -a /etc/resolv.conf

apt-get update && apt-get install tzdata  
timedatectl set-timezone Europe/Samara

apt-get update && apt-get install -y gpupdate
gpupdate-setup enable
apt-get install -y admc
apt-get install -y gpui
apt-get install -y libnss-role
control libnss-role
roleadd hq wheel
rolelst
apt-get install -y admx-*
admx-msi-setup
