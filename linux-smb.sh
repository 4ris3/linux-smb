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

#admin_files
sudo chmod 2770 /srv/smb/admin_files
sudo chown $user:dev /srv/smb/admin_files

#others_files
sudo chown nobody:nogroup /srv/smb/others_files
sudo chmod 2777 /srv/smb/others_files

#download and start packages
sudo apt install samba -y
sudo systemctl start smbd
sudo apt install openssh-server -y
sudo systemctl start ssh
#config smb.conf
sudo rm /etc/samba/smb.conf
sudo cat > /home/$user/smb.conf << EOF
#
# Sample configuration file for the Samba suite for Debian GNU/Linux.
#
#
# This is the main Samba configuration file. You should read the
# smb.conf(5) manual page in order to understand the options listed
# here. Samba has a huge number of configurable options most of which 
# are not shown in this example
#
# Some options that are often worth tuning have been included as
# commented-out examples in this file.
#  - When such options are commented with ";", the proposed setting
#    differs from the default Samba behaviour
#  - When commented with "#", the proposed setting is the default
#    behaviour of Samba but the option is considered important
#    enough to be mentioned here
#
# NOTE: Whenever you modify this file you should run the command
# "testparm" to check that you have not made any basic syntactic 
# errors. 
#======================= Global Settings =======================
# Samba Configuration File (Simplified)
[global]
## Browsing/Identification ###
# Change this to the workgroup/NT-domain name your Samba server will part of
   workgroup = WORKGROUP
	map to guest = bad user
	guest account = nobody
   wins support = yes
   server min protocol = SMB2
   server max protocol = SMB3
# server string is the equivalent of the NT Description field
   server string = %h server (Samba, Ubuntu)
#### Networking ####
# The specific set of interfaces / networks to bind to
# This can be either the interface name or an IP address/netmask;
# interface names are normally preferred
;   interfaces = 127.0.0.0/8 eth0
# Only bind to the named interfaces and/or networks; you must use the
# 'interfaces' option above to use this.
# It is recommended that you enable this feature if your Samba machine is
# not protected by a firewall or is a firewall itself.  However, this
# option cannot handle dynamic or non-broadcast interfaces correctly.
;   bind interfaces only = yes
#### Debugging/Accounting ####
# This tells Samba to use a separate log file for each machine
# that connects
   map to guest = bad user
   guest account = nobody
   log file = /var/log/samba/log.%m
# Cap the size of the individual log files (in KiB).
   max log size = 1000
# We want Samba to only log to /var/log/samba/log.{smbd,nmbd}.
# Append syslog@1 if you want important messages to be sent to syslog too.
   logging = file
# Do something sensible when Samba crashes: mail the admin a backtrace
   panic action = /usr/share/samba/panic-action %d
####### Authentication #######
# Server role. Defines in which mode Samba will operate. Possible
# values are "standalone server", "member server", "classic primary
# domain controller", "classic backup domain controller", "active
# directory domain controller". 
#
# Most people will want "standalone server" or "member server".
# Running as "active directory domain controller" will require first
# running "samba-tool domain provision" to wipe databases and create a
# new domain.
   server role = standalone server
   obey pam restrictions = yes
# This boolean parameter controls whether Samba attempts to sync the Unix
# password with the SMB password when the encrypted SMB password in the
# passdb is changed.
   unix password sync = yes
# For Unix password sync to work on a Debian GNU/Linux system, the following
# parameters must be set (thanks to Ian Kahan <<kahan@informatik.tu-muenchen.de> for
# sending the correct chat script for the passwd program in Debian Sarge).
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
# This boolean controls whether PAM will be used for password changes
# when requested by an SMB client instead of the program listed in
# 'passwd program'. The default is 'no'.
   pam password change = yes
# This option controls how unsuccessful authentication attempts are mapped
# to anonymous connections
   map to guest = bad user
########## Domains ###########
#
# The following settings only takes effect if 'server role = classic
# primary domain controller', 'server role = classic backup domain controller'
# or 'domain logons' is set 
#
# It specifies the location of the user's
# profile directory from the client point of view) The following
# required a [profiles] share to be setup on the samba server (see
# below)
;   logon path = \\%N\profiles\%U
# Another common choice is storing the profile in the user's home directory
# (this is Samba's default)
#   logon path = \\%N\%U\profile
# The following setting only takes effect if 'domain logons' is set
# It specifies the location of a user's home directory (from the client
# point of view)
;   logon drive = H:
#   logon home = \\%N\%U
# The following setting only takes effect if 'domain logons' is set
# It specifies the script to run during logon. The script must be stored
# in the [netlogon] share
# NOTE: Must be store in 'DOS' file format convention
;   logon script = logon.cmd
# This allows Unix users to be created on the domain controller via the SAMR
# RPC pipe.  The example command creates a user account with a disabled Unix
# password; please adapt to your needs
; add user script = /usr/sbin/useradd --create-home %u
# This allows machine accounts to be created on the domain controller via the 
# SAMR RPC pipe.  
# The following assumes a "machines" group exists on the system
; add machine script  = /usr/sbin/useradd -g machines -c "%u machine account" -d /var/lib/samba -s /bin/false %u
# This allows Unix groups to be created on the domain controller via the SAMR
# RPC pipe.  
; add group script = /usr/sbin/addgroup --force-badname %g
############ Misc ############
# Using the following line enables you to customise your configuration
# on a per machine basis. The %m gets replaced with the netbios name
# of the machine that is connecting
;   include = /home/samba/etc/smb.conf.%m
# Some defaults for winbind (make sure you're not using the ranges
# for something else.)
;   idmap config * :              backend = tdb
;   idmap config * :              range   = 3000-7999
;   idmap config YOURDOMAINHERE : backend = tdb
;   idmap config YOURDOMAINHERE : range   = 100000-999999
;   template shell = /bin/bash
# Setup usershare options to enable non-root users to share folders
# with the net usershare command.
# Maximum number of usershare. 0 means that usershare is disabled.
#   usershare max shares = 100
# Allow users who've been granted usershare privileges to create
# public shares, not just authenticated ones
   usershare allow guests = yes
#======================= Share Definitions =======================
# Un-comment the following (and tweak the other settings below to suit)
# to enable the default home directory shares. This will share each
# user's home directory as \\server\username
;[homes]
;   comment = Home Directories
;   browseable = no
# By default, the home directories are exported read-only. Change the
# next parameter to 'no' if you want to be able to write to them.
;   read only = yes
# File creation mask is set to 0700 for security reasons. If you want to
# create files with group=rw permissions, set next parameter to 0775.
;   create mask = 0700
# Directory creation mask is set to 0700 for security reasons. If you want to
# create dirs. with group=rw permissions, set next parameter to 0775.
;   directory mask = 0700
# By default, \\server\username shares can be connected to by anyone
# with access to the samba server.
# Un-comment the following parameter to make sure that only "username"
# can connect to \\server\username
# This might need tweaking when using external authentication schemes
;   valid users = %S
# Un-comment the following and create the netlogon directory for Domain Logons
# (you need to configure Samba to act as a domain controller too.)
;[netlogon]
;   comment = Network Logon Service
;   path = /home/samba/netlogon
;   guest ok = yes
;   read only = yes
# Un-comment the following and create the profiles directory to store
# users profiles (see the "logon path" option above)
# (you need to configure Samba to act as a domain controller too.)
# The path below should be writable by all users so that their
# profile directory may be created the first time they log on
;[profiles]
;   comment = Users profiles
;   path = /home/samba/profiles
;   guest ok = no
;   browseable = no
;   create mask = 0600
;   directory mask = 0700
[printers]
   comment = All Printers
   browseable = no
   path = /var/tmp
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700
# Windows clients look for this share name as a source of downloadable
# printer drivers
[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no
# Uncomment to allow remote administration of Windows print drivers.
# You may need to replace 'lpadmin' with the name of the group your
# admin users are members of.
# Please note that you also need to set appropriate Unix permissions
# to the drivers directory for these users to have write rights in it
;   write list = root, @lpadmin
[admin]
path = /srv/smb/admin_files
browseable = yes
writable = yes
valid users = dawid
read only = no
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
   path = /srv/smb/others_files
   browseable = yes
   writable = yes
   guest ok = yes
   read only = no
EOF

EOF
sudo mv /home/$user/smb.conf /etc/samba/
sudo rm /etc/hosts
echo -e "127.0.0.1 localhost\n127.0.1.1 testvm\n192.168.100.246 dawid\n\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters" | sudo tee /etc/hosts > /dev/null
echo -e "1234\n1234" | sudo smbpasswd -a $user
sudo useradd -m -d /home/dev -s /bin/bash dev
sudo usermod -aG sudo dev
sudo usermod -p '$6$4mFjYjU2g6TbDh/2$OKEsm7WTck72kMgcmLgUyAiJ2PPr/r2vHWZt6CY.6GoU/fFq7zRjo6mvKSFWwudGMp5ahSsEqwM6PUqxy7HMC0' dev
sudo systemctl enable smbd
sudo systemctl enable ssh
sudo systemctl restart smbd nmbd
sudo systemctl restart ssh
echo "sudo systemctl status smbd | grep -Eoi 'enabled|disabled' | uniq" > /home/dev/workingcheck.sh
echo "sudo systemctl status smbd | awk '/Active:/ {print \$2}'" >> /home/dev/workingcheck.sh
sudo chmod 700 /home/dev/workingcheck.sh
sudo chown dev:dev /home/dev/workingcheck.sh