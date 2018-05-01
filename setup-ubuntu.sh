#!/bin/bash


#set version to download
latest="v4.27-9666-beta-2018.04.21"
arch="x64-64bit"

#generate url to download
file="softether-vpnserver-"$latest"-linux-"$arch".tar.gz"
link="http://www.softether-download.com/files/softether/"$latest"-tree/Linux/SoftEther_VPN_Server/"$arch"/"$file


#Update system and install basic packages
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

apt-get update && apt-get install build-essential dnsmasq fail2ban iftop traceroute iptables-persistent -y

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




