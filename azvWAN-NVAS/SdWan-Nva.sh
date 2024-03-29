#!/bin/sh
#  DISCLAIMER - I not the author of this script - I just changed for my needs - Follow bellow to see the original one : 
#  https://github.com/dmauser/AzureVM-Router/blob/master/linuxrouterbgp.sh
#  Merits to the author - Daniel Mauser. 
# 
#
# Installb and set  admin stuff 
# Cockpit enable a Web interface for management - at https://$HOSTIP:9090 
ufw disable 
apt update && apt -y net-tools bind9-utils cockpit 
systemctl enable cockpit && systemctl start cockpit 

# Enable IPv4 and IPv6 forwarding / disable ICMP redirect
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_redirects=0
sed -i "/net.ipv4.ip_forward=1/ s/# *//" /etc/sysctl.conf
sed -i "/net.ipv6.conf.all.forwarding=1/ s/# *//" /etc/sysctl.conf
sed -i "/net.ipv4.conf.all.accept_redirects = 0/ s/# *//" /etc/sysctl.conf
sed -i "/net.ipv6.conf.all.accept_redirects = 0/ s/# *//" /etc/sysctl.conf

echo "Installing IPTables-Persistent"
echo iptables-persistent iptables-persistent/autosave_v4 boolean false | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | sudo debconf-set-selections
apt-get -y install iptables-persistent

# Enable NAT to Internet
iptables -t nat -F 
iptables -t filter -F 
iptables -A FORWARD -j ACCEPT

# Save to IPTables file for persistence on reboot
iptables-save > /etc/iptables/rules.v4
