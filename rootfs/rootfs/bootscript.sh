#!/bin/sh

# Configure sysctl
/etc/rc.d/sysctl

# Load TCE extensions
/etc/rc.d/tce-loader

# Automount a hard drive
/etc/rc.d/automount

# Mount cgroups hierarchy
/etc/rc.d/cgroupfs-mount
# see https://github.com/tianon/cgroupfs-mount

mkdir -p /var/lib/boot2docker/log

#import settings from profile (or unset them)
export NTP_SERVER=pool.ntp.org
test -f "/var/lib/boot2docker/profile" && . "/var/lib/boot2docker/profile"

# set the hostname
/etc/rc.d/hostname

# sync the clock (in the background, it takes 40s to timeout)
/etc/rc.d/ntpclient > /var/log/ntpclient.log 2>&1 &

# TODO: move this (and the docker user creation&pwd out to its own over-rideable?))
if grep -q '^docker:' /etc/passwd; then
    # if we have the docker user, let's create the docker group
    /bin/addgroup -S docker
    # ... and add our docker user to it!
    /bin/addgroup docker docker

    #preload data from boot2docker-cli
    if [ -e "/var/lib/boot2docker/userdata.tar" ]; then
        tar xf /var/lib/boot2docker/userdata.tar -C /home/docker/ > /var/log/userdata.log 2>&1
        chown -R docker:staff /home/docker
    fi
fi

# Automount Shared Folders (VirtualBox, etc.)
/etc/rc.d/automount-shares

# Configure SSHD
/etc/rc.d/sshd

# Launch ACPId
/etc/rc.d/acpid

echo "-------------------"
date
#maybe the links will be up by now - trouble is, on some setups, they may never happen, so we can't just wait until they are
sleep 5
date
ip a
echo "-------------------"

# Launch Docker
/etc/rc.d/docker

# Allow local bootsync.sh customisation
if [ -e /var/lib/boot2docker/bootsync.sh ]; then
    /var/lib/boot2docker/bootsync.sh
fi

# Allow local HD customisation
if [ -e /var/lib/boot2docker/bootlocal.sh ]; then
    /var/lib/boot2docker/bootlocal.sh > /var/log/bootlocal.log 2>&1 &
fi

# Set IP addresses for Docker containers to use
ifconfig eth0 192.168.200.1 netmask 255.255.255.0
ifconfig eth0 up
ifconfig eth0:1 192.168.200.2 netmask 255.255.255.0
ifconfig eth0:2 192.168.200.3 netmask 255.255.255.0
ifconfig eth0:3 192.168.200.4 netmask 255.255.255.0
ifconfig eth0:4 192.168.200.5 netmask 255.255.255.0

route add default gw 192.168.200.250 eth0


# Launch docker images

docker run --name webserver1 -e CONTAINERNAME=webserver1 -p 192.168.200.1:80:80 benpiper/lbwebtest
docker run --name webserver2 -e CONTAINERNAME=webserver2 -p 192.168.200.2:80:80 benpiper/lbwebtest
docker run --name webserver3 -e CONTAINERNAME=webserver3 -p 192.168.200.3:80:80 benpiper/lbwebtest
docker run --name webserver4 -e CONTAINERNAME=webserver4 -p 192.168.200.4:80:80 benpiper/lbwebtest

# Execute automated_script
# disabled - this script was written assuming bash, which we no longer have.
#/etc/rc.d/automated_script.sh
