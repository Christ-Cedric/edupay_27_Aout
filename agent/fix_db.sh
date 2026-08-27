#!/bin/bash
# =============================================================================
# SCRIPT DE RÉPARATION BASE DE DONNÉES — EduPay
# Exécuter avec : bash fix_db.sh
# =============================================================================
set -e

echo "🔧 Réparation de la base de données EduPay..."

sudo -u postgres psql <<'SQL'
-- Créer l'utilisateur edupay s'il n'existe pas
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'edupay') THEN
    CREATE USER edupay WITH PASSWORD 'edupay';
    RAISE NOTICE 'Utilisateur edupay créé.';
  ELSE
    ALTER USER edupay WITH PASSWORD 'edupay';
    RAISE NOTICE 'Mot de passe de edupay réinitialisé.';
  END IF;
END
$$;

-- Créer la base de données si elle n'existe pas
SELECT 'CREATE DATABASE edupay OWNER edupay'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'edupay')\gexec

-- Donner tous les droits
GRANT ALL PRIVILEGES ON DATABASE edupay TO edupay;
SQL

# Donner les droits sur le schéma public
sudo -u postgres psql -d edupay <<'SQL'
GRANT ALL ON SCHEMA public TO edupay;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO edupay;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO edupay;
SQL

echo "✅ Base de données réparée !"

echo ""
echo "📦 Application des migrations Prisma..."
cd /home/ouedraogo/Bureau/project_edupay/backend
npx prisma migrate deploy

echo ""
echo "🌱 Création du compte agent (seed)..."
npx prisma db seed

echo ""
echo "✅ Tout est prêt ! Relancez le backend avec : npm run dev"
echo ""
echo "=== IDENTIFIANTS DE CONNEXION ==="
echo "Numéro  : +22676691911"
echo "Code    : Admin@2026"
