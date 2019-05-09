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
    echo -n " Type the new root password: "
    passwd root
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
   dpkg-reconfigure tzdata
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
   say_done

}

##############################################################################################################
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
  echo -n " Please Enter Your Password: "; read archivepassword
  cd a1
  7z x a1.7z -p$archivepassword
  cd ..
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
      say_done
  else
      echo "Nice Going, Remember to set proper permissions in /etc/fstab"
      echo ""
      echo "Example:"
      echo ""
      echo "/dev/sda4   /tmp   tmpfs  loop,nosuid,noexec,rw  0 0 "
      echo ""
      mount
      echo ""
      say_done
  fi
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
    echo -n " Replacing php.ini..."
    spinner
    cp templates/php /etc/php/7.*/apache2/php.ini; echo " OK"
    cp templates/php /etc/php/7.*/cli/php.ini; echo " OK"
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

# Configure and optimize Apache
secure_optimize_apache(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Optimizing Apache"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""
    cp templates/apache /etc/apache2/apache2.conf
    echo " -- Enabling ModRewrite"
    spinner
    a2enmod rewrite
    service apache2 restart
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
    mysql_secure_installation
    cp templates/usr.sbin.mysqld /etc/apparmor.d/local/usr.sbin.mysqld
    service mysql restart
    say_done
}

##############################################################################################################

# Create mysql user and data base and copy

create__mysql_user_db_a1(){
    clear
    f_banner
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo -e "\e[93m[+]\e[00m Create MySQL user and database"
    echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
    echo ""

apt -y install pwgen
apt -y install gpw

usernamedb=userdb_$(gpw 12 1)
userdbpass=userpass_$(openssl rand -base64 16)
charset=utf8
dbname=db_$(gpw 12 1)
panelname=$(gpw 12 1)

adminpassw=admin_pass_$(openssl rand -base64 16)
basicuser=$(gpw 8 1)
basicpassword=$basicuser_$(openssl rand -base64 16)

htpasswd -c /etc/apache2/.htpasswd "$basicuser" "$basicpassword"


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
	
	mysql -u "$usernamedb" -p "$userdbpass" "$dbname" < /root/JShielder/UbuntuServer_18.04LTS/a1/panel/info/dump.sql
	
	exit


# If /root/.my.cnf doesn't exist then it'll ask for root password	
else
	echo "Please enter root user MySQL password!"
	read rootpasswd
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
	
	mysql -u "$usernamedb" -p "$userdbpass" "$dbname" < /root/JShielder/UbuntuServer_18.04LTS/a1/panel/info/dump.sql
	exit
fi
       
        echo "Setup adminpanel..."
        
	sed -i -e "s/panelreplace/$panelname/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	sed -i -e "s/dbuserreplace/$usernamedb/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	sed -i -e "s/dbpassreplace/$userdbpass/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
        sed -i -e "s/dbnamereplace/$dbname/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	sed -i -e "s/adminpaswreplace/$adminpassw/g" /root/JShielder/UbuntuServer_18.04LTS/a1/index.php
	rm /root/JShielder/UbuntuServer_18.04LTS/a1/panel/info/dump.sql
	mv /root/JShielder/UbuntuServer_18.04LTS/a1/panel /root/JShielder/UbuntuServer_18.04LTS/a1/$panelname
	


        cp -aR /root/JShielder/UbuntuServer_18.04LTS/a1/. /var/www/html/


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
    apt purge at
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
  say_done

}
##############################################################################################################

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
extract_a1
secure_tmp
install_apache
install_secure_php
install_modsecurity
set_owasp_rules
install_modevasive
install_qos_spamhaus
secure_optimize_apache
install_fail2ban
install_secure_mysql
create__mysql_user_db_a1
tune_secure_kernel
tune_nano_vim_bashrc
daily_update_cronjob
additional_hardening
apache_conf_restrictions
unattended_upgrades
file_permissions
;;

2)
exit 0
;;

esac
##############################################################################################################