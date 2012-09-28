# Xavier de Pedro Puente - VHIR - UEB - xavier.depedro (a) vhir.org
#
# Change directory to where all files will be saved
cd /home/ueb/Documents/Spammers_Info/

# Get daily info on error codes 400, 403 and 404 from apache access logs, while removing lines which include '" httpd://', since they belong to false positives produced by legitimate visitors from web pages which have some missing file due to human error or simple bugs, etc. Save those lines in a daily text file which has been prefixed with the date in yyyy-mm-dd_ format.
cat /var/log/apache2/access.log | egrep --color " 400 | 403 | 404 "  | egrep " \"http://" -v >> `date +%y-%m-%d`_errors_400_403_404_b52.csv
	### Append that daily info into a comprehensive file.
	cat `date +%y-%m-%d`_errors_400_403_404_b52.csv >> 00_all_errors_400_403_404_b52.csv

# Sort those lines by the originating IP, and remove duplicates if any (duplicates are present when the previous line is run more than once a day, when there are some tests performed, of the script fine tuned, etc)
sort -u `date +%y-%m-%d`_errors_400_403_404_b52.csv > `date +%y-%m-%d`_errors_400_403_404_b52_sorted_nodup.csv

# Get content from hosts.deny, delete all comments, remove the "sshd: " from the lines which contain the offending ip , and save the result in the file hosts.deny.clean.sorted.txt on disk
sed '/^#/ d' /etc/hosts.deny | sed 's/sshd: //' | sort > hosts.deny.clean.sorted.txt

# Start adding populating the file "yyyy-mm-dd_offending_ips.b52.csv" with the file "yyyy-mm-dd_errors_400_403_404_b52_sorted_nodup.csv" 
cp `date +%y-%m-%d`_errors_400_403_404_b52_sorted_nodup.csv `date +%y-%m-%d`_offending_ips.b52.csv
	### Append (">>") each day the contents of the file "yyyy-mm-dd_errors_400_403_404_b52_sorted_nodup.csv" into the file "00_all_offending_ips.b52.csv" 
	cat `date +%y-%m-%d`_errors_400_403_404_b52_sorted_nodup.csv >> 00_all_offending_ips.b52.csv

# Append (">>") the content of "hosts.deny.clean.sorted.txt" to the previous file "yyyy-mm-dd_offending_ips.b52.csv" which so far only included the info from document types 400 403 and 404 from apache access logs.
cat hosts.deny.clean.sorted.txt >> `date +%y-%m-%d`_offending_ips.b52.csv
	### Do the equivalent with  the comprehensive file "00_all_offending_ips.b52.csv" 
	cat hosts.deny.clean.sorted.txt >> 00_all_offending_ips.b52.csv
	### Do the equivalent with  the comprehensive file "00_all_offending_ips_plus_glodev.b52.csv" 
	cat hosts.deny.clean.sorted.txt >> 00_all_offending_ips_plus_glodev.b52.csv

# Sort all lines by ip, since all lines start with their corresponding offending ip, compress it with gzip and save it to disk
sort `date +%y-%m-%d`_offending_ips.b52.csv > `date +%y-%m-%d`_offending_ips.b52.sorted.csv
        ### Do the equivalent with  the comprehensive file "00_all_offending_ips.b52.csv"  and compress it with gzip
        sort -u 00_all_offending_ips.b52.csv | gzip > 00_all_offending_ips.b52.sorted.csv.gz
	### Do the equivalent with  the comprehensive file "00_all_offending_ips_plus_glodev.b52.csv" and compress it with gzip
	sort -u 00_all_offending_ips_plus_glodev.b52.csv | gzip > 00_all_offending_ips_plus_glodev.b52.sorted.csv.gz

# Send the report file by email
sendemail -f xdpedro@ir.vhebron.net -t xavier.depedro@vhir.org -u 'Offending IPs to B52' -m 'See attachment' -a `date +%y-%m-%d`_offending_ips.b52.sorted.csv -a 00_all_offending_ips.b52.sorted.csv.gz -a 00_all_offending_ips_plus_glodev.b52.sorted.csv.gz -s servirmta1.ir.vhebron.net

# Clean temp files (all except the 00_all_*, and the *_sorted.csv or *_sorted_nodup.csv)
rm `date +%y-%m-%d`_errors_400_403_404_b52.csv
rm `date +%y-%m-%d`_offending_ips.b52.csv
