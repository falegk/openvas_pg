#!/bin/bash

echo "Starting setup..."
ldconfig

sed -i 's|^#checkpoint_timeout = 5min|checkpoint_timeout = 1h|;s|^#checkpoint_warning = 30s|checkpoint_warning = 0|' /etc/postgresql/9.5/main/postgresql.conf

{ echo; echo "host all all 127.0.0.1/32 trust"; } >> "/etc/postgresql/9.5/main/pg_hba.conf"

service postgresql start

su - postgres -c "createuser -DRS root"
su - postgres -c "createdb -O root tasks"
su - postgres -c "psql tasks -c 'create role dba with superuser noinherit; grant dba to root; create extension \"uuid-ossp\";'"
sleep 5

redis-server /etc/redis/redis.conf
while  [ "${X}" != "PONG" ]; do
        echo "[REDIS] Redis not yet ready"
        sleep 1
        X="$(redis-cli ping)"
done
echo "[REDIS] Redis ready."

# Add openvas certificates
echo "Add openvas certificates..." && openvas-manage-certs -a -f -q

cd /usr/local/sbin

echo "Sync NVTs, CVEs, CPEs..."
echo "NVT Sync..." && greenbone-nvt-sync
sleep 5
echo "Start scanner..." && openvassd
# TODO-BUG: SCAP Sync hangs up when finishing. So run these commands when the build finished
# docker exec -it openvas_pg_container bin/bash
# greenbone-scapdata-sync
# openvasmd --rebuild --progress --verbose
sleep 5
echo "CERT Sync..." && greenbone-certdata-sync
sleep 5

echo "Rebuilding Openvasmd..."
sleep 5
openvasmd --rebuild --progress --verbose

echo "Creating Admin user..."
sleep 5
openvasmd --create-user=sadmin --role="Super Admin"
openvasmd --user=sadmin --new-password=changeme

echo "Kill openvassd"
ps aux | grep openvassd | awk '{print $2}' | xargs kill -9

echo "Finished setup..."
