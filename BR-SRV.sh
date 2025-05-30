#!/bin/bash

#Переименование виртуалки
hostnamectl set-hostname br-srv.au-team.irpo; 

#Настройка интерфейсов и времени
cat <<EOF > /etc/net/ifaces/ens18/options
TYPE=eth
DISABLED=no
NM_CONTROLLED=no
BOOTPROTO=static
IPV4_CONFIG=yes
EOF

touch /etc/net/ifaces/ens18/ipv4address
cat <<EOF > /etc/net/ifaces/ens18/ipv4address
192.168.0.30/27
EOF

touch /etc/net/ifaces/ens18/ipv4route
cat <<EOF > /etc/net/ifaces/ens18/ipv4route
default via 192.168.0.1
EOF

cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 77.88.8.8
EOF

timedatectl set-timezone Europe/Samara
systemctl restart network

#Создание пользователя sshuser и настройка sshd конфига
useradd sshuser -u 1010
echo "sshuser:P@ssw0rd" | chpasswd
usermod -aG wheel sshuser

touch /etc/sudoers
cat <<EOF /etc/sudoers
sshuser ALL=(ALL) NOPASSWD:ALL
EOF


CONFIG_FILE="/etc/openssh/sshd_config"  

# Изменить SSH-порт с 22 на 2024  
awk -i inplace '/^#Port 22$/ { gsub(/22/, "2024"); $0 = "Port 2024" } { print }' "$CONFIG_FILE"  

# Уменьшить MaxAuthTries с 6 до 2  
awk -i inplace '/^#MaxAuthTries 6$/ { gsub(/6/, "2"); $0 = "MaxAuthTries 2" } { print }' "$CONFIG_FILE"  

echo "Allow users = sshuser" >> "$CONFIG_FILE" 

# Разрешить аутентификацию по паролю  
awk -i inplace '/^#PasswordAuthentication yes$/ { sub(/^#/, ""); print; next } { print }' "$CONFIG_FILE"  

touch /etc/openssh/banner
cat <<EOF > /etc/openssh/banner

Authorized access only  
 
EOF  

systemctl restart sshd  

#Создание NTP
apt-get install chrony -y 
sed -i '3i#pool pool.ntp.org iburst' /etc/chrony.conf
systemctl enable --now chronyd

cat <<EOF >> /etc/resolv.conf 
nameserver 8.8.8.8
EOF

#Создание Samba DC
apt-get update && apt-get install -y task-samba-dc bind 
control bind-chroot disabled
grep -q KRB5RCACHETYPE /etc/sysconfig/bind || echo 'KRB5RCACHETYPE="none"' >> /etc/sysconfig/bind
systemctl stop bind
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba
rm -rf /var/cache/samba
mkdir -p /var/lib/samba/sysvol
samba-tool domain provision --realm=au-team.irpo --domain=au-team --adminpass='P@ssw0rd' --dns-backend=SAMBA_INTERNAL --server-role=dc --use-rfc2307
