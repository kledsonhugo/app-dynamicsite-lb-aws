#!/bin/bash

echo "Update/Install required OS packages"
yum update -y
dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel telnet tree git

echo "Deploy PHP info app"
cd /tmp
git clone https://github.com/kledsonhugo/app-site-ec2-elb
cp /tmp/app-site-ec2-elb/app/phpinfo.php /var/www/html/index.php
rm -rf /tmp/app-site-ec2-elb

echo "Config Apache WebServer"
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

echo "Start Apache WebServer"
systemctl enable httpd
service httpd restart