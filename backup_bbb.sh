#!/bin/bash
#######################################
### PARAMETERS TO CUSTOMIZE THE SCRIPT
#######################################
### Generic Label for the server ###
MLABEL="bbb.example.org"
### FTP SERVER Login info ###
FTPU="ftpuser"
FTPP="ftppass"
FTPS="ftpserver"
FTPF="./backups/bbb.example.org"
NOWD=$(date +"%Y-%m-%d")
NOWT=$(date +"%H_%M_%S")
## Some paths defined
BAKPATH="/home/exampleuser" 
BAK="backups"
## For BBB, you could record ALL folders 
BBBFILESABSPATH1="/var/bigbluebutton/"
## Alternatively, you could only backup the recordings for playback
BBBFILESABSPATH2a="/var/bigbluebutton/recording/publish/" # For BBB 0.81
BBBFILESABSPATH2b="/var/bigbluebutton/publish/slides/" # For BBB 0.80
## Choose the BBB recording that your prefer
BBBFILESABSPATH=$BBBFILESABSPATH1
## And record log files
BBBLOGSABSPATH="/var/log/bigbluebutton/"
# Relative paths to backup folders
RBAK3="serverfiles"
RBAK4="bbb"
EMAILF="exampleuser1@example.org"
EMAILT="exampleuser2@example.org"
SMTP="localhost"

#### End of parameters
#######################################


# Base path for backup folders
BBAK=$BAKPATH/$BAK/$NOWD
# Absolute paths to backup folders (base path + relative path)
ABAK3=$BBAK/$RBAK3
ABAK4=$BBAK/$RBAK4
# Other variables used
GZIP="$(which gzip)"
# Relative paths for each log file
RLOGF=log-$MLABEL-SUM.$NOWD.txt
RLOGF3=log-$MLABEL-$RBAK3.$NOWD.txt
RLOGF4=log-$MLABEL-$RBAK4.$NOWD.txt
# Base log path (set by default to the same base path for backups)
BLOGF=$BBAK
# Absolute path for log files
ALOGF=$BLOGF/$RLOGF
ALOGF3=$BLOGF/$RLOGF3
ALOGF4=$BLOGF/$RLOGF4


### These next parts (1) & (2) are related to the removal of previous files in these folders if they exist, and create dirs as needed for new set of periodic backups ###

## (1) To remove all previous backups locally at the server and at the same base backup folder, uncomment the following line
[ ! -d $BAKPATH/$BAK ] && mkdir -p $BAKPATH/$BAK || /bin/rm -rf $BAKPATH/$BAK/*

## (2) To avoid removing previous backups from the same day locally, keep the last part commeted out (with ## just in front of "|| /bin/rm -rf ..." )
[ ! -d $ABAK3 ] && mkdir -p $ABAK3 || /bin/rm -rf $ABAK3/*
[ ! -d $ABAK4 ] && mkdir -p $ABAK4 || /bin/rm -rf $ABAK4/*
### [ ! -d "$BAK" ] && mkdir -p "$BAK" ###

### Backup serverfiles ###
tar -czhvf $ABAK3/00-$RBAK3-$MLABEL.$NOWD-$NOWT.tgz /etc/* /root/.local/* /root/.ssh/* /root/.config/.*  >  $ALOGF3

### Backup bbb (files and logs)###
tar -czhvf $ABAK4/00-$RBAK4-$MLABEL.$NOWD-$NOWT.tgz $BBBFILESABSPATH/* $BBBLOGSABSPATH/* >  $ALOGF4
## Or manually indicate several backup paths for bbb ($BBBFILESABSPATH2a for 0.81 and $BBBFILESABSPATH2b for 0.80, etc) 
#tar -czhvf $ABAK4/00-$RBAK4-$MLABEL.$NOWD-$NOWT.tgz $BBBFILESABSPATH2a/* $BBBFILESABSPATH2b/* $BBBLOGSABSPATH/* >  $ALOGF4

### Send files over ftp ###
lftp -u $FTPU,$FTPP -e "mkdir $FTPF/$NOWD;cd $FTPF/$NOWD; mput $ABAK3/*.tgz; mput $ABAK4/*.tgz; quit" $FTPS > $ALOGF
cd $ABAK1;ls -lh * > $ALOGF1
# Add a short summary with partial dir sizes and append all partial log files into one ($LOGF)
cd $BBAK;du -h $RBAK3 $RBAK4 > $ALOGF;echo "" >> $ALOGF;echo "--- $RBAK4 uncompressed: ---------------" >> $ALOGF;du $BBBFILESPATH -h --max-depth=2 >> $ALOGF

# Add a short summary with partial dir sizes and append all partial log files into one ($LOGF)
cd $BBAK;du -h $RBAK4 > $ALOGF;echo "" >> $ALOGF;du $BBBFILESABSPATH -h --max-depth=2 >> $ALOGF

### Compress and Send log files ###

tar -czvf $ALOGF4.tgz -C $BLOGF $RLOGF4
lftp -u $FTPU,$FTPP -e "cd $FTPF/$NOWD; put $ALOGF4.tgz; quit" $FTPS

### Send report through email ###
sendemail -f $EMAILF -t $EMAILT -u '[bbb.example.org BBB Backup Report]' -m 'Short report attached' -a $ALOGF -a $ALOGF4  -o tls=no
