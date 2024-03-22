#!/bin/sh

if [ -f "$PATH_TO_MONARC/data/dbinit_done" ]; then
  echo "Database initialization already done. Exiting."
  exit 0
fi

# Create data and caches directories
mkdir -p $PATH_TO_MONARC/data/cache $PATH_TO_MONARC/data/DoctrineORMModule/Proxy $PATH_TO_MONARC/data/LazyServices/Proxy $PATH_TO_MONARC/data/import/files

# fix permissions in data dir
chown -R www-data:www-data $PATH_TO_MONARC/data

MAX_RETRIES=10
RETRY_DELAY=10

echo "Performing database initialization at $DB_HOST..."

retry=0
connected=0

while [ $retry -lt $MAX_RETRIES ]; do
    mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -D $DB_CLI_NAME -e "SELECT 1;" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        connected=1
        echo "Connection to database successful."
        break
    fi

    echo "Could not connect to database $DB_CLI_NAME at $DB_HOST using $DB_USER. Retrying in $RETRY_DELAY seconds..."
    sleep $RETRY_DELAY
    retry=$((retry + 1))
done

if [ $connected -ne 1 ]; then
    echo "Error connecting to database - aborting"
    exit 1
fi

echo "GRANT ALL PRIVILEGES ON * . * TO 'monarc'@'%'" | mysql -h $DB_HOST -u root -p$DB_ROOT_PASSWORD

echo "Create $DB_COMMON_NAME db"
echo "CREATE DATABASE IF NOT EXISTS $DB_COMMON_NAME DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" | mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD

echo "Initialize the common database"
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_COMMON_NAME < $PATH_TO_MONARC/db-bootstrap/monarc_structure.sql
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_COMMON_NAME < $PATH_TO_MONARC/db-bootstrap/monarc_data.sql

echo "Create $DB_CLI_NAME db"
echo "DROP DATABASE $DB_CLI_NAME;" | mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD
echo "CREATE DATABASE $DB_CLI_NAME DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" | mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD

echo "create database backup configuration"
cat > /var/lib/monarc/fo/data/backup/credentialsmysql.cnf <<EOF
[client]
host     = $DB_HOST
user     = $DB_USER
password = $DB_PASSWORD
socket   = /var/run/mysqld/mysqld.sock
[mysql_upgrade]
host     = $DB_HOST
user     = $DB_USER
password = $DB_PASSWORD
socket   = /var/run/mysqld/mysqld.sock
basedir  = /usr
EOF

echo "upgrade db"
cd $PATH_TO_MONARC
./scripts/upgrade-db.sh

echo "seed"
./scripts/seed-db.sh

touch $PATH_TO_MONARC/data/dbinit_done