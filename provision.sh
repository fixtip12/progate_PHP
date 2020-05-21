#!/bin/sh

# epalとremiをそれぞれをインストール
yum -y install epel-release
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# apacheインストール
yum -y --enablerepo=remi install httpd

# php7.3インストール
yum -y install --enablerepo=remi,remi-php73 php php-devel php-mbstring php-pdo php-gd php-xml php-mcrypt

# phpのタイムゾーンをUTCにする
sed -i -e "/;date\.timezone /a date\.timezone = 'UTC'" /etc/php.ini

# phpのerror_logを出力させる
sed -i -e "s/;display_errors\ =\ Off/display_errors = On/g" /etc/php.ini
sed -i -e "s/;error_log\ =\ php_errors.log/error_log\ =\ '\/var\/log\/php\/error.log'/g" /etc/php.ini
mkdir /var/log/php/
touch /var/log/php/error.log
chown apache:apache /var/log/php/error.log

# mysql8インストール
yum -y remove mariadb-libs
yum -y remove mysql*
rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
yum -y install mysql-community-server

# mysqlの文字セットをUTF8にする
sed -i -e "/\[mysqld\]/a character-set-server=utf8" /etc/my.cnf
sed -i -e "/\[mysqld_safe\]/i \[mysql\]\ndefault-character-set = utf8" /etc/my.cnf

# 利用するサービスを開始する
systemctl enable httpd.service
systemctl enable mysqld.service
systemctl restart httpd
systemctl restart mysqld.service

# セットアップ終了
echo "COMPLETE!"