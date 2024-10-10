#!/bin/bash
# wait-for-postgres.sh

set -e

until pg_isready -h 127.0.0.1 -p 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done
