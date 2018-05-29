# Softether-vpn-bridge optimized install
Script to install Softether VPN in Ubuntu as Local Bridge (faster than SecureNAT) and optimized TCP Congestion Control Algorithm (Google TCP BBR)

Instructions for Ubuntu 16.04 x64:

1 - Login as root

2 - wget https://raw.githubusercontent.com/rolsite/softether-vpn-bridge/master/setup-ubuntu.sh

3 - chmod 755 setup-ubuntu.sh

4 - ./setup-ubuntu.sh

5 - Set your VPS IP and credentials

6 - Accept terms from Softether contract (Select option 1, 1, 1)

7 - This script will reboot your machine when completed


Instructions for Centos 7.1503.01 x64:

1 - Login as root

2 - yum -y install wget

2 - wget https://raw.githubusercontent.com/rolsite/softether-vpn-bridge/master/setup-centos.sh

3 - chmod 755 setup-centos.sh

4 - ./setup-centos.sh

5 - Set your VPS IP and credentials

6 - Accept terms from Softether contract (Select option 1, 1, 1)

7 - This script will reboot your machine when completed


How to connect (VPN Clients)

Many devices are supported, including Windows, Linux, Android and IOS natively.

Android/iOS
https://www.softether.org/4-docs/2-howto/9.L2TPIPsec_Setup_Guide_for_SoftEther_VPN_Server

Windows, MacOS and Linux
http://www.softether-download.com/en.aspx?product=softether



