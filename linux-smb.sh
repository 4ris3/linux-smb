#create folders admin_files and others_files and set permissions/own
cd /srv/
sudo mkdir smb
sudo mkdir admin_files
sudo mkdir others_files
sudo group add mod
sudo chown mod:mod admin_files
sudo chmod 770 admin_files
sudo chown nobody:nogroup others_files
sudo chmod 777 others_files
#download and start samba
sudo apt install samba -y
sudo systemctl start smbd
#config smb.conf
sudo tee -a /etc/samba/smb.conf << EOF

[global]
map to guest = Bad User
guest account = nobody

[others]
path = /srv/smb/others_files
browseable = yes
writable = yes
guest ok = yes
read only = no

[admin]
path = /srv/smb/admin_files
browseable = yes
writable = yes
valid users = admin
read only = no
EOF

sudo systemctl restart smb