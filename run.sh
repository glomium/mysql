#!/bin/sh

# parameters
MYSQL_ROOT_PWD=`cat /run/secrets/mysql_password_root`

MYSQL_USER1="mes"
MYSQL_USER1_PWD=`cat /run/secrets/mysql_password_mes`
MYSQL_USER1_DB="mes"

MYSQL_USER2="erp"
MYSQL_USER2_PWD=`cat /run/secrets/mysql_password_erp`
MYSQL_USER2_DB="erp"

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

    echo "[i] MySql root password: $MYSQL_ROOT_PWD"

    # create temp file
    tfile=`mktemp`
    if [ ! -f "$tfile" ]; then
        return 1
    fi

    # save sql
    echo "[i] Create temp file: $tfile"
    cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PWD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PWD' WITH GRANT OPTION;
EOF

    # Create new database for user1
    if [ "$MYSQL_USER1_DB" != "" ]; then
        echo "[i] Creating database: $MYSQL_USER1_DB"
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_USER1_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

        # set new User and Password
        if [ "$MYSQL_USER1" != "" ] && [ "$MYSQL_USER1_PWD" != "" ]; then
        echo "[i] Creating user: $MYSQL_USER1 with password $MYSQL_USER1_PWD"
        echo "GRANT CREATE, DROP ON *.* to '$MYSQL_USER1'@'%' IDENTIFIED BY '$MYSQL_USER1_PWD';" >> $tfile
        echo "GRANT ALL ON \`$MYSQL_USER1_DB\`.* to '$MYSQL_USER1'@'%' IDENTIFIED BY '$MYSQL_USER1_PWD';" >> $tfile
        fi
    fi

    # Create new database for user2
    if [ "$MYSQL_USER2_DB" != "" ]; then
        echo "[i] Creating database: $MYSQL_USER2_DB"
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_USER2_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

        # set new User and Password
        if [ "$MYSQL_USER2" != "" ] && [ "$MYSQL_USER2_PWD" != "" ]; then
        echo "[i] Creating user: $MYSQL_USER2 with password $MYSQL_USER2_PWD"
        echo "GRANT CREATE, DROP ON *.* to '$MYSQL_USER2'@'%' IDENTIFIED BY '$MYSQL_USER2_PWD';" >> $tfile
        echo "GRANT ALL ON \`$MYSQL_USER2_DB\`.* to '$MYSQL_USER2'@'%' IDENTIFIED BY '$MYSQL_USER2_PWD';" >> $tfile
        fi
    fi

    echo 'FLUSH PRIVILEGES;' >> $tfile

    # run sql in tempfile
    echo "[i] exec tempfile: $tfile"
    /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --datadir='/var/lib/mysql' < $tfile
    echo "[i] remove tempfile: $tfile"
    rm -f $tfile
fi

# echo "[i] Sleeping 5 sec"
# sleep 5

echo '[i] start running mysqld'
exec /usr/bin/mysqld_safe --user=mysql --console --datadir='/var/lib/mysql'
