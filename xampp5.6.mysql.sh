sudo service mysql stop
sudo service apache2 stop
sudo /opt/lampp/xampp stop
sudo rm /opt/lampp
sudo ln -s /opt/lampp-5.6.12-mysql /opt/lampp
sudo /opt/lampp/xampp start
gksu '/opt/lampp/manager-linux-x64.run'
