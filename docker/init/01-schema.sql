-- =============================================================
-- 01-schema.sql — Estructura de la base de datos
-- Se ejecuta automáticamente al crear el contenedor de PostgreSQL
-- =============================================================

-- Esquema 'api': PostgREST expone solo lo que está en este schema
CREATE SCHEMA IF NOT EXISTS api;

-- Rol anónimo para PostgREST (sin autenticación para simplificar)
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'karate_anon') THEN
    CREATE ROLE karate_anon NOLOGIN;
  END IF;
END
$$;

GRANT USAGE ON SCHEMA api TO karate_anon;

-- ── Tabla: products ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS api.products (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(200)   NOT NULL,
  description TEXT,
  price       DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
  stock       INTEGER        NOT NULL DEFAULT 0 CHECK (stock >= 0),
  category    VARCHAR(100)   NOT NULL,
  sku         VARCHAR(50)    UNIQUE NOT NULL,
  active      BOOLEAN        NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ── Tabla: customers ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS api.customers (
  id         SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name  VARCHAR(100) NOT NULL,
  email      VARCHAR(200) UNIQUE NOT NULL,
  phone      VARCHAR(30),
  active     BOOLEAN      NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ── Tabla: orders ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS api.orders (
  id          SERIAL PRIMARY KEY,
  customer_id INTEGER        NOT NULL REFERENCES api.customers(id),
  status      VARCHAR(30)    NOT NULL DEFAULT 'pending'
                             CHECK (status IN ('pending','confirmed','shipped','delivered','cancelled')),
  total       DECIMAL(10, 2) NOT NULL DEFAULT 0,
  notes       TEXT,
  created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- ── Tabla: order_items ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS api.order_items (
  id         SERIAL PRIMARY KEY,
  order_id   INTEGER        NOT NULL REFERENCES api.orders(id) ON DELETE CASCADE,
  product_id INTEGER        NOT NULL REFERENCES api.products(id),
  quantity   INTEGER        NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0)
);

-- Permisos para el rol anónimo de PostgREST
GRANT SELECT, INSERT, UPDATE, DELETE
  ON api.products, api.customers, api.orders, api.order_items
  TO karate_anon;

GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA api
  TO karate_anon;
