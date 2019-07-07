#!/bin/bash
# JShielder v2.3
# Deployer for Ubuntu Server 18.04 LTS
#
# Jason Soto
# www.jasonsoto.com
# www.jsitech-sec.com
# Twitter = @JsiTech

# Based from JackTheStripper Project
# Credits to Eugenia Bahit

# A lot of Suggestion Taken from The Lynis Project
# www.cisofy.com/lynis
# Credits to Michael Boelen @mboelen


source helpers.sh

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
For Ubuntu Server 18.04 LTS
Developed By Jason Soto @Jsitech"
echo
echo

}

##############################################################################################################

# Check if running with root User

clear
f_banner


check_root() {
if [ "$USER" != "root" ]; then
      echo "Permission Denied"
      echo "Can only be run by root"
      exit
else
      clear
      f_banner
      cat templates/texts/welcome
fi
}

##############################################################################################################

# Installing Dependencies
# Needed Prerequesites will be set up here
install_dep(){
   clear
   f_banner
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo -e "\e[93m[+]\e[00m Setting some Prerequisites"
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo ""
   spinner
   add-apt-repository universe
   say_done
}

##############################################################################################################

# Update Root Password

update_root_password() {
clear
f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Please Update Your Root Password!"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    #echo -n " Type the new root password: "; read root_password
    #echo -e "$root_password\n$root_password" | passwd root
    #echo -n " Type the new root password: "
    #passwd root
    
    echo -e "$NEW_SERVER_ROOT_PASSWORD\n$NEW_SERVER_ROOT_PASSWORD\n" | passwd root
    
    say_done
}

##############################################################################################################

# Configure Hostname
config_host() {

echo -n " ¿Do you Wish to Set a HostName? (y/n): "; read config_host
if [ "$config_host" == "y" ]; then
    serverip=$(__get_ip)
    echo " Type a Name to Identify this server :"
    echo -n " (For Example: myserver): "; read host_name
    echo -n " ¿Type Domain Name?: "; read domain_name
    echo $host_name > /etc/hostname
    hostname -F /etc/hostname
    echo "127.0.0.1    localhost.localdomain      localhost" >> /etc/hosts
    echo "$serverip    $host_name.$domain_name    $host_name" >> /etc/hosts
    #Creating Legal Banner for unauthorized Access
    echo ""
    echo "Creating legal Banners for unauthorized access"
    spinner
    cat templates/motd > /etc/motd
    cat templates/motd > /etc/issue
    cat templates/motd > /etc/issue.net
    sed -i s/server.com/$host_name.$domain_name/g /etc/motd /etc/issue /etc/issue.net
    echo "OK "
fi
    say_done
}

##############################################################################################################

# Configure TimeZone
config_timezone(){
   clear
   f_banner
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo -e "\e[93m[+]\e[00m We will now Configure the TimeZone"
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo ""
   sleep 10
   #dpkg-reconfigure tzdata
   ln -fs /usr/share/zoneinfo/Europe/Kyiv /etc/localtime
   dpkg-reconfigure --frontend noninteractive tzdata
   say_done
}

##############################################################################################################

# Update System, Install sysv-rc-conf tool
update_system(){
   clear
   f_banner
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo -e "\e[93m[+]\e[00m Updating the System"
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo ""
   apt update
   apt -y upgrade
   apt -y dist-upgrade
   say_done
}

##############################################################################################################

# Setting a more restrictive UMASK
restrictive_umask(){
   clear
   f_banner
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo -e "\e[93m[+]\e[00m Setting UMASK to a more Restrictive Value (027)"
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo ""
   spinner
   cp templates/login.defs /etc/login.defs
   # sed -i s/umask\ 022/umask\ 027/g /etc/init.d/rc
   echo ""
   echo "OK"
   say_done
}

#############################################################################################################

#Disabling Unused Filesystems

unused_filesystems(){
   clear
   f_banner
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo -e "\e[93m[+]\e[00m Disabling Unused FileSystems"
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo ""
   spinner
   echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf
   echo " OK"
   say_done
}

##############################################################################################################

#Disable uncommon netprotocols

uncommon_netprotocols(){
   clear
   f_banner
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo -e "\e[93m[+]\e[00m Disabling Uncommon Network Protocols"
   echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
   echo ""
   spinner
   echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install rds /bin/true" >> /etc/modprobe.d/CIS.conf
   echo "install tipc /bin/true" >> /etc/modprobe.d/CIS.conf
   echo " OK"
   say_done_2

}

##############################################################################################################

# Create Privileged User
admin_user(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m We will now Create a New User"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    
    
    echo -n " Type the new username: "; read username
    PassWord=$username_main_password_$(pwgen 22 1)

#if id -u "$UserName" >/dev/null 2>&1; then
#    userdel -r -f "$UserName"
#fi

#adduser --disabled-password --gecos "" "$UserName"
#userdir=/home/"$UserName"
#[[ -d $userdir ]] || mkdir "$userdir"   # only needed for system users.
                                        # which usually do not have a password.
#echo "$UserName:$PassWord" | chpasswd
    
   #echo -n " Type the new username: "; read username
    adduser --gecos "" $username
    echo -e "$PassWord\n$PassWord\n" | sudo passwd $username

    mkdir /home/$username/.ssh
    touch /home/$username/.ssh/authorized_keys
    touch /home/$username/userpass
    echo -e "Shell username is: $username\nPassword of $username is: $PassWord" > /home/$username/userpass
    say_done
}

##############################################################################################################

# Instruction to Generate RSA Keys
rsa_keygen(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Instructions to Generate an RSA KEY PAIR"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    serverip=$(__get_ip)
    echo " *** IF YOU DONT HAVE A PUBLIC RSA KEY, GENERATE ONE ***"
    echo "     Follow the Instruction and Hit Enter When Done"
    echo "     To receive a new Instruction"
    echo " "
    echo "    RUN THE FOLLOWING COMMANDS"
    echo -n "     a) ssh-keygen -t rsa -b 4096 "; read foo1
    echo -n "     b) cat /home/$username/.ssh/id_rsa.pub >> /home/$username/.ssh/authorized_keys "; read foo2
    say_done
}
##############################################################################################################

# Move the Generated Public Key
rsa_keycopy(){
    echo " Run the Following Command to copy the Key"
    echo " Press ENTER when done "
    echo " ssh-copy-id -i $HOME/.ssh/id_rsa.pub $username@$serverip "
    say_done_2
}

##############################################################################################################

# Add manually the Generated Public Key
rsa_add(){
#read -t 3 -e -p " Do you want add your user public key mannually? (y/n): " -i "y" rsa_add_answer
echo -n " Do you want add your user public key mannually? (y/n): "; read rsa_add_answer
if [ "$rsa_add_answer" == "y" ]; then
echo -n " Now we need to add your ssh key"
echo -n " Enter your public key here and press enter: ";read -s publickey
echo "$publickey" >> /home/$username/.ssh/authorized_keys
 echo ""
 spinner
  echo "Your key is successfully add!"
 
      say_done   
      
 else
 echo ""
 echo "Ok"
 
 say_done
 fi
 }
   
##############################################################################################################


# Secure SSH
secure_ssh(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Securing SSH"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo -n " Securing SSH..."
    spinner
    sed s/USERNAME/$username/g templates/sshd_config2 > /etc/ssh/sshd_config; echo "OK"
    chattr -i /home/$username/.ssh/authorized_keys
    service ssh restart
    say_done
}

##############################################################################################################

# Set IPTABLES Rules
set_iptables(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Setting IPTABLE RULES"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo -n " Setting Iptables Rules..."
    spinner
    sh templates/iptables.sh
    cp templates/iptables.sh /etc/init.d/
    chmod +x /etc/init.d/iptables.sh
    ln -s /etc/init.d/iptables.sh /etc/rc2.d/S99iptables.sh
    say_done
}

##############################################################################################################

# Install fail2ban
    # To Remove a Fail2Ban rule use:
    # iptables -D fail2ban-ssh -s IP -j DROP
install_fail2ban(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing Fail2Ban"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt -y install sendmail
    apt -y install fail2ban
    say_done
}

##############################################################################################################

# Install, Configure and Optimize MySQL
install_secure_mysql(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing, Configuring and Optimizing MySQL"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt -y install mysql-server
    echo ""
    echo -n " configuring MySQL............ "
    spinner
    cp templates/mysql /etc/mysql/mysqld.cnf; echo " OK"
    
    #echo -n " Type the new root password: "; read -s NEW_MYSQL_PASSWORD
    
    # Usage:
#  Setup mysql root password:  ./mysql_secure.sh 'your_new_root_password'
#  Change mysql root password: ./mysql_secure.sh 'your_old_root_password' 'your_new_root_password'"
#

# Delete package expect when script is done
# 0 - No; 
# 1 - Yes.
#PURGE_EXPECT_WHEN_DONE=0

#
# Check the bash shell script is being run by root
#
#if [[ $EUID -ne 0 ]]; then
#   echo "This script must be run as root" 1>&2
#   exit 1
#fi

#
# Check input params
#
#if [ -n "${1}" -a -z "${2}" ]; then
    # Setup root password
#    CURRENT_MYSQL_PASSWORD=''
#    NEW_MYSQL_PASSWORD="${1}"
#elif [ -n "${1}" -a -n "${2}" ]; then
    # Change existens root password
#    CURRENT_MYSQL_PASSWORD="${1}"
 #   NEW_MYSQL_PASSWORD="${2}"
#else
#    echo "Usage:"
#    echo "  Setup mysql root password: ${0} 'your_new_root_password'"
#    echo "  Change mysql root password: ${0} 'your_old_root_password' 'your_new_root_password'"
#    exit 1
#fi

#
# Check is expect package installed
#
if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Can't find expect. Trying install it..."
    apt -y install expect --no-install-recommends

fi

SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No :\"
send \"n\r\"
expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"y\r\"
expect eof
")

#
# Execution mysql_secure_installation
#
echo "${SECURE_MYSQL}"

#if [ "${PURGE_EXPECT_WHEN_DONE}" -eq 1 ]; then
    # Uninstalling expect package
#    aptitude -y purge expect
#fi

    
    
    #mysql_secure_installation
    cp templates/usr.sbin.mysqld /etc/apparmor.d/local/usr.sbin.mysqld
    service mysql restart
    say_done
}

##############################################################################################################

# Install Apache
install_apache(){
  clear
  f_banner
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Installing Apache Web Server"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""
  apt -y install apache2
  say_done
}

##############################################################################################################

# Install, Configure and Optimize PHP
install_secure_php(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing, Configuring and Optimizing PHP"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt -y install php php-cli php-pear
    apt -y install php-mysql python-mysqldb libapache2-mod-php7.2
    echo ""
    echo -n " Making backup and replacing php.ini..."
    spinner
    #cp templates/php /etc/php/7.2/apache2/php.ini; echo " OK"
    #cp templates/php /etc/php/7.2/cli/php.ini; echo " OK"
    
    cp /etc/php/7.2/apache2/php.ini{,.bak}; echo " OK"
    cp /etc/php/7.2/cli/php.ini{,.bak}; echo " OK"
    
    cp templates/php /etc/php/7.2/apache2/php.ini.new; echo " OK"
    cp templates/php /etc/php/7.2/cli/php.ini.new; echo " OK"
    
    mv /etc/php/7.2/apache2/php.ini.new /etc/php/7.2/apache2/php.ini; echo " OK"
    mv /etc/php/7.2/cli/php.ini.new /etc/php/7.2/cli/php.ini; echo " OK"
    
    service apache2 restart
    say_done
}

##############################################################################################################

# Install ModSecurity
install_modsecurity(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing ModSecurity"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    
    apt -y install libapache2-mod-security2
    
    #apt -y install libxml2 libxml2-dev libxml2-utils
    #apt -y install libaprutil1 libaprutil1-dev
    #apt -y install git build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev  libcurlpp-dev libcurl4-openssl-dev automake pkgconf
    #mkdir src
    #cd src/
    #git clone https://github.com/SpiderLabs/ModSecurity
    #cd ModSecurity
    #git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
    #git submodule init
    #git submodule update
    #apt -y install libyajl-dev
    #apt -y install liblua5.3-dev
    #apt -y install liblmdb-dev
    #apt -y install libgeoip-dev
    #apt -y install libmaxminddb-dev
    
    #./build.sh
    #./configure
    #make
    #make install
    #cd ..
    
    #git clone https://github.com/SpiderLabs/ModSecurity-apache.git
    #cd ModSecurity-apache/
    #./autogen.sh
    #./configure
    #make
    #make install
    
    service apache2 restart
    say_done
}
##############################################################################################################

# Configure OWASP for ModSecurity
set_owasp_rules(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Setting UP OWASP Rules for ModSecurity"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""

    #for archivo in /usr/share/modsecurity-crs/base_rules/*
    #    do ln -s $archivo /usr/share/modsecurity-crs/activated_rules/
    #done

    #for archivo in /usr/share/modsecurity-crs/optional_rules/*
    #    do ln -s $archivo /usr/share/modsecurity-crs/activated_rules/
    #done
    
    spinner
    echo "OK"

    apt -y install modsecurity-crs
    
    cp /etc/modsecurity/modsecurity.conf{-recommended,}
    
    #sed -i -e 's/SecDefaultAction \"phase:1,log,auditlog,pass\"/#SecDefaultAction \"phase:1,log,auditlog,pass\"/g' /etc/modsecurity/crs/crs-setup.conf
    #sed -i -e 's/SecDefaultAction \"phase:2,log,auditlog,pass\"/#SecDefaultAction \"phase:2,log,auditlog,pass\"/g' /etc/modsecurity/crs/crs-setup.conf
    #sed -i -e 's/# SecDefaultAction \"phase:1,log,auditlog,deny,status:403\"/SecDefaultAction \"phase:1,log,auditlog,deny,status:403\"/g' /etc/modsecurity/crs/crs-setup.conf
    #sed -i -e 's/# SecDefaultAction \"phase:2,log,auditlog,deny,status:403\"/SecDefaultAction \"phase:2,log,auditlog,deny,status:403\"/g' /etc/modsecurity/crs/crs-setup.conf
 
    
    sed -i -e 's/DetectionOnly$/On/i' /etc/modsecurity/modsecurity.conf
    sed -i -e 's/SecStatusEngine On/SecStatusEngine Off/g' /etc/modsecurity/modsecurity.conf
   
    #mv /usr/share/modsecurity-crs /usr/share/modsecurity-crs.bk
    mkdir /usr/share/modsecurity-crs/activated_rules
    
    #  for archivo in /usr/share/modsecurity-crs/base_rules/*
    #    do ln -s $archivo /usr/share/modsecurity-crs/activated_rules/
    #done

    #for archivo in /usr/share/modsecurity-crs/optional_rules/*
    #    do ln -s $archivo /usr/share/modsecurity-crs/activated_rules/
    #done
    
    
    #cd /usr/share/modsecurity-crs/base_rules/
    #for ruleFile in * ; do sudo ln -s /usr/share/modsecurity-crs/base_rules/$ruleFile /etc/modsecurity/$ruleFile ; done
    
    #cd /usr/share/modsecurity-crs/optional_rules/
    #for ruleFile in * ; do sudo ln -s /usr/share/modsecurity-crs/optional_rules/$ruleFile /etc/modsecurity/$ruleFile ; done
    
    #cp /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf /etc/modsecurity/modsecurity_crs_10_setup.conf
    
    #git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs
    #mkdir /usr/share/modsecurity-crs/activated_rules
    
    #echo -e '# ModSecurity Core Rule Set (CRS)\nIncludeOptional /usr/share/modsecurity-crs/*.conf\nIncludeOptional /usr/share/modsecurity-crs/activated_rules/*.conf' >> 
    #echo -e '# ModSecurity Core Rule Set (CRS)\nIncludeOptional /usr/share/modsecurity-crs/*.conf\nIncludeOptional /usr/share/modsecurity-crs/activated_rules/*.conf' >> /etc/modsecurity/modsecurity.conf
    #CSRD=/usr/share/modsecurity-crs; for e in $CSRD/rules/*.conf; do sudo ln -s $e $CSRD/activated_rules/; done
    
    # check that rules are enabled
    #ls /usr/share/modsecurity-crs/activated_rules/*.conf
    
    #enable optional_rules
    #CSRD=/usr/share/modsecurity-crs; for e in $CSRD/optional_rules/*.conf; do sudo ln -s $e $CSRD/activated_rules/; done
    
    #enable experimental rules
    #CSRD=/usr/share/modsecurity-crs; for e in $CSRD/experimental_rules/*.conf; do sudo ln -s $e $CSRD/activated_rules/; done
    
    #enable slr_rules
    #CSRD=/usr/share/modsecurity-crs; for e in $CSRD/slr_rules/*.conf; do sudo ln -s $e $CSRD/activated_rules/; done
    
    # check that rules are enabled
    #ls /usr/share/modsecurity-crs/activated_rules/*.conf
    
    #apache2ctl -t && apache2ctl restart
    
    #Disable Rules
    #To disable rules, delete the symlink within the activated_rules directory that pertains to the rule in question. Once deleted, a quick restart of Apache services is necessary to make the change active.
    #Example: Delete the application_defects rule then restart Apache.
    #sudo rm -rf /usr/share/modsecurity-crs/activated_rules/modsecurity_crs_55_application_defects.conf
    #apache2ctl restart
    
    
    #sed s/SecRuleEngine\ DetectionOnly/SecRuleEngine\ On/g /etc/modsecurity/modsecurity.conf-recommended > salida
    #sed -i -e 's/SecStatusEngine On/SecStatusEngine Off/g' salida
    #mv salida /etc/modsecurity/modsecurity.conf

    echo 'SecServerSignature "AntiChino Server 1.0.4 LS"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
    echo 'Header set X-Powered-By "Plankalkül 1.0"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf
    echo 'Header set X-Mamma "Mama mia let me go"' >> /usr/share/modsecurity-crs/modsecurity_crs_10_setup.conf

    a2enmod headers
    a2enmod security2
    apache2ctl -t && apache2ctl restart
    say_done
}

##############################################################################################################

# Configure and optimize Apache
secure_optimize_apache(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Optimizing Apache"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    cp templates/apache /etc/apache2/apache2.conf.new
    cp /etc/apache2/apache2.conf{,.bak}
    mv /etc/apache2/apache2.conf.new /etc/apache2/apache2.conf
    echo " -- Enabling ModRewrite"
    spinner
    a2enmod rewrite
    a2enmod headers
    service apache2 restart
    say_done
}
##############################################################################################################

# Install ModEvasive
install_modevasive(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing ModEvasive"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo -n " Type Email to Receive Alerts "; read inbox
    apt -y install libapache2-mod-evasive
    mkdir /var/log/mod_evasive
    chown www-data:www-data /var/log/mod_evasive/
    sed s/MAILTO/$inbox/g templates/mod-evasive > /etc/apache2/mods-available/mod-evasive.conf
    service apache2 restart
    say_done
}

##############################################################################################################

# Install Mod_qos/spamhaus
install_qos_spamhaus(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing Mod_Qos/Spamhaus"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    apt -y install libapache2-mod-qos
    cp templates/qos /etc/apache2/mods-available/qos.conf
    apt -y install libapache2-mod-spamhaus
    cp templates/spamhaus /etc/apache2/mods-available/spamhaus.conf
    service apache2 restart
    say_done
}

##############################################################################################################

# Configure fail2ban
config_fail2ban(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Configuring Fail2Ban"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo " Configuring Fail2Ban......"
    spinner
    cp templates/portscan.conf /etc/fail2ban/filter.d/portscan.conf
    sed s/MAILTO/$inbox/g templates/fail2ban > /etc/fail2ban/jail.local
    cp /etc/fail2ban/jail.local /etc/fail2ban/jail.conf
    /etc/init.d/fail2ban restart
    say_done
}

##############################################################################################################

# Install Additional Packages
additional_packages(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing Additional Packages"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Install tree............."; apt -y install tree
    echo "Install Python-MySQLdb..."; apt -y install python-mysqldb
    echo "Install WSGI............."; apt -y install libapache2-mod-wsgi
    echo "Install PIP.............."; apt -y install python-pip
    echo "Install Vim.............."; apt -y install vim
    echo "Install Nano............."; apt -y install nano
    echo "Install pear............."; apt -y install php-pear
    echo "Install DebSums.........."; apt -y install debsums
    echo "Install apt-show-versions"; apt -y install apt-show-versions
    echo "Install PHPUnit..........";
    pear config-set auto_discover 1
    mv phpunit-patched /usr/share/phpunit
    echo include_path = ".:/usr/share/phpunit:/usr/share/phpunit/PHPUnit" >> /etc/php/7.2/cli/php.ini
    echo include_path = ".:/usr/share/phpunit:/usr/share/phpunit/PHPUnit" >> /etc/php/7.2/apache2/php.ini
    service apache2 restart
    say_done
}


##############################################################################################################
#Extract archive
extract_a1(){
clear
  f_banner
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Extract a1"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""
  

  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Extract a1 archive. Please Enter Your Password!"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"

  apt -y install p7zip-full
  echo ""
  echo -n " Please Enter Your Password: "; read -s archivepassword
  cd a1
  7z x a1.7z -p$archivepassword; echo "extract archive OK"
  rm a1.7z; echo "remove archive OK"
  cd ..
  echo " OK"
say_done
}
	
##############################################################################################################

# Add manually the Generated Public Key
rsa_add_manual(){
publickey=$(</root/JShielder/UbuntuServer_18.04LTS/a1/publickey.txt)
echo "$publickey" >> /home/$username/.ssh/authorized_keys
srm /root/JShielder/UbuntuServer_18.04LTS/a1/publickey.txt
 echo ""
 spinner
  echo "Your key is successfully add!"
 
      say_done   
 }
   
##############################################################################################################

# Create mysql user and data base and copy

create_mysql_user_db_a1(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Create MySQL user and database"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""

apt -y install pwgen
apt -y install gpw

# Autodetect IP address and pre-fill for the user
IP="$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)"
usernamedb=dbuser_"$(gpw 1 12)"
userdbpass=dbuser_pass_"$(pwgen 22 1)"
charset=utf8
dbname=db_"$(gpw 1 12)"
panelname="$(gpw 1 12)"

adminpassw=admin_pass_"$(pwgen 22 1)"
basicuser="$(gpw 1 8)"
basicpassword="$basicuser"_"$(pwgen 18 1)"


echo "##################################################################################################################"
echo "##################################################################################################################"
echo "##################################################################################"
echo "User name: $usernamedb"
echo "User db password: $userdbpass"
echo "Database name: $dbname"
echo "Your admin panel address is here: http://$IP/$panelname/"
echo "Admin panel password is: $adminpassw"
echo "First basic auth login is: $basicuser" 
echo "First basic auth password is: $basicpassword"
echo "Your index.php is here: http://$IP/index.php"
echo "##################################################################################"
echo "##################################################################################################################"
echo "##################################################################################################################"


# Bash script written by Saad Ismail - me@saadismail.net

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
	
	echo "Creating new adminpanel database..."
	mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo "Database successfully created!"
	echo "Showing existing databases..."
	mysql -e "show databases;"
	echo ""
	
	echo "Creating new user..."
	mysql -e "CREATE USER ${usernamedb}@localhost IDENTIFIED BY '${userdbpass}';"
	echo "User successfully created!"
	echo ""
	echo "Granting ALL privileges on ${dbname} to ${usernamedb}!"
	mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${usernamedb}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
	echo "You're good now :)"
	echo ""
	
	echo "Importing mysql dump..."
	
	#mysql -u "$usernamedb" -p "$userdbpass" "$dbname" < /root/JShielder/UbuntuServer_18.04LTS/a1/panel/info/dump.sql
	mysql --user=$usernamedb  --password=$userdbpass $dbname < /root/JShielder/UbuntuServer_18.04LTS/a1/panel/info/dump.sql
	
        echo "Importing mysql dump successfull!"

# If /root/.my.cnf doesn't exist then it'll ask for root password	
else
	echo "Please enter root user MySQL password!"
	read -s rootpasswd <<< $NEW_MYSQL_PASSWORD
	echo "Creating new adminpanel database..."
	mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
	echo "Database successfully created!"
	echo "Showing existing databases..."
	mysql -e "show databases;"
	echo ""
	
	echo "Creating new user..."
	mysql -e "CREATE USER ${usernamedb}@localhost IDENTIFIED BY '${userdbpass}';"
	echo "User successfully created!"
	echo ""
	echo "Granting ALL privileges on ${dbname} to ${usernamedb}!"
	#mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${usernamedb}'@'localhost' WITH GRANT OPTION;"
	mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${usernamedb}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
	echo "You're good now :)"
	echo ""
	
	echo "Importing mysql dump..."
	
	mysql --user=$usernamedb --password=$userdbpass $dbname < /root/JShielder/UbuntuServer_18.04LTS/a1/panel/info/dump.sql
	
	echo "Importing mysql dump successfull!"
fi
     

	 
    echo "Setup adminpanel..."
        
	sed -i -e "s/panelreplace/$panelname/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	sed -i -e "s/dbuserreplace/$usernamedb/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	sed -i -e "s/dbpassreplace/$userdbpass/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
        sed -i -e "s/dbnamereplace/$dbname/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	sed -i -e "s/adminpaswreplace/$adminpassw/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	
	
	rm /root/JShielder/UbuntuServer_18.04LTS/a1/panel/info/dump.sql
	mv /root/JShielder/UbuntuServer_18.04LTS/a1/panel /root/JShielder/UbuntuServer_18.04LTS/a1/$panelname
	

#htpasswd -c /root/apache/.htpasswd $basicuser $basicpassword

    cp -aR /root/JShielder/UbuntuServer_18.04LTS/a1/. /var/www/html/

echo "Ok"

find /var/www/ -type d -print0 | xargs -0 chmod 755
find /var/www/ -type f -print0 | xargs -0 chmod 644

chmod 777 /var/www/html/$panelname/links.txt
chmod 777 /var/www/html/$panelname/config.json
chmod 777 /var/www/html/$panelname/files/
chown -R www-data:www-data /var/www

htpasswd -b -c /etc/apache2/.htpasswd $basicuser $basicpassword

touch /root/adminpanelsdata.txt
cat > /root/adminpanelsdata.txt << EOL
##################################################################################################################
##################################################################################################################
##################################################################################################################
Your admin panel address is here: http://$IP/$panelname/
Basic auth login is: $basicuser
Basic auth password is: $basicpassword
Admin panel password is: $adminpassw
User name: $usernamedb
User db password: $userdbpass
Database name: $dbname
Your index.php is here: http://$IP/index.php
Mysql Root Password: $NEW_MYSQL_PASSWORD
Server Root Password: $NEW_SERVER_ROOT_PASSWORD
##################################################################################################################
##################################################################################################################
##################################################################################################################
EOL


     say_done
}
##############################################################################################################


# Tune and Secure Kernel
tune_secure_kernel(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Tuning and Securing the Linux Kernel"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo " Securing Linux Kernel"
    spinner
    echo "* hard core 0" >> /etc/security/limits.conf
    cp templates/sysctl.conf /etc/sysctl.conf; echo " OK"
    cp templates/ufw /etc/default/ufw
    sysctl -e -p
    say_done
}

##############################################################################################################


# Install RootKit Hunter
install_rootkit_hunter(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Installing RootKit Hunter"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Rootkit Hunter is a scanning tool to ensure you are you're clean of nasty tools. This tool scans for rootkits, backdoors and local exploits by running tests like:
          - MD5 hash compare
          - Look for default files used by rootkits
          - Wrong file permissions for binaries
          - Look for suspected strings in LKM and KLD modules
          - Look for hidden files
          - Optional scan within plaintext and binary files "
    sleep 1
    cd rkhunter-1.4.6/
    sh installer.sh --layout /usr --install
    cd ..
    rkhunter --update
    rkhunter --propupd
    echo ""
    echo " ***To Run RootKit Hunter ***"
    echo "     rkhunter -c --enable all --disable none"
    echo "     Detailed report on /var/log/rkhunter.log"
    say_done
}

##############################################################################################################

# Tuning
tune_nano_vim_bashrc(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Tunning bashrc, nano and Vim"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""

# Tune .bashrc
    echo "Tunning .bashrc......"
    spinner
    cp templates/bashrc-root /root/.bashrc
    cp templates/bashrc-user /home/$username/.bashrc
    chown $username:$username /home/$username/.bashrc
    echo "OK"


# Tune Vim
    echo "Tunning Vim......"
    spinner
    tunning vimrc
    echo "OK"


# Tune Nano
    echo "Tunning Nano......"
    spinner
    tunning nanorc
    echo "OK"
    say_done
}
##############################################################################################################

# Add Daily Update Cron Job
daily_update_cronjob(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Adding Daily System Update Cron Job"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Creating Daily Cron Job"
    spinner
    job="@daily apt update; apt dist-upgrade -y"
    touch job
    echo $job >> job
    crontab job
    rm job
    say_done
}

##############################################################################################################

# Additional Hardening Steps
additional_hardening(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Running additional Hardening Steps"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Running Additional Hardening Steps...."
    spinner
    echo tty1 > /etc/securetty
    chmod 0600 /etc/securetty
    chmod 700 /root
    chmod 600 /boot/grub/grub.cfg
    #Remove AT and Restrict Cron
    apt -y purge at
    apt -y install libpam-cracklib
    echo ""
    echo " Securing Cron "
    spinner
    touch /etc/cron.allow
    chmod 600 /etc/cron.allow
    awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny
    echo ""
    echo -n " Do you want to Disable USB Support for this Server? (y/n): " ; read usb_answer
    if [ "$usb_answer" == "y" ]; then
       echo ""
       echo "Disabling USB Support"
       spinner
       echo "blacklist usb-storage" | sudo tee -a /etc/modprobe.d/blacklist.conf
       update-initramfs -u
       echo "OK"
       say_done
    else
       echo "OK"
       say_done
    fi
}

##############################################################################################################

# Disable Compilers
disable_compilers(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Disabling Compilers"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo "Disabling Compilers....."
    spinner
    chmod 000 /usr/bin/as >/dev/null 2>&1
    chmod 000 /usr/bin/byacc >/dev/null 2>&1
    chmod 000 /usr/bin/yacc >/dev/null 2>&1
    chmod 000 /usr/bin/bcc >/dev/null 2>&1
    chmod 000 /usr/bin/kgcc >/dev/null 2>&1
    chmod 000 /usr/bin/cc >/dev/null 2>&1
    chmod 000 /usr/bin/gcc >/dev/null 2>&1
    chmod 000 /usr/bin/*c++ >/dev/null 2>&1
    chmod 000 /usr/bin/*g++ >/dev/null 2>&1
    spinner
    echo ""
    echo " If you wish to use them, just change the Permissions"
    echo " Example: chmod 755 /usr/bin/gcc "
    echo " OK"
    say_done
}
##############################################################################################################

#Securing /tmp Folder
secure_tmp(){
  clear
  f_banner
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Securing /tmp Folder"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""
  echo -n " ¿Did you Create a Separate /tmp partition during the Initial Installation? (y/n): "; read tmp_answer
  if [ "$tmp_answer" == "n" ]; then
      echo "We will create a FileSystem for the /tmp Directory and set Proper Permissions "
      spinner
      dd if=/dev/zero of=/usr/tmpDISK bs=1024 count=2048000
      mkdir /tmpbackup
      cp -Rpf /tmp /tmpbackup
      mount -t tmpfs -o loop,noexec,nosuid,rw /usr/tmpDISK /tmp
      chmod 1777 /tmp
      cp -Rpf /tmpbackup/* /tmp/
      rm -rf /tmpbackup
      echo "/usr/tmpDISK  /tmp    tmpfs   loop,nosuid,nodev,noexec,rw  0 0" >> /etc/fstab
      sudo mount -o remount /tmp
      say_continue_2
      say_done
  else
      echo "Nice Going, Remember to set proper permissions in /etc/fstab"
      echo ""
      echo "Example:"
      echo ""
      echo "/dev/sda4   /tmp   tmpfs  loop,nosuid,noexec,rw  0 0 "
      say_continue_2
      say_done
  fi
}

##############################################################################################################
# Restrict Access to Apache Config Files
apache_conf_restrictions(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Restricting Access to Apache Config Files"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo " Restricting Access to Apache Config Files......"
    spinner
     chmod 750 /etc/apache2/conf* >/dev/null 2>&1
     chmod 511 /usr/sbin/apache2 >/dev/null 2>&1
     chmod 750 /var/log/apache2/ >/dev/null 2>&1
     chmod 640 /etc/apache2/conf-available/* >/dev/null 2>&1
     chmod 640 /etc/apache2/conf-enabled/* >/dev/null 2>&1
     chmod 640 /etc/apache2/apache2.conf >/dev/null 2>&1
     echo " OK"
     say_done
}

##############################################################################################################
# 
cat_setup_info(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Save your install info"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    echo " Restricting Access to Apache Config Files......"
    spinner
     cat /root/adminpanelsdata.txt
     echo " OK"
     say_done_2
}

##############################################################################################################
##############################################################################################################
# 
srm_setup_info(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Secure remove install info"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    spinner
    apt -y install secure-delete
    srm -rvz /root/JShielder
     srm -vz /root/adminpanelsdata.txt
     echo " OK"
     say_done_2
}

##############################################################################################################


# Additional Security Configurations
  #Enable Unattended Security Updates
  unattended_upgrades(){
  clear
  f_banner
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Enable Unattended Security Updates"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""
  echo -n " ¿Do you Wish to Enable Unattended Security Updates? (y/n): "; read unattended
  if [ "$unattended" == "y" ]; then
      dpkg-reconfigure -plow unattended-upgrades
  else
      clear
  fi
}

##############################################################################################################

file_permissions(){
 clear
  f_banner
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Setting File Permissions on Critical System Files"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""
  spinner
  sleep 2
  chmod -R g-wx,o-rwx /var/log/*

  chown root:root /etc/ssh/sshd_config
  chmod og-rwx /etc/ssh/sshd_config

  chown root:root /etc/passwd
  chmod 644 /etc/passwd

  chown root:shadow /etc/shadow
  chmod o-rwx,g-wx /etc/shadow

  chown root:root /etc/group
  chmod 644 /etc/group

  chown root:shadow /etc/gshadow
  chmod o-rwx,g-rw /etc/gshadow

  chown root:root /etc/passwd-
  chmod 600 /etc/passwd-

  chown root:root /etc/shadow-
  chmod 600 /etc/shadow-

  chown root:root /etc/group-
  chmod 600 /etc/group-

  chown root:root /etc/gshadow-
  chmod 600 /etc/gshadow-


  echo -e ""
  echo -e "Setting Sticky bit on all world-writable directories"
  sleep 2
  spinner

  df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t

  echo " OK"
  say_done_2

}
##############################################################################################################

# Reboot Server
reboot_server(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Final Step"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    sed -i s/USERNAME/$username/g templates/texts/bye
    sed -i s/SERVERIP/$serverip/g templates/texts/bye
    cat templates/texts/bye
    echo -n " ¿Were you able to connect via SSH to the Server using $username? (y/n): "; read answer
    if [ "$answer" == "y" ]; then
        reboot
    else
        echo "Server will not Reboot"
        echo "Bye."
    fi
}

##################################################################################################################

clear
f_banner
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[93m[+]\e[00m SELECT THE DESIRED OPTION"
echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
echo ""
echo "1. A1"
echo "2. Exit"
echo

read choice

case $choice in

1)
check_root
install_dep
update_root_password
config_host
config_timezone
update_system
restrictive_umask
unused_filesystems
uncommon_netprotocols
set_iptables
install_fail2ban
install_secure_mysql
install_apache
install_secure_php
secure_optimize_apache
config_fail2ban
extract_a1
rsa_add_manual
secure_ssh
create_mysql_user_db_a1
tune_secure_kernel
install_rootkit_hunter
tune_nano_vim_bashrc
cat_setup_info
srm_setup_info
daily_update_cronjob
yes y | additional_hardening
disable_compilers
secure_tmp
apache_conf_restrictions
say y | unattended_upgrades
file_permissions
;;

2)
exit 0
;;

esac
