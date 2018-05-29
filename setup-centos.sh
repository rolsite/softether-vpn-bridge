#!/bin/bash

SERVER_IP=""
SERVER_PASSWORD=""
USER=""
USER_PASSWORD=""
HUB="VPN"
SHARED_KEY=""

#Set configs
echo -n "Enter Server IP: "
read SERVER_IP
echo -n "Set Softether VPN Server Admin Password: "
read SERVER_PASSWORD
echo -n "Set Softether VPN Secret (Pre-Shared Key) : "
read SHARED_KEY
echo -n "Create a VPN Client Username: "
read USER
echo -n "Set a VPN Client Password: "
read USER_PASSWORD
echo "+++ Wait until the installation finished... +++"

#set version to download
latest="v4.27-9666-beta-2018.04.21"
arch="64bit_-_Intel_x64_or_AMD64"
arch2="x64-64bit"

#generate url to download
file="softether-vpnserver-"$latest"-linux-"$arch2".tar.gz"
link="http://www.softether-download.com/files/softether/"$latest"-tree/Linux/SoftEther_VPN_Server/"$arch"/"$file


#Update system and install basic packages
yum update -y &&
yum -y install epel-release
yum -y install net-tools
yum -y groupinstall "Development Tools"
yum install dnsmasq fail2ban iftop traceroute iptables-services -y

#disable firewall and SELinux
systemctl disable firewalld
systemctl stop firewalld
systemctl status firewalld
service iptables save
service iptables stop
chkconfig iptables off
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#Get lastest Softether VPN Server
wget "$link"
if [ -f "$file" ];then
	tar xzf "$file"
	dir=$(pwd)
	echo "current dir " $dir
	cd vpnserver
	dir=$(pwd)
	echo "changed to dir " $dir
else
	echo "Archive not found. Please rerun this script or check permission."
	break
fi

#Install SoftEther VPN Server
make
cd ..
mv vpnserver /usr/local
dir=$(pwd)
echo "current dir " $dir
cd /usr/local/vpnserver/
dir=$(pwd)
echo "changed to dir " $dir
chmod 600 *
chmod 700 vpnserver
chmod 700 vpncmd
./vpnserver start
sleep 2
./vpncmd localhost /SERVER /CSV /CMD ServerPasswordSet ${SERVER_PASSWORD}
./vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD HubDelete DEFAULT
./vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD HubCreate ${HUB} /PASSWORD:${SERVER_PASSWORD}
./vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserCreate ${USER} /GROUP:none /REALNAME:none /NOTE:none
./vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserPasswordSet ${USER} /PASSWORD:${USER_PASSWORD}
./vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:no /PSK:${SHARED_KEY} /DEFAULTHUB:${HUB}
./vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD BridgeCreate ${HUB} /DEVICE:soft /TAP:yes

#Set DNSMASQ
cat <<EOF >> /etc/dnsmasq.conf
interface=tap_soft
dhcp-range=tap_soft,192.168.7.50,192.168.7.60,12h
dhcp-option=tap_soft,3,192.168.7.1
dhcp-option=tap_soft,6,8.8.8.8,8.8.4.4
EOF



#Create SoftEther VPN Server service
wget -P /etc/init.d https://raw.githubusercontent.com/rolsite/softether-vpn-bridge/master/vpnserver
chmod 755 /etc/init.d/vpnserver
chkconfig --add vpnserver
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 192.168.7.0/24 -j ACCEPT
iptables -A FORWARD -j REJECT
iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -j SNAT --to-source ${SERVER_IP}
iptables-save > /etc/sysconfig/iptables
systemctl enable dnsmasq
systemctl enable vpnserver
systemctl enable iptables.service
/usr/libexec/iptables/iptables.init save


#upgrarde kernel and active TCP BBR Congestion Control and IPv4 Forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ipv4_forwarding.conf
#echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
#echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

echo "+++ Installation finished, rebooting server... +++"
reboot


