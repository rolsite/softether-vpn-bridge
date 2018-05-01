#!/bin/bash

##update system and install packets
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

apt-get update && apt-get install build-essential dnsmasq fail2ban iftop traceroute iptables-persistent -y
