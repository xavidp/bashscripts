date
sudo date -s "$(wget -qSO- --max-redirect=0 https://google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z" | sudo hwclock --systohc
date
