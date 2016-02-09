#!/bin/sh
# Xavier de Pedro Puente - UEB-VHIR
# http://ueb.vhir.org

# Check that the script is run as root (or with sudo)
if [[ $(id -u) -eq 0 ]] ; then echo "Please do not run as root (run without sudo, for instance)" ; exit 1 ; fi

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
myrepo=""
verbose=0

while getopts "h?vr:" opt; do
    case "$opt" in
    h|\?)
        echo "Tip: Run this script with the my local repository as argument"
        exit 0
        ;;
    v)  verbose=1
        echo "Run this script with the my local repository as argument, which should match the github repository name. I.e., for repo my.repo, run the script as 'sh fixgitueb.sh my.repo'"
	echo "verbose=$verbose, myrepo='$myrepo', Leftovers: $@"
        ;;
    r)  myrepo=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

newuser="$@"

# Check that there was a repo name provided as an argument in the command run
if [[ $myrepo == "" ]] ; then echo "You need to specify the repository name you want to create. Read the help info with 'sudo fixgitueb.sh -h'" ; exit 1 ; fi

cd ~/code/$myrepo
echo "* Changed directory ..."
git remote add origin https://github.com/xavidp/$myrepo.git
echo "* Added remote origin ..."
git remote set-url origin https://github.com/xavidp/$myrepo.git
echo "* Added remote set-url ..."
git config remote.origin.url git@github.com:xavidp/$myrepo.git
echo "* Set up config remote.origin.url ..."
#git commit -m "Added a minor change" # optional, only if requried
git config --global push.default matching
echo "* Set config global push.default matching ..."
git config --global user.name "xavidp"
echo "* Set config user.name ..."
sed -i -e "s/url = https:\/\/github.com\/xavidp\//url = git@github.com:xavidp\//g" .git/config # this seems needed from work at VHIR, otherwise it doesn't succeed pushing through Firewall/Proxy.
echo "* Replace url prefix from https:// to git@ ..."
git pull https://github.com/xavidp/$myrepo.git
echo "* Pull https://github.com/xavidp/$myrepo.git ..."
git push -u -f
echo "* Push changes as your username and forcing a merge on github with your new files only in localhost..."
git reset HEAD *
echo "* Re-set HEAD as the valid tree of changes and not your local changes anymore..."
echo "...We are done! :-)"
# End of file
