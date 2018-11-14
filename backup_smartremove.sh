# From https://stackoverflow.com/questions/27245182/bash-script-for-deleting-old-backup-files
# it doesn't properly delete files from this year which doesn't match the days indicated
# don't use in production yet (untested); it's a work in progress; use at your own risk
#!/bin/bash
cd ../tmp_backups/
read YEAR MONTH <<<$(date "+%Y %m")
LASTYEAR=$(( YEAR-1 ))
DAYS=" 07 14 21 28 "

for fn in $( ls )
do
     DELETE=false

     if   [ "${fn:0:7}" = "$YEAR-$MONTH" ] &&
          [ "${DAYS/ ${fn:8:2} /}" != "$DAYS" ]
     then
          DELETE=true
     elif [ "${fn:0:4}" = "$LASTYEAR" ] &&
          [ "${fn:8:2}" != ${DAYS:1:2} ]
     then
          DELETE=true
     fi

     if [ "$DELETE" = true ]
     then
          OUTPUT=`rm -v -R $fn`
          echo "$fn"
     fi
done
