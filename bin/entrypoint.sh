#!/bin/bash
set -e

echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf
echo "host all  all    127.0.0.1/32  trust" >> /etc/postgresql/12/main/pg_hba.conf
service postgresql start
service redis-server start
/usr/local/bin/wait-for-postgres.sh
su - postgres -c "psql -c \"ALTER USER postgres PASSWORD 'postgres';\""
su - postgres -c "psql -c \"CREATE DATABASE vinsight;\""
gunicorn superset.app:create_app()