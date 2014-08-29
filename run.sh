#!/bin/bash

function start_mysql()
{
    service mysqld start

    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 1
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done
}

function check_install_mysql()
{
    local VOLUME_HOME="/var/lib/mysql"

    if [[ ! -d $VOLUME_HOME/mysql ]]; then
        echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
        start_mysql

        mysql_upgrade
        PASS="admin"
        echo "=> MySQL admin password: $PASS"
        mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
        mysql -uroot -e "CREATE DATABASE zabbix"
        zabbix_mysql_v="/usr/share/zabbix-mysql"
        mysql -uroot zabbix < "${zabbix_mysql_v}/schema.sql"
        mysql -uroot zabbix < "${zabbix_mysql_v}/images.sql"
        mysql -uroot zabbix < "${zabbix_mysql_v}/data.sql"
        mysql -uroot -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY 'zabbix'"
        mysql -uroot -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix'"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%'"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'"

        mysqladmin -uroot shutdown
    else
        echo "=> Using an existing volume of MySQL"
    fi
}

check_install_mysql

echo "=> Starting Monit..."
exec monit -d 10 -Ic /etc/monitrc
