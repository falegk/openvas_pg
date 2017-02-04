#!/bin/bash

echo "Starting Openvas..."

service postgresql start
echo "[PostgreSQL] Wait until postgresql is ready..."
sleep 1
until grep "database system is ready to accept connections" /var/log/postgresql/postgresql-9.5-main.log
do
	echo "[PostgreSQL] Waiting for PostgreSQL to start..."
	sleep 2
done

redis-server /etc/redis/redis.conf
sleep 1
while  [ "${X}" != "PONG" ]; do
        echo "[REDIS] Redis not yet ready"
        sleep 1
        X="$(redis-cli ping)"
done
echo "[REDIS] Redis ready."

cd /usr/local/sbin

echo "Starting Openvassd"
openvassd
sleep 8

echo "Starting gsad for debug..."
# http://wiki.openvas.org/index.php/Edit_the_SSL_ciphers_used_by_GSAD
gsad --listen=0.0.0.0 --port=4000 # --gnutls-priorities="SECURE128:-AES-128-CBC:-CAMELLIA-128-CBC:-VERS-SSL3.0:-VERS-TLS1.0"

echo "Rebuilding openvasmd"
#n=0
#until [ $n -eq 2 ]
#do
#	        timeout 10m openvasmd --rebuild --progress --verbose;
#		if [ $? -eq 0 ]; then
#			break;
#		fi
#		sleep 5
#		echo "Rebuild failed, attempt: $n"
#	        n=$[$n+1]
#done

echo "Starting Openvasmd..."
openvasmd # --listen=0.0.0.0
sleep 5

echo "Checking setup"
/openvas/openvas-check-setup --v9 --server
echo "Done."

echo "Finished startup"

tail -f /usr/local/var/log/openvas/*
