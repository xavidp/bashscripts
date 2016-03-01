#!/bin/sh
# Xavier de Pedro Puente - UEB-VHIR
# http://ueb.vhir.org

# Check that the script is run as root (or with sudo)
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root (run with sudo, for instance)" ; exit 1 ; fi

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
new_username=""
verbose=0

while getopts "h?vn:" opt; do
    case "$opt" in
    h|\?)
        echo "Tip: Run this script with the username as argument. I.e., for user foo.bar, run the script as 'sudo sh addtrompetauser.sh foo.bar'"
        exit 0
        ;;
    v)  verbose=1
        echo "Tip: You can also specify the new user with the argument '-n foo.bar' (i.e. 'sudo sh addtrompetauser.sh -n foo.bar')"
	echo "verbose=$verbose, new_user='$new_username', Leftovers: $@"
        ;;
    n)  new_username=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

newuser="$@"

# Check that there was a username provided as an argument in the command run
if [[ $newuser == "" ]] ; then echo "You need to specify the username you want to create. Read the help info with 'sudo addtrompetauser.sh -h'" ; exit 1 ; fi

adduser $newuser --force-badname
echo "* System user created..."
echo "export LIBGL_ALWAYS_INDIRECT=yes" >> /home/$newuser/.bashrc
#echo "export PATH=$PATH:/usr/local/stata" >> /home/$newuser/.bashrc
echo "* His/her .bashrc tweaked..."
cd /home/ueb/scripts/templates4systemusers;cp --parents Desktop/*.desktop /home/$newuser/;cd ~
echo "* Desktop shortcuts added..."
cd /home/ueb/scripts/templates4systemusers;cp --parents .trompeta/* /home/$newuser/;cd ~
echo "* Desktop icon and background files copied to the "$newuser" folders..."
cd /home/ueb/scripts/templates4systemusers;cp --parents .config/lxsession/LXDE/autostart /home/$newuser/;cd ~
echo "* Keyboard fixed..."
cd /home/ueb/scripts/templates4systemusers;cp --parents .config/pcmanfm/LXDE/*.conf /home/$newuser/;cd ~
echo "* Desktop background changed..."
sed -i -e "s/foo.bar/$newuser/g" /home/$newuser/Desktop/*.desktop
sed -i -e "s/foo.bar/$newuser/g" /home/$newuser/.trompeta/*.svg
sed -i -e "s/foo.bar/$newuser/g" /home/$newuser/.config/pcmanfm/LXDE/*.conf
echo "* Fixed paths and name for "$newuser" in desktop icons and background..."
cd /home/$newuser/;chown $newuser:$newuser Desktop Desktop/* -R;cd ~
cd /home/$newuser/;chown $newuser:$newuser .config .config/* -R;cd ~
echo "* Ownership and permissions of new folders and files fixed..."
cd /home/;chmod 770 $newuser;cd ~
echo "* Enforced privacy on user's home folder (new perms: 770)..."
echo "...We are done! :-)"
# End of file
