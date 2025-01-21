#!/bin/bash
set -e

if [[ -z "$BILLING_USER" || -z "$BILLING_PASSWORD" || -z "$BILLING_DB" ]]; then
  echo "Missing variables BILLING_USER, BILLING_PASSWORD, and BILLING_DB."
else
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER "$BILLING_USER" WITH PASSWORD '$BILLING_PASSWORD';
    CREATE DATABASE "$BILLING_DB" OWNER "$BILLING_USER";
    GRANT ALL PRIVILEGES ON DATABASE "$BILLING_DB" TO "$BILLING_USER";
EOSQL
  if [ -f /docker-entrypoint-initdb.d/billing.sql.noauto ]; then
    psql -v ON_ERROR_STOP=1 --username "$BILLING_USER" --dbname "$BILLING_DB" -f /docker-entrypoint-initdb.d/billing.sql.noauto
  else
    echo "Missing /docker-entrypoint-initdb.d/billing.sql.noauto"
  fi
fi
