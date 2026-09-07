-- =============================================================
-- 02-seed.sql — Datos iniciales de prueba
-- =============================================================

-- ── Products ──────────────────────────────────────────────────
INSERT INTO api.products (name, description, price, stock, category, sku) VALUES
  ('Laptop Pro 15',      'Laptop de alto rendimiento, 16GB RAM, SSD 512GB', 1299.99, 50,  'laptops',     'LAP-001'),
  ('Smartphone X12',     'Pantalla AMOLED 6.5", cámara 108MP',              899.99,  120, 'smartphones',  'PHN-001'),
  ('Auriculares BT',     'Noise cancelling, batería 30hs',                   199.99, 200, 'audio',        'AUD-001'),
  ('Monitor 4K 27"',     'Panel IPS, 144Hz, HDR400',                        499.99,  35, 'monitors',     'MON-001'),
  ('Teclado Mecánico',   'Switches Cherry MX, retroiluminado',               149.99,  80, 'peripherals',  'KEY-001'),
  ('Mouse Ergonómico',   'Inalámbrico, 6 botones, DPI ajustable',             59.99, 150, 'peripherals',  'MOU-001'),
  ('Tablet 10"',         '128GB, WiFi + 4G, Stylus incluido',                399.99,  60, 'tablets',      'TAB-001'),
  ('Cámara Mirrorless',  '24MP, lente 18-55mm, grabación 4K',               1099.99,  20, 'cameras',      'CAM-001'),
  ('SSD Externo 1TB',    'USB-C, 1000MB/s lectura',                           89.99, 300, 'storage',      'SSD-001'),
  ('Router WiFi 6',      'Tri-band, hasta 6600Mbps, cobertura 200m²',        189.99,  45, 'networking',   'NET-001');

-- ── Customers ─────────────────────────────────────────────────
INSERT INTO api.customers (first_name, last_name, email, phone) VALUES
  ('Emily',    'Johnson',   'emily.j@example.com',  '+1-555-0101'),
  ('Michael',  'Williams',  'michael.w@example.com','+1-555-0102'),
  ('Sarah',    'Brown',     'sarah.b@example.com',  '+1-555-0103'),
  ('James',    'Jones',     'james.j@example.com',  '+1-555-0104'),
  ('Axel',     'Ramirez',   'axel.r@example.com',   '+54-11-0105');

-- ── Orders ────────────────────────────────────────────────────
INSERT INTO api.orders (customer_id, status, total, notes) VALUES
  (1, 'delivered',  1399.98, 'Entrega express solicitada'),
  (2, 'shipped',     899.99, NULL),
  (3, 'confirmed',   649.98, 'Regalo — no incluir factura'),
  (4, 'pending',     189.99, NULL),
  (5, 'pending',    1299.99, 'Primera compra');

-- ── Order Items ───────────────────────────────────────────────
INSERT INTO api.order_items (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 1299.99),  -- Orden 1: Laptop Pro
  (1, 6, 2,   59.99),  -- Orden 1: 2x Mouse
  (2, 2, 1,  899.99),  -- Orden 2: Smartphone
  (3, 5, 1,  149.99),  -- Orden 3: Teclado
  (3, 6, 1,   59.99),  -- Orden 3: Mouse
  (3, 3, 1,  199.99),  -- Orden 3: Auriculares
  (4, 10, 1, 189.99),  -- Orden 4: Router
  (5, 1, 1, 1299.99);  -- Orden 5: Laptop Pro
