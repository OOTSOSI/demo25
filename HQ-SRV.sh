#!/bin/bash

hostnamectl set-hostname hq-srv.au-team.irpo
cat <<EOF > /etc/net/ifaces/ens18/options
TYPE=eth
DISABLED=no
NM_CONTROLLED=no
BOOTPROTO=static
IPV4_CONFIG=yes
EOF

touch /etc/net/ifaces/ens18/ipv4address
cat <<EOF > /etc/net/ifaces/ens18/ipv4address
192.168.1.62/26
EOF

touch /etc/net/ifaces/ens18/ipv4route
cat <<EOF > /etc/net/ifaces/ens18/ipv4route
default via 192.168.1.1
EOF

cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
EOF
systemctl restart network

#Создание пользователя sshuser и настройка sshd конфига
useradd sshuser -u 1010
echo "sshuser:P@ssw0rd" | chpasswd
usermod -aG wheel sshuser

apt-get update && apt-get install tzdata  
timedatectl set-timezone Europe/Samara

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

touch /etc/openssh/bannermotd  
cat <<EOF > /etc/openssh/bannermotd 
Authorized access only  
EOF  

systemctl restart sshd  

apt-get install -y chrony dnsmasq
cat <<EOF > /etc/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
#pool pool.ntp.org iburst
server 192.168.1.62 iburst prefer
# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
#allow 192.168.0.0/16

# Serve time even if not synchronized to a time source.
#local stratum 10

# Require authentication (nts or key option) for all NTP sources.
#authselectmode require

# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys

# Save NTS keys and cookies.
ntsdumpdir /var/lib/chrony

# Insert/delete leap seconds by slewing instead of stepping.
#leapsecmode slew

# Get TAI-UTC offset and leap seconds from the system tz database.
#leapsectz right/UTC

# Specify directory for log files.
logdir /var/log/chrony

# Select which information is logged.
#log measurements statistics tracking
EOF

apt-get update && apt-get install -y dnsmasq
cat > /etc/dnsmasq.conf <<EOF
no-resolv
no-poll
no-hosts
listen-address=192.168.1.62

server=77.88.8.8
server=8.8.8.8

cache-size=1000
all-servers
no-negcache

host-record=hq-rtr.au-team.irpo,192.168.1.1
host-record=hq-srv.au-team.irpo,192.168.1.62
host-record=hq-cli.au-team.irpo,192.168.1.66

address=/br-rtr.au-team.irpo/192.168.0.1
address=/br-srv.au-team.irpo/192.168.0.30

cname=moodle.au-team.irpo,hq-rtr.au-team.irpo
cname=wiki.au-team.irpo,hq-rtr.au-team.irpo
EOF
systemctl restart dnsmasq

grep -E "Port|MaxAuthTries|PasswordAuthentication|PubkeyAuthentication" "$CONFIG_FILE"
cat /etc/dnsmasq.conf
timedatectl

