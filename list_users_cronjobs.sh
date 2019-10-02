# Derived from https://askubuntu.com/a/274437/538432
for user in $(cut -f1 -d: /etc/passwd)
do
  echo $user
  crontab -u $user -l
done
