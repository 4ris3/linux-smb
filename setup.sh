#!/bin/bash
set -e

# Create user 'dev' and setup permissions
useradd -m -d /home/dev -s /bin/bash dev
groupadd admin_group
usermod -aG sudo,admin_group dev

# Setup SSH directory
mkdir -p /home/dev/.ssh
chmod 700 /home/dev/.ssh
chown dev:dev /home/dev/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPNC0iws3HMtbgp9kZftYGJNBqglDAAXojT50Xce07Yd dawid@dawidsmb" > /home/dev/.ssh/authorized_keys
chmod 600 /home/dev/.ssh/authorized_keys
chown dev:dev /home/dev/.ssh/authorized_keys

# Create and set permissions for Samba shares
mkdir -p /srv/smb/admin_files /srv/smb/others_files
chown dev:admin_group /srv/smb/admin_files
chmod 2770 /srv/smb/admin_files
chown nobody:nogroup /srv/smb/others_files
chmod 2777 /srv/smb/others_files

#create allias
echo "alias smcheck='sudo systemctl status smbd'" >> ~/.bashrc
echo "alias sscheck='sudo systemctl status ssh'" >> ~/.bashrc

#!/bin/bash

# Start Samba ssh
mkdir -p /run/sshd
/usr/sbin/smbd -D
/usr/sbin/nmbd -D  # 
/usr/sbin/sshd
echo "Starting services..."
tail -f /dev/null