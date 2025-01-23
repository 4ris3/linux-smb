sudo tee -a /etc/samba/smb.conf << EOF
[global]
map to guest = Bad User
guest account = nobody
EOF