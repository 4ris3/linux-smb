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
cat > /etc/samba/smb.conf << EOF
[global]
         workgroup = WORKGROUP
         map to guest = bad user
         guest account = nobody
         server string = %h server (Samba, Ubuntu)
         log file = /var/log/samba/log.%m
         max log size = 1000
         logging = file
         panic action = /usr/share/samba/panic-action %d
         server role = standalone server
         obey pam restrictions = yes
         unix password sync = yes
         passwd program = /usr/bin/passwd %u
         passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
         pam password change = yes
         map to guest = bad user
         usershare allow guests = yes

      [admin]
      path = /srv/smb/admin_files
      browseable = yes
      writable = yes
      valid users = $user
      read only = no

      [others]
      path = /srv/smb/others_files
      browseable = yes
      writable = yes
      guest ok = yes
      read only = no
EOF
echo -e "1234\n1234" | sudo smbpasswd -a $user
sudo systemctl restart smbd