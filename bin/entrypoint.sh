#!/bin/bash
set -e

# echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf
# echo "host all  all    127.0.0.1/32  trust" >> /etc/postgresql/12/main/pg_hba.conf
service postgresql start
service redis-server start
/usr/local/bin/wait-for-postgres.sh
# Configure PostgreSQL: Set password and create database if it doesn't exist
su - postgres -c 'psql -c "ALTER USER postgres PASSWORD '\''postgres'\'';"'
su - postgres -c "psql -c \"SELECT 'CREATE DATABASE vinsight' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'vinsight')\\gexec\""
# Start Gunicorn server for Superset
exec gunicorn superset.app:create_app()