#!/bin/bash
# Exécuté en root par pkexec
su -s /bin/bash postgres -c "psql <<'SQL'
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'edupay') THEN
    CREATE USER edupay WITH PASSWORD 'edupay';
  ELSE
    ALTER USER edupay WITH PASSWORD 'edupay';
  END IF;
END
\$\$;
SELECT 'CREATE DATABASE edupay OWNER edupay' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'edupay')\gexec
GRANT ALL PRIVILEGES ON DATABASE edupay TO edupay;
SQL"

su -s /bin/bash postgres -c "psql -d edupay <<'SQL'
GRANT ALL ON SCHEMA public TO edupay;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO edupay;
SQL"

echo "BASE DE DONNÉES RÉPARÉE"
