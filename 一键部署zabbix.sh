#!/bin/bash
yum -y install gcc pcre-devel zlib-devel openssl-devel
tar -xf nginx-1.12.2.tar.gz
cd nginx-1.12.2
./configure --with-htlp_ssl_module
make && make install
yum -y install php php-fpm php-mysql mariadb mariadb-server mariadb-devel
sed -i '65,71s/#//' /usr/local/nginx/conf/nginx,conf
sed -i '69d' /usr/local/nginx/conf/nginx,conf
systemctl restart mariadb
systemctl enable mariadb
systemctl restart php-fpm
systemctl enable php-fpm
yum -y install net-snmp-devel curl-devel libevent-devel
tar -xf zabbix-3.4.4.tar.gz
cd zabbix-3.4.4/
./configure --enable-proxy --enable-agent --enable-server --with-mysql=/use/bin/mysql_config --with-net-snmp --with-libcurl
make && make install
mysql -e "create database zabbix character set uft8"
mysql -e "grant all on zabbix.* to zabbix@'localhost' identified by 'zabbix'"
cd zabbix-3.4.4/database/mysql/
mysql -uzabbix -pzabbix zabbix < schema.sql
mysql -uzabbix -pzabbix zabbix < images.sql
mysql -uzabbix -pzabbix zabbix < data.sql
cd zabbix-3.4.4/frontends/php/
cp -r * /usr/local/nginx/html/
chmod -R 777 /usr/local/nginx/html/*
sed 
sed -i "17afastcgi_buffers 8 16k;\nfastcgi_buffer_size 32k;\nfastcgi_connect_timeout 300;\nfastcgi_send_timeout 300;\nfastcgi_read_timeout 300;" /usr/local/nginx/conf/nginx.conf
/usr/local/nginx/sbin/nginx -s reload
yum -y install php-gd php-xml php-ldap
yum -y install php-bcmath php-mbstring
sed -i '/;date.timezone/s#;date.timezone =#date.timezone = Asia/Shanghai#' /etc/php.ini
sed -i '/execution_time/s/30/300/'  /etc/php.ini
sed -i '/post_max/s/8/32/'  /etc/php.ini
sed -i '/max_input_time = /s/60/300/'  /etc/php.ini
systemctl restart php-fpm
firewall-cmd --set-default-zone=trusted
setenforce 0
