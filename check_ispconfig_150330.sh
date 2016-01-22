#!/bin/bash
###################################################################################################################################################
###################################################################################################################################################
#### #####
#### This script is created by Srijan Kishore to cross-check the complete installation of tutorial #####
#### #####
###################################################################################################################################################
###################################################################################################################################################

cd /tmp

###################################################################################################################################################
#### Installations done in Tutorial #####
###################################################################################################################################################

echo "amavisd-new
apache2
apache2-doc
apache2-suexec
apache2-utils
apt-listchanges
arj
autoconf
automake1.9
awstats
bind9
binutils
bison
build-essential
bzip2
cabextract
clamav
clamav-daemon
clamav-docs
daemon
debhelper
dnsutils
dovecot-imapd
dovecot-mysql
dovecot-pop3d
dovecot-sieve
fail2ban
flex
geoip-database
getmail4
imagemagick
jailkit
libapache2-mod-fastcgi
libapache2-mod-fcgid
libapache2-mod-php5
libapache2-mod-python
libapache2-mod-suphp
libauthen-sasl-perl
libclass-dbi-mysql-perl
libio-socket-ssl-perl
libio-string-perl
libnet-dns-perl
libnet-ident-perl
libnet-ldap-perl
libruby
libtool
lzop
mailman
mcrypt
memcached
mysql-client
mysql-server
nomarch
ntp
ntpdate
openssl
php5
php5-cgi
php5-cli
php5-common
php5-curl
php5-fpm
php5-gd
php5-imagick
php5-imap
php5-intl
php5-mcrypt
php5-memcache
php5-memcached
php5-ming
php5-mysql
php5-ps
php5-pspell
php5-recode
php5-snmp
php5-sqlite
php5-tidy
php5-xcache
php5-xmlrpc
php5-xsl
php-auth
phpmyadmin
php-pear
postfix
postfix-doc
postfix-mysql
rkhunter
spamassassin
squirrelmail
sudo
unzip
vlogger
webalizer
zip
zoo" > tutorial_install


##################################################################################################################################################
#### List of all packages installed by you on your server #####
##################################################################################################################################################

dpkg -l |grep ii| cut -d ' ' -f3 > server_installed

##################################################################################################################################################
#### Difference between the tutorial & your server's installation #####
##################################################################################################################################################

diff server_installed tutorial_install | grep ">" | cut -d ' ' -f2 > missing_packages

if [ $? -eq 0 ]

echo "You missed to install these packages 
` cat missing_packages` "
then 
echo "You need to install these packages. To install these packages you need to run the command apt-get install package_name"

echo " You can cross check the particular installation as follows:
dpkg -l | grep package_name | cut -d ' ' -f3

If it is showing the package_name then you can ignore the package."

else

echo "Congratulations you have installed all the packages successfully"

fi

rm -rf missing_packages server_installed tutorial_install

