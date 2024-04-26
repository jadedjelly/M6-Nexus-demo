#!/bin/bash
echo "Open port 8081 on Firewall for DO linux server"
echo "Open 22 on local from IP addr of DO droplet / server (hint ufw)"
chmod +x ./create-user.sh
# execute from Digital Oceans Linux server

# run package update, install jdk-8 & net tools
apt update -y && apt install openjdk-8-jre-headless -y && apt install net-tools -y

# download & extract nexus installer to /opt/
wget -P /opt/ https://download.sonatype.com/nexus/3/nexus-3.65.0-02-unix.tar.gz && tar -zxvf /opt/nexus-3.65.0-02-unix.tar.gz -C /opt/

# create Nexus user
./create-user.sh

# change ownership of nexus files to user "nexus"
chown -R nexus:nexus /opt/nexus-3.65.0-02 && chown -R nexus:nexus /opt/sonatype-work

# set Nexus to run as the user "nexus"
echo "run_as_user=\"nexus"\" > /opt/nexus-3.65.0-02/bin/nexus.rc
# remove comment, add nexus
# should look like: run_as_user="nexus"

# run nexus as nexus user
runuser -u nexus -- /opt/nexus-3.65.0-02/bin/nexus start

echo "waiting 2 mins for temp Admin password to generate"
sleep 2m

# echo temp nexus admin pw
adminpw=/opt/sonatype-work/nexus3/admin.password

[ -f $adminpw ] && echo $(cat $adminpw) || echo "file doesn't exist"

extip=$(curl https://ipinfo.io/ip)

echo "Open a browser to the following ip address:" $extip