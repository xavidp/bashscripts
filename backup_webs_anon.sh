#!/bin/bash
#######################################
### PARAMETERS TO CUSTOMIZE THE SCRIPT
#######################################
### Generic Label for the server ###
MLABEL="myserver"
### MySQL Server Login Info ###
MUSER="mysqluser"
MPASS="*******"
MHOST="localhost"
### FTP SERVER Login info ###
FTPU="ftpuser"
FTPP="ftppass"
FTPS="ftpserver"
FTPF="./backups_user/myserver"
NOWD=$(date +"%Y-%m-%d")
NOWT=$(date +"%H_%M_%S")
## Some paths defined
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
BAKPATH="/home/myuser" # TODO: make the folliwng paths relative to this one
BAK="backup_webs_myserver"
TIKIFILESABSPATH="/var/www/tiki_files"
# Relative paths to backup folders
RBAK1="mysql"
RBAK2="tikifiles"
RBAK3="serverfiles"
EMAILF="emailfrom@example.com"
EMAILT="emailto@example.com"
SMTP="localhost"

#### End of parameters
#######################################


# Base path for backup folders
BBAK=$BAKPATH/$BAK/$NOWD
# Absolute paths to backup folders (base path + relative path)
ABAK1=$BBAK/$RBAK1
ABAK2=$BBAK/$RBAK2
ABAK3=$BBAK/$RBAK3
# Other variables used
GZIP="$(which gzip)"
# Relative paths for each log file
RLOGF=log-$MLABEL-SUM.$NOWD.txt
RLOGF1=log-$MLABEL-$RBAK1.$NOWD.txt
RLOGF2=log-$MLABEL-$RBAK2.$NOWD.txt
RLOGF3=log-$MLABEL-$RBAK3.$NOWD.txt
# Base log path (set by default to the same base path for backups)
BLOGF=$BBAK
# Absolute path for log files
ALOGF=$BLOGF/$RLOGF
ALOGF1=$BLOGF/$RLOGF1
ALOGF2=$BLOGF/$RLOGF2
ALOGF3=$BLOGF/$RLOGF3


### These next parts (1) & (2) are related to the removal of previous files in these folders if they exist, and create dirs as needed for new set of periodic backups ###

## (1) To remove all previous backups locally at the server and at the same base backup folder, uncomment the following line
#[ ! -d $BAKPATH/$BAK ] && mkdir -p $BAKPATH/$BAK || /bin/rm -rf $BAKPATH/$BAK/*

## (2) To avoid removing previous backups from the same day locally, keep the last part commeted out (with ## just in front of "|| /bin/rm -rf ..." )
[ ! -d $ABAK1 ] && mkdir -p $ABAK1 || /bin/rm -rf $ABAK1/*
[ ! -d $ABAK2 ] && mkdir -p $ABAK2 || /bin/rm -rf $ABAK2/*
[ ! -d $ABAK3 ] && mkdir -p $ABAK3 || /bin/rm -rf $ABAK3/*
### [ ! -d "$BAK" ] && mkdir -p "$BAK" ###
 
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
 FILE=$ABAK1/$db.$NOWD-$NOWT.gz
 $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db --single-transaction | $GZIP -9 > $FILE
done
 
### Backup tikifiles ###
tar -chzvf $ABAK2/00-$RBAK2-$MLABEL.$NOWD-$NOWT.tgz $TIKIFILESABSPATH/* >  $ALOGF2

# Keep track of crontab tasks and /etc/fstab by means of saving them to a file on disk
crontab -l > /home/myuser/scripts/crontab_root.txt
cat /etc/fstab > /home/myuser/scripts/etc_fstab.txt

### Backup serverfiles ###
crontab -l > /root/.crontab.txt
tar --exclude='/root/..' -chzvf $ABAK3/00-$RBAK3-$MLABEL.$NOWD-$NOWT.tgz /etc/* /root/.* /home/myuser/scripts/* /srv/* /var/log/* >  $ALOGF3

### Send files over ftp ###
#lftp -u $FTPU,$FTPP -e "mkdir -p $FTPF/$NOWD;cd $FTPF/$NOWD; mput $ABAK1/*.gz; mput $ABAK2/*.tgz; mput $ABAK3/*.tgz; quit" $FTPS > $ALOGF
# If lftp fails complaining about ssl cert cannot be trusted etc, dissalow verifying the certificate in the command:
#lftp -u $FTPU,$FTPP -e "set ssl:verify-certificate no; mkdir -p $FTPF/$NOWD;cd $FTPF/$NOWD; mput $ABAK1/*.gz; mput $ABAK2/*.tgz; mput $ABAK3/*.tgz; quit" $FTPS > $ALOGF
cd $ABAK1;ls -lh * > $ALOGF1
# Add a short summary with partial dir sizes and append all partial log files into one ($LOGF)
cd $BBAK;du -h $RBAK1 $RBAK2 $RBAK3 > $ALOGF;echo "" >> $ALOGF;echo "--- $RBAK2 uncompressed: ---------------" >> $ALOGF;du $TIKIFILESABSPATH -h --max-depth=2 >> $ALOGF

### Compress and Send log files ###
tar -czvf $ALOGF1.tgz -C $BLOGF $RLOGF1
tar -czvf $ALOGF2.tgz -C $BLOGF $RLOGF2
tar -czvf $ALOGF3.tgz -C $BLOGF $RLOGF3
#lftp -u $FTPU,$FTPP -e "set ssl:verify-certificate no;cd $FTPF/$NOWD; put $ALOGF1.tgz; put $ALOGF2.tgz; put $ALOGF3.tgz; quit" $FTPS

### Send report through email ###
sendemail -f $EMAILF -t $EMAILT -u '[MyServer webs Backups Report]' -m 'Short report attached' -a $ALOGF -a $ALOGF1 -s $SMTP -o tls=no


