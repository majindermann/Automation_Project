#!/bin/bash
#Declaring variables

myname="Majnder"
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket="upgrad-majinder"
srv_apache=`dpkg -l apache2|tail -1 | awk '{print $1}'`
srv_apache_status=`systemctl status apache2 | head -2| tail -1 | awk -F '; ' '{print $2}'`
srv_apache_curr_state=`systemctl status apache2 | head -5 | tail -1| awk   '{print $2}'`

#Updating Packages
echo -e "Updating Packages \n"
apt update -y &> /dev/null
echo -e "Update Completed \n"

#Installing Apache2 

if [ "$srv_apache" = "ii" ]
then
	echo -e "Apache already exist .......... PASS\n"
else
	echo -e "Apcahe is not existing\n"	
	echo -e "Apache Installation in progress.........\n"
	apt install apache2 -y &> /dev/null
	echo -e "Apache Installed successfully.\n"

fi

#Validating service is active and running

echo -e "Please wait validating apache service\n"

if [ "$srv_apache_curr_state" = "active" ]
then
	echo -e "Service is already running and active...........PASS\n"
else
	echo -e "Starting Apcahe service.....\n"
	systemctl enable apcahe2
	echo -e "Apache service started successfully ......PASS/n"

fi
#Validating Apcahe services enabled or not.
echo -e "Please wait validating apache service enabled or not\n"


if [ "$srv_apache_status" = "enabled" ]
then
        echo -e "Service is already enabled...........PASS\n"
else
        echo -e "Enabling Apcahe service.....\n"
        systemctl enable apcahe2
        echo -e "Apache service enabled successfully ......PASS/n"

fi


echo -e "Apache Installed and service started \n"

#Creating tar of log file in /var/log/apache2
echo -e "Creating Tar in /tmp"
tar -cf /tmp/${myname}-httpd-logs-${timestamp}.tar --absolute-names /var/log/apache2/*.log
echo -e "Tar created successfully in /tmp......PASS\n"

#Sending file to S3 bucket from /tmp
echo -e "Sending log tar to S3\n"
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
echo -e "Tar log copied to S3.......PASS\n"
echo -e "TASK 2 completed.Thank you !!!\n"

#Validating inventory.html in /var/www/html. If not create file

FILE=inventory.html
if [ -f /var/www/html/inventory.html ] 
then
	echo -e "$FILE exist.\n" 
else
	echo -e "$FILE does not exist.\n"
	echo -e "Creating $FILE please wait\n"
	echo -e "Log Type\tTime Created\tType\tSize" > /var/www/html/inventory.html
	echo -e "$FILE created \n"
fi

#Gathering value to input in inventory file

s=`ls -ltrh /tmp/*.tar| grep -i "$timestamp" | awk '{print $5}'`
lt=`ls -ltrh /tmp/*.tar |grep -i "$timestamp"| awk -F "/" '{print $3}' | awk -F "-" '{print $2 "-" $3}'`
dc=`ls -ltrh /tmp/*.tar |grep -i "$timestamp"| awk -F "/" '{print $3}' | awk -F "-" '{print $4 "-" $5}'| awk -F "." '{print $1}'`
ft=`ls -ltrh /tmp/*.tar |grep -i "$timestamp"| awk -F "/" '{print $3}' | awk -F "-" '{print $4 "-" $5}'| awk -F "." '{print $2}'`
echo -e "$lt\t$dc\t$ft\t$s" >> /var/www/html/inventory.html

#Creating cron entries
CFILE=automation
if [ -f /etc/cron.d/automation ]
then
        echo -e "$CFILE exist in crontab.\n"
else
        echo -e "$CFILE does not exist crontab.\n"
        echo -e "Creating $CFILE please wait\n"
	echo "00 01 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
	echo -e "$CFILE created in crontab and scheduled job.\n"
fi

echo -e "TASK 3 completed. Exiting the script.Thank you !!!"
