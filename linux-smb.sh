#create folders admin_files and others_files and set permissions/own
cd /srv/
sudo mkdir smb
sudo mkdir admin_files
sudo mkdir others_files
sudo chmod 700 admin_files
sudo chown nobody:nogroup others_files
sudo chmod 777 others_files
#download and start samba
sudo apt install samba -y
sudo systemctl start smbd
