#!/bin/bash

set -eo pipefail

if [ -d /var/lib/mysql/mysql ]; then
    echo '[i] MySQL directory already present, skipping creation'

else
    echo "[i] MySQL data directory not found, creating initial DBs"

    if [ ! -f "/run/secrets/mysql_init.sql" ]; then
        echo "[e] mysql_init.sql not found!"
        exit 1
    fi

    chown -R mysql:mysql /var/lib/mysql

    # init database
    echo '[i] Initializing database'
    mysql_install_db --auth-root-authentication-method=socket --datadir=/var/lib/mysql --skip-test-db

    # start temporary server
    echo '[i] wait for temporary server to start'
    mysqld_safe --datadir='/var/lib/mysql' --skip-networking --socket="/tmp/mysql" &

	for i in {30..0}; do
		if mysql --socket /tmp/mysql --database mysql -e 'SELECT 1' &> /dev/null; then
			break
		fi
		sleep 1
	done

	if [ "$i" = 0 ]; then
		echo "[e] Unable to start server."
        exit 1;
	fi

    echo "[i] load data from mysql_init.sql"
    mysql --socket /tmp/mysql < /run/secrets/mysql_init.sql

    echo '[i] shutdown temporary server'
    if ! mysqladmin shutdown --socket="/tmp/mysql"; then
		echo "[e] Unable to shut down server."
        exit 1;
	fi

    echo '[i] Database initialized'
fi

echo '[i] start running mysqld'
exec /usr/bin/mysqld_safe --user=mysql --console --datadir='/var/lib/mysql' --skip-syslog --skip-log-error
