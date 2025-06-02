#!/bin/bash

hostnamectl set-hostname ISP;

mkdir /etc/net/ifaces/ens19
mkdir /etc/net/ifaces/ens20

touch /etc/net/ifaces/ens19/options
touch /etc/net/ifaces/ens20/options

cat <<EOF > /etc/net/ifaces/ens19/options
TYPE=eth
DISABLED=no
NM_CONTROLLED=no
BOOTPROTO=static
IPV4_CONFIG=yes
EOF

cat <<EOF > /etc/net/ifaces/ens20/options
TYPE=eth
DISABLED=no
NM_CONTROLLED=no
BOOTPROTO=static
IPV4_CONFIG=yes
EOF

cat <<EOF > /etc/net/ifaces/ens19/ipv4address
172.16.4.1/28
EOF

cat <<EOF > /etc/net/ifaces/ens20/ipv4address
172.16.5.1/28
EOF

sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/net/sysctl.conf

apt-get update && apt-get install -y firewalld

apt-get update && apt-get install tzdata  
timedatectl set-timezone Europe/Samara

systemctl enable --now firewalld
firewall-cmd --permanent --zone=public --add-interface=ens18
firewall-cmd --permanent --zone=trusted --add-interface=ens19
firewall-cmd --permanent --zone=trusted --add-interface=ens20
firewall-cmd --permanent --zone=public --add-masquerade
firewall-cmd --reload
systemctl restart firewalld
systemctl restart network

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


hostnamectl set-hostname ISP; exec bash
