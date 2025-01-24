user=$(whoami)
#.ssh exists?
if [ ! -d "~/.ssh" ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
fi

#Add pub key
sudo echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEK4bslW2t+uSdGDVdfIz0lOgIksAp/r7gtKU5cPyEna dawid@dawidsmb" >> $HOME/.ssh/authorized_keys
sudo echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEK4bslW2t+uSdGDVdfIz0lOgIksAp/r7gtKU5cPyEna dawid@dawidsmb" >> dev/.ssh/authorized_keys
sudo chmod 600 ~/.ssh/authorized_keys
#create folders admin_files and others_files and set permissions/own
sudo mkdir -p /srv/smb/admin_files
sudo mkdir -p /srv/smb/others_files
sudo chown $user:dev admin_files
sudo chmod 2770 admin_files
sudo chown nobody:nogroup others_files
sudo chmod 2777 others_files
#download and start packages
sudo apt install samba -y
sudo systemctl start smbd
sudo apt install openssh-server -y
sudo systemctl start ssh
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
sudo rm /etc/hosts
cat > /etc/hosts << EOF 
127.0.0.1 localhost
127.0.1.1 testvm
192.168.100.246 dawid

::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
echo -e "1234\n1234" | sudo smbpasswd -a $user
sudo useradd -m -d /home/dev -s /bin/bash dev
sudo usermod -aG sudo dev
sudo usermod -p '$6$4mFjYjU2g6TbDh/2$OKEsm7WTck72kMgcmLgUyAiJ2PPr/r2vHWZt6CY.6GoU/fFq7zRjo6mvKSFWwudGMp5ahSsEqwM6PUqxy7HMC0' dev
sudo systemctl enable smbd
sudo systemctl enable ssh
sudo systemctl restart smbd
sudo systemctl restart ssh