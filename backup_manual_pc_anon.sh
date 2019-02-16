#!/bin/bash
#######################################
### PARAMETERS TO CUSTOMIZE THE SCRIPT
#######################################
### Generic Label for the username ###
username="myuser"
### Generic Label for the computer ###
pcname="mypc"
### Generic Label for the user and computer for mysql ###
MLABEL=$username"_"$pcname
### MySQL Server Login Info ###
MUSER="username"
MPASS="********"
MHOST="localhost"
### FTP SERVER Login info ###
FTPU="ftpuser"
FTPP="ftppass"
FTPS="ftpserver"
FTPF="./backups/"$pcname
NOWD=$(date +"%Y-%m-%d")
NOWT=$(date +"%H_%M_%S")
### USB BACKUP folder (if used instead of FTP)
USBBAK="/media/xavi/usbbackups"
## Some paths defined
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
BAKPATH="/home/"$username"/backups_locals" # TODO: make the folliwng paths relative to this one
BAK=$pcname
TIKIFILESABSPATH="/var/www/tiki_files"
# Relative paths to backup folders
RBAK1="mysql"
RBAK2="tikifiles"
RBAK3="serverfiles"
RBAK4="home"$username"files"
EMAILF="username@example.com"
EMAILT="email@example.com"
SMTP="smtp.example.com"

#### End of parameters
#######################################


# Base path for backup folders
BBAK=$BAKPATH/$BAK/$NOWD
# Absolute paths to backup folders (base path + relative path)
ABAK1=$BBAK/$RBAK1
ABAK2=$BBAK/$RBAK2
ABAK3=$BBAK/$RBAK3
ABAK4=$BBAK/$RBAK4
# Other variables used
GZIP="$(which gzip)"
# Relative paths for each log file
RLOGF=log-$MLABEL-SUM.$NOWD.txt
RLOGF1=log-$MLABEL-$RBAK1.$NOWD.txt
RLOGF2=log-$MLABEL-$RBAK2.$NOWD.txt
RLOGF3=log-$MLABEL-$RBAK3.$NOWD.txt
RLOGF4=log-$MLABEL-$RBAK4.$NOWD.txt
# Base log path (set by default to the same base path for backups)
BLOGF=$BBAK
# Absolute path for log files
ALOGF=$BLOGF/$RLOGF
ALOGF1=$BLOGF/$RLOGF1
ALOGF2=$BLOGF/$RLOGF2
ALOGF3=$BLOGF/$RLOGF3
ALOGF4=$BLOGF/$RLOGF4


### These next parts (1) & (2) are related to the removal of previous files in these folders if they exist, and create dirs as needed for new set of periodic backups ###

## (1) To remove all previous backups locally at the server and at the same base backup folder, uncomment the following line
#[ ! -d $BAKPATH/$BAK ] && mkdir -p $BAKPATH/$BAK || /bin/rm -rf $BAKPATH/$BAK/*

## (2) To avoid removing previous backups from teh same day locally, keep the last part commeted out (with ## just in front of "|| /bin/rm -rf ..." )
[ ! -d $ABAK1 ] && mkdir -p $ABAK1 # || /bin/rm -rf $ABAK1/*
[ ! -d $ABAK2 ] && mkdir -p $ABAK2 # || /bin/rm -rf $ABAK2/*
[ ! -d $ABAK3 ] && mkdir -p $ABAK3 # || /bin/rm -rf $ABAK3/*
[ ! -d $ABAK4 ] && mkdir -p $ABAK4 # || /bin/rm -rf $ABAK4/*
### [ ! -d "$BAK" ] && mkdir -p "$BAK" ###
 
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
 FILE=$ABAK1/$db.$NOWD-$NOWT.gz
 $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done
 
### Backup tikifiles ###
#tar -czvf $ABAK2/00-$RBAK2-$MLABEL.$NOWD-$NOWT.tgz $TIKIFILESABSPATH/* >  $ALOGF2

### Backup systemfiles ###
tar -czhvf $ABAK3/00-$RBAK3-$MLABEL.$NOWD-$NOWT.tgz /etc/* /usr/local/ispconfig/* /root/.luckyBackup/* /root/.local/* /root/.ssh/* /root/.config/.*  >  $ALOGF3

### Backup home user files ###
tar -czhvf $ABAK4/00-$RBAK4-$MLABEL.$NOWD-$NOWT.tgz /home/$username/scripts/* /home/$username/.local/* /home/$username/.config/* /home/$username/.Skype/* /home/$username/.luckyBackup/* /home/$username/.ssh/* /home/$username/.purple/* /home/$username/.kde/*  /home/$username/.thunderbird/* /home/$username/Sync/yourcriticalfolder/*  \
		--exclude='.WebIde*' --exclude='.config/variet*' --exclude='.local/share/Trash' --exclude='code/*' >  $ALOGF4

### Send files over ftp ###
#lftp -u $FTPU,$FTPP -e "mkdir $FTPF/$NOWD;cd $FTPF/$NOWD; mput $ABAK1/*.gz; mput $ABAK2/*.tgz; mput $ABAK3/*.tgz; quit" $FTPS > $ALOGF
cd $ABAK1;ls -lh * > $ALOGF1
# Add a short summary with partial dir sizes and append all partial log files into one ($LOGF)
cd $BBAK;du -h $RBAK1 $RBAK2 $RBAK3 $RBAK4 > $ALOGF;echo "" >> $ALOGF;echo "--- $RBAK2 uncompressed: ---------------" >> $ALOGF;du $TIKIFILESABSPATH -h --max-depth=2 >> $ALOGF

### Compress log files ###
tar -czvf $ALOGF1.tgz -C $BLOGF $RLOGF1
#tar -czvf $ALOGF2.tgz -C $BLOGF $RLOGF2
tar -czvf $ALOGF3.tgz -C $BLOGF $RLOGF3
tar -czvf $ALOGF4.tgz -C $BLOGF $RLOGF4

### save report of files sizes
echo $NOWD"_allSize_"`du . -hs` | xargs touch
du . -h --max-depth=3 | grep G > $NOWD"_logBigSizes".txt
du . -h --max-depth=3 | grep M >> $NOWD"_logBigSizes".txt

### Changing perms for standard user
chmod 600 * -R
chown $username:$username * -R

### Send log files ###
#lftp -u $FTPU,$FTPP -e "cd $FTPF/$NOWD; put $ALOGF1.tgz; put $ALOGF2.tgz; put $ALOGF3.tgz; put $ALOGF4.tgz; quit" $FTPS

### Clon the local backup at the USB location
mkdir -p $USBBAK/$BAK/$NOWD;cp $BBAK/* -R $USBBAK/$BAK/$NOWD
### Changing perms of usbbackup folder for standard user
chmod 600 $USBBAK/$BAK/$NOWD
chown $username:$username $USBBAK/$BAK/$NOWD/ $USBBAK/$BAK/$NOWD/* -R

### Send report through email ###
### See documentation about sendmail at: 
### https://github.com/mogaal/sendemail
### Display ALOGF (summary of sizes of the compressed files) in the message body (cat file before the pipe)
cat $ALOGF | sendemail -f $EMAILF -t $EMAILT -u '['$username' at '$pcname': Custom Backup Report]' -a $ALOGF1 -s $SMTP -o tls=no
