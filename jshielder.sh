#!/bin/bash

# JShielder v2.3
# Linux Hardening Script
#
# Jason Soto
# www.jasonsoto.com
# Twitter = @JsiTech

# Tool URL = github.com/jsitech/jshielder

# Based from JackTheStripper Project
# Credits to Eugenia Bahit

# A lot of Suggestion Taken from The Lynis Project
# www.cisofy.com/lynis
# Credits to Michael Boelen @mboelen

##############################################################################################################

f_banner(){
echo
echo "

     ██╗███████╗██╗  ██╗██╗███████╗██╗     ██████╗ ███████╗██████╗
     ██║██╔════╝██║  ██║██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗
     ██║███████╗███████║██║█████╗  ██║     ██║  ██║█████╗  ██████╔╝
██   ██║╚════██║██╔══██║██║██╔══╝  ██║     ██║  ██║██╔══╝  ██╔══██╗
╚█████╔╝███████║██║  ██║██║███████╗███████╗██████╔╝███████╗██║  ██║
╚════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                              
Linux Automated Hardening Script for Linux Servers
Developed By Jason Soto @JsiTech "
echo
echo

}

##############################################################################################################

#Check if Running with root user

if [ "$USER" != "root" ]; then
      echo "Permission Denied"
      echo "Can only be run by root"
      exit
else
      clear
      f_banner
fi

#install additional packages 
apt -y install pkg-config 
apt -y install software-properties-common
apt -y install screen
apt -y install pwgen 
apt -y install gpw

menu=""
until [ "$menu" = "10" ]; do

clear
f_banner

echo
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[+]\e[00m SELECT YOUR LINUX DISTRIBUTION"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo ""
echo "1. Ubuntu Server 16.04 LTS"
echo "2. Ubuntu Server 18.04 LTS"
echo "3. Exit"
echo

read menu
case $menu in

1)
cd UbuntuServer_16.04LTS/
chmod +x jshielder.sh
#screen -S jshielder /root/JShielder/UbuntuServer_16.04LTS/jshielder.sh

./jshielder.sh
;;

2)
cd UbuntuServer_18.04LTS/
chmod +x jshielder.sh
#screen -S jshielder /root/JShielder/UbuntuServer_18.04LTS/jshielder.sh
./jshielder.sh
;;

3)
break
;;

*) ;;

esac
done
