#!/bin/bash
set -e

echo "listen_addresses='*'" >> /etc/postgresql/15/main/postgresql.conf
echo "host all  all    127.0.0.1/32  trust" >> /etc/postgresql/15/main/pg_hba.conf
service postgresql start
service redis-server start
/usr/local/bin/wait-for-postgres.sh
# Configure PostgreSQL: Set password and create database if it doesn't exist
su - postgres -c 'psql -c "ALTER USER postgres PASSWORD '\''postgres'\'';"'
service postgresql restart
# su - postgres -c "psql -c \"SELECT 'CREATE DATABASE vinsight' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'vinsight')\\gexec\""
# Start Gunicorn server for Superset
echo "Starting up Vinsight gunicorn server"

gunicorn \
    --bind  "0.0.0.0:8088" \
    --access-logfile '-' \
    --error-logfile '-' \
    --workers 1 \
    --worker-class gthread \
    --threads 20 \
    --timeout 60 \
    --limit-request-line 0 \
    --limit-request-field_size 0 \
    "superset.app:create_app()"