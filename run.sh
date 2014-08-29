#!/bin/bash

if [ ! -f /mysql-configured ]; then
    service mysqld start

    mysql_upgrade

    sleep 10s

    PASS="mypassword"
    echo "mysql admin password: $PASS"

    mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
    mysql -uroot -e "CREATE DATABASE zabbix CHARACTER SET utf8;"
    zabbix_mysql_v="/usr/share/zabbix-mysql"
    mysql -uroot zabbix < "${zabbix_mysql_v}/schema.sql"
    mysql -uroot zabbix < "${zabbix_mysql_v}/images.sql"
    mysql -uroot zabbix < "${zabbix_mysql_v}/data.sql"
    mysql -uroot -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY 'zabbix'"
    mysql -uroot -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix'"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%'"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'"

    mysqladmin -uroot shutdown
    #service mysqld stop

    touch /mysql-configured
fi

monit -d 10 -Ic /etc/monitrc
