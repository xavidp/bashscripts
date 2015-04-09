#/bin/bash
#ADMIN="ueb@ir.vhebron.net"
#ADMIN="xavier.depedro@vhir.org,ueb@vhir.org"
ADMIN="xavier.depedro@vhir.org"
# set alert-level on a given %
ALERT=75
df -H | grep -vE '^Filesystem|tmpfs|cdrom|MainHead|magatzem' | awk '{ print $5 " " $6 }' | while read output;
do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "space low on \"$partition ($usep%)\", on server $(hostname) at $(date)" |
    mail -s "Alert: Free space low at B52, $usep % used on $partition" $ADMIN
 fi
done
