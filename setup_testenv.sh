#!/usr/bin/env bash

# Mostly just automating this process:
# https://support.cpanel.net/hc/en-us/articles/360052582833-How-to-change-the-primary-IP-of-a-cPanel-server

# Send stdout and stderr to log file
exec > >(tee /root/setup.log) 2>&1

# Set hostname - not strictly necessary since this is set in the image, but just in case
whmapi1 sethostname hostname=test.cp.quinlan.local

# Set IP for new shared hosting accounts (i.e. in "Basic WebHost Manager Setup"
myip=$(ip -o addr show dev eth0 | awk '$3=="inet"{split($4, a, "/"); print a[1]}')
sed -i "1s/.*/ADDR $myip/" /etc/wwwacct.conf

# Set the primary cPanel IP address
/scripts/mainipcheck

# Update the /etc/hosts file
/scripts/fixetchosts

# Update IP for all accounts and DNS zones
for user in $(ls /home | grep "support"); do
    whmapi1 setsiteip ip="$myip" user="$user"
    version=$(echo "$user" | cut -d 'w' -f 1)
    domain=$(echo "${version}.test.cp.quinlan.local")
    whmapi1 resetzone domain=$domain
done

# Make sure that the IP is correct for the primary domain's DNS zone
whmapi1 resetzone domain=test.cp.quinlan.local

# And create NS records in the primary domain's zone (because for some reason that's not a default)
whmapi1 addzonerecord domain=test.cp.quinlan.local name=ns1 class=IN ttl=86400 type=A address="$myip"
whmapi1 addzonerecord domain=test.cp.quinlan.local name=ns2 class=IN ttl=86400 type=A address="$myip"
