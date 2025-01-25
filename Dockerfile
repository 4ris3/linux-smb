# Ubuntu base image
FROM ubuntu:20.04

# Install packages and cleanup
RUN apt update && apt install -y samba openssh-server iptables && apt clean && rm -rf /var/lib/apt/lists/*

# Add configuration files
COPY smb.conf /etc/samba/smb.conf
COPY setup.sh /usr/local/bin/setup.sh

# Set permissions for setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Expose necessary ports
EXPOSE 445 22

# Start setup script
CMD ["/usr/local/bin/setup.sh"]