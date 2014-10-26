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
        local PASS="admin"
        echo "=> MySQL admin password: $PASS"
        mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
        mysql -uroot -e "CREATE DATABASE zabbix"

        echo "=> Executing Zabbix MySQL script files ..."
        local ZABBIX_MYSQL_V="/usr/share/zabbix-mysql"
        mysql -uroot zabbix < "${ZABBIX_MYSQL_V}/schema.sql"
        mysql -uroot zabbix < "${ZABBIX_MYSQL_V}/images.sql"
        mysql -uroot zabbix < "${ZABBIX_MYSQL_V}/data.sql"
        echo "=> Done"

        mysql -uroot -e "CREATE USER 'zabbix'@'%' IDENTIFIED BY 'zabbix'"
        mysql -uroot -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix'"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%'"
        mysql -uroot -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'"

        mysqladmin -uroot shutdown
    else
        echo "=> Using an existing volume of MySQL"
    fi
}

function config_mail()
{

    if [[ ! -z $GMAIL_USER ]]; then

        sed -i "s/^\(user \).*/\1${GMAIL_USER}/g" /etc/msmtprc
        sed -i "s/^\(from \).*/\1${GMAIL_USER}/g" /etc/msmtprc
        sed -i "s/^\(password \).*/\1${GMAIL_PASS}/g" /etc/msmtprc

    fi

}

check_install_mysql
config_mail

echo "=> Executing Monit..."
exec monit -d 10 -Ic /etc/monitrc
