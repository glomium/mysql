#!/bin/sh

set -e

# parameters
PASSWORD=`cat /run/secrets/mysql_password_root`

if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

if [ -d /var/lib/mysql/mysql ]; then
    echo '[i] MySQL directory already present, skipping creation'
else
    echo "[i] MySQL data directory not found, creating initial DBs"

    chown -R mysql:mysql /var/lib/mysql

    # init database
    echo '[i] Initializing database'
    /usr/bin/mysql_install_db --user=mysql --datadir=/var/lib/mysql
    echo '[i] Database initialized'

    # create temp file
    tfile=`mktemp`
    if [ ! -f "$tfile" ]; then
        return 1
    fi

    # run sql in tempfile
   /usr/bin/envsubst < entrypoint.sql | /usr/sbin/mysqld --user=mysql --bootstrap --verbose=0 --datadir='/var/lib/mysql'
    if [ -f "/run/secrets/mysql_init.sql" ]; then
        echo "[i] load data from mysql_init.sql"
        /usr/sbin/mysqld --user=mysql --bootstrap --verbose=0 --datadir='/var/lib/mysql' < /run/secrets/mysql_init.sql
    fi
fi

echo '[i] start running mysqld'
exec /usr/bin/mysqld_safe --user=mysql --console --datadir='/var/lib/mysql' --skip-syslog --log-error=/dev/stderr
