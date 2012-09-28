#/bin/bash
ADMIN="ueb@ir.vhebron.net"
# set alert-level 92 % standard
ALERT=92
df -H | grep -vE '^Filesystem|tmpfs|cdrom|MainHead' | awk '{ print $5 " " $6 }' | while read output;
do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "space low on \"$partition ($usep%)\", on server $(hostname) at $(date)" |
    mail -s "Alert: Free space low at B52, $usep % used on $partition" $ADMIN
 fi
done
