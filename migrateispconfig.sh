#!/bin/bash
#
  echo "############################################################"
  echo "##                     Welcome                            ##"
  echo "##   Please take note of all instructions and             ##"
  echo "##   recommendations                                      ##"
  echo "##                                                        ##"
  echo "##   If you have questions or problems you can always     ##"
  echo "##   visit http://wiki.teris-cooper.de                    ##"
  echo "##                                                        ##"
  echo "##   Alternatively you're welcome to send an email to     ##"
  echo "##   admin [at] teris-cooper [dot] de                     ##"
  echo "############################################################"
  echo ""
  echo "Please enter the IP address of your master (remote) server:"
  read main_server


#common_args='-aPv --delete'
#common_args='-aPv --dry-run'
common_args='-aPv'
install_rsync="apt-get -y install rsync"
www_start="service apache2 start"
www_stop="service apache2 stop"
db_start="service mysql start"
db_stop="service mysql stop"

function menu {
    clear
    echo "############################################################"
    echo "##                    Main menu                           ##"
    echo "##                                                        ##"
    echo "## Install RSync on the remote server                  (1)##"
    echo "## Synchronize MySql                                   (2)##"
    echo "## Synchronize websites                                (3)##"
    echo "## Synchronize email                                   (4)##"
    echo "## Synchronize passwords, users and other files        (5)##"
    echo "## Synchronize MailMan                                 (6)##"
    echo "## Synchronize LetsEncrypt                             (7)##"
    echo "## Exit program                                        (0)##"
    echo "############################################################"
    read -n 1 eingabe
}

function install {
    clear
    echo "Installing RSync on the remote server..."
    ssh $main_server "$install_rsync"
    echo "Installation complete"
    menu
}

function db_migration {
    clear
  echo "###############################################################"
  echo "###############################################################"
  echo "############## Start MySql Migration              #############"
  echo "############## Step1:                             #############"
  echo "############## Back up the remote databases       #############"
  echo "###############################################################"
  echo "############## Step2:                             #############"
  echo "############## Copy the backed-up databases       #############"
  echo "###############################################################"
  echo "############## Step3:                             #############"
  echo "############## Import the databases into MySql    #############"
  echo "###############################################################"
  echo "###############################################################"
  echo " "
  echo "Back up the remote databases............................................................."
  echo "Please enter the MySql password for the root user on the remote server $main_server:....."
  read mysqlext
  ssh $main_server "mkdir /root/mysql; mysqldump -u root -p$mysqlext --force --all-databases > /root/mysql/fulldump.sql"
  clear
  echo "Copy the backup.........................................................................."
  rsync $common_args $main_server:/root/mysql/ /root/mysql
  clear
  echo "Import the backup........................................................................"
  echo "Please enter the MySql password for the root user on this server:........................"
  read mysql2
  mysql -u root -p$mysql2 < /root/mysql/fulldump.sql
  clear
  echo "Upgrade mysql system tables if target server has newer mysql/mariadb versions..........................................................."
  mysql_upgrade -uroot -p --force
  #
  # mysql_upgrade also does:
  ## mysqlcheck --all-databases --check-upgrade --auto-repair
  ## mysql < fix_priv_tables
  #
  # Therefore, no need to run again mysqlcheck with autorepair below
  ##echo "Check and repair the databases..........................................................."
  ##mysqlcheck -p -A --auto-repair
  echo "###############################################################"
  echo "###############################################################"
  menu
}

function www_migration {
    clear

  echo "############################################################"
  echo "############################################################"
  echo "################## Web Migration          ##################"
  echo "################## Step1:                 ##################"
  echo "################## Stop the webserver     ##################"
  echo "############################################################"
  echo "################## Step2:                 ##################"
  echo "################## Start the migration    ##################"
  echo "############################################################"
  echo "################## Step3:                 ##################"
  echo "################## Start the webserver    ##################"
  echo "############################################################"
  $www_stop
  rsync $common_args --compress --delete $main_server:/var/www/ /var/www
  rsync $common_args --compress --delete $main_server:/var/log/ispconfig/httpd/ /var/log/ispconfig/httpd
  $www_start
  echo "############################################################"
  echo "############################################################"
  menu
}

function mail_migration {
    clear
  echo "############################################################"
  echo "############################################################"
  echo "################## Mail Migration         ##################"
  echo "################## Step1:                 ##################"
  echo "################## Migrate vmail          ##################"
  echo "############################################################"
  echo "################## Step2:                 ##################"
  echo "################## Migrate vmail logs     ##################"
  echo "############################################################"
  rsync $common_args --compress --delete $main_server:/var/vmail/ /var/vmail
  rsync $common_args --compress --delete $main_server:/var/log/mail.* /var/log/
  echo "############################################################"
  echo "############################################################"
  menu
}

function files_migration {
    clear
  echo "############################################################"
  echo "############################################################"
  echo "############# Files Migration                        #######"
  echo "############# Step1:                                 #######"
  echo "############# Copy /var/backup                       #######"
  echo "############################################################"
  echo "############# Step2:                                 #######"
  echo "############# Copy /etc/passwd to /root/old-server   #######"
  echo "############################################################"
  echo "############# Step3:                                 #######"
  echo "############# Copy /etc/group to /root/old-server    #######"
  echo "############################################################"
  echo "############# Please manually install passwd+group   #######"
  echo "############# (see readme.md)                        #######"
  echo "############################################################"
  echo "############# Step4:                                 #######"
  echo "############# Copy /etc/apache2/sites-available      #######"
  echo "############################################################"
  echo "############# Step5:                                 #######"
  echo "############# Copy /etc/apache2/sites-enabled        #######"
  echo "############################################################"
  rsync $common_args $main_server:/var/backup/ /var/backup
  rsync $common_args $main_server:/etc/passwd /root/old-server/
  rsync $common_args $main_server:/etc/group  /root/old-server/
  rsync $common_args $main_server:/etc/shadow  /root/old-server/
  rsync $common_args $main_server:/etc/gshadow  /root/old-server/
  rsync $common_args $main_server:/etc/apache2/sites-available/ /etc/apache2/sites-available
  rsync $common_args $main_server:/etc/apache2/sites-enabled/ /etc/apache2/sites-enabled
  echo "############################################################"
  echo "############################################################"
  menu
}

function mailman_migration {
    clear
  echo "############################################################"
  echo "############################################################"
  echo "############ Mailman migration                 #############"
  echo "############################################################"
  rsync $common_args --compress --delete $main_server:/var/lib/mailman/lists /var/lib/mailman
  rsync $common_args --compress --delete $main_server:/var/lib/mailman/data /var/lib/mailman
  rsync $common_args --compress --delete $main_server:/var/lib/mailman/archives /var/lib/mailman
  cd /var/lib/mailman/bin && ./genaliases
  echo "############################################################"
  echo "############################################################"
  menu
}
function le_migration {
    clear
  echo "############################################################"
  echo "############################################################"
  echo "############ LetsEncrypt migration             #############"
  echo "############################################################"
  rsync $common_args --compress $main_server:/etc/letsencrypt /etc
  echo "############################################################"
  echo "############################################################"
  menu
}
function beenden {
        clear
        exit
}
menu
while [ "$eingabe" != "0" ]
do
case "$eingabe" in
    0) beenden
    ;;
    1) install
    ;;
    2) db_migration
    ;;
    3) www_migration
    ;;
    4) mail_migration
    ;;
    5) files_migration
    ;;
    6) mailman_migration
    ;;
    7) le_migration
    ;;
esac    
done
