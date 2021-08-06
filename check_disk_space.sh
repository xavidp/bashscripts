#/bin/bash
SMTP="localhost"
EMAILF="foo@example.com"
EMAILT="bar1@example.com,bar2@example.com"
# set alert-level on a given %
ALERT=99
df -H 2> /dev/null | grep -vE '^Filesystem|tmpfs|cdrom|dev$|snap|sys|run|docker|windows/o|S\.\ fitxers' | awk '{ print $5 " " $6 }' | while read output;
do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
#    echo "space low on \"$partition ($usep%)\", on server $(hostname) at $(date)" > last_alert.txt
#    echo "space low on \"$partition ($usep%)\", on server $(hostname) at $(date +\"%Y-%m-%d\")" | sendemail -f $EMAILF -t $EMAILT -u 'Alert: Free space low' -a last_alert.txt -s $SMTP -o tls=no
    echo "space low on \"$partition ($usep%)\", on server $(hostname) at $(date +\"%Y-%m-%d\ %H:%M\")" | sendemail -f $EMAILF -t $EMAILT -u '[Alert][Server XXX]: disk filling up' -s $SMTP -o tls=no
 fi
done
