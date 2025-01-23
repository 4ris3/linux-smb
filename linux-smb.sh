user=$(whoami)
#.ssh exists?
if [ ! -d "~/.ssh" ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
fi

#Add pub key
sudo echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHobJjdK4mP0++Ago9uj08Ut6dfwdgdowT09YZXyjhzo dawid@dawidsmb" >> ~/.ssh/authorized_keys
sudo chmod 600 ~/.ssh/authorized_keys
#create folders admin_files and others_files and set permissions/own
sudo mkdir -p /srv/smb/admin_files
sudo mkdir -p /srv/smb/others_files
sudo chown $user:$user admin_files
sudo chmod 2770 admin_files
sudo chown nobody:nogroup others_files
sudo chmod 2777 others_files
#download and start packages
sudo apt install samba -y
sudo systemctl start smbd
sudo apt install openssh-server -y
sudo systemctl start openssh-server
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
sudo systemctl enable smbd
sudo systemctl enable openssh-server
sudo systemctl restart smbd
sudo systemctl restart openssh-server