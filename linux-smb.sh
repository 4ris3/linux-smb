user=$(whoami)
#create folders admin_files and others_files and set permissions/own
cd /srv/
sudo mkdir smb
cd smb/
sudo mkdir admin_files
sudo mkdir others_files
sudo chown $user:$user admin_files
sudo chmod 2770 admin_files
sudo chown nobody:nogroup others_files
sudo chmod 2777 others_files
#download and start samba
sudo apt install samba -y
sudo systemctl start smbd
#config smb.conf
sudo rm /etc/samba/smb.conf
sudo mv /home/$user/server/smb.conf /etc/samba/
sudo sed -i "s/changeitquickly/$user/g" /etc/samba/smb.conf
echo -e "1234\n1234" | sudo smbpasswd -a $user
sudo systemctl restart smbd