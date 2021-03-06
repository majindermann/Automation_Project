#!/bin/bash
#Declaring variables

myname="Majnder"
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket="upgrad-majinder"

#Updating Packages
echo -e "Updating Packages \n"
apt update -y >> /dev/null
echo -e "Update Completed \n"

#Installing Apache2 and enabling service
echo -e "Installing Apache \n"
apt install apache2 -y >> /dev/null
systemctl enable apcahe2
systemctl start apache2
systemctl status apache2 | grep -i running | awk {'print $2 $3'}
echo -e "Apache Installed and service started \n"

#Creating tar of log file in /var/log/apache2
tar -cf /tmp/${myname}-httpd-logs-${timestamp}.tar --absolute-names /var/log/apache2/*.log

#Sending file to S3 bucket and removing fro /tmp
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
rm -rf /tmp/${myname}-httpd-logs-${timestamp}.tar
