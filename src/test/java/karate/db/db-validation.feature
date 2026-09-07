@db @regression @lock=products
Feature: DB Validation — Tests puros de base de datos via JDBC
# Sin HTTP — acceso directo a PostgreSQL con JDBC
# Útil para: validar migraciones, integridad de datos, stored procedures

  Background:
    * def DbUtils = Java.type('util.DbUtils')
    * def db      = new DbUtils(dbConfig)


  # ── Scenario 1: Validar seed data ────────────────────────────
  @smoke @db
  Scenario: Verificar que el seed data está completo
    * def productCount  = db.count('SELECT COUNT(*) FROM api.products')
    * def customerCount = db.count('SELECT COUNT(*) FROM api.customers')
    * def orderCount    = db.count('SELECT COUNT(*) FROM api.orders')

    * assert productCount  >= 10
    * assert customerCount >= 5
    * assert orderCount    >= 5
    * print '✅ Seed data OK — products:', productCount, '| customers:', customerCount, '| orders:', orderCount


  # ── Scenario 2: Validar integridad de datos ───────────────────
  @db
  Scenario: Todos los productos tienen precio mayor a 0
    * def sinPrecio = db.count('SELECT COUNT(*) FROM api.products WHERE price <= 0')
    * assert sinPrecio == 0
    * print '✅ Todos los productos tienen precio válido'


  @db
  Scenario: Todos los orders_items referencian órdenes y productos existentes
    * def huerfanos = db.count('SELECT COUNT(*) FROM api.order_items oi LEFT JOIN api.orders o ON oi.order_id = o.id WHERE o.id IS NULL')
    * assert huerfanos == 0
    * print '✅ No hay order_items huérfanos'


  # ── Scenario 3: Queries complejas ─────────────────────────────
  @db
  Scenario: Obtener clientes con órdenes pendientes
    * def pendientes = db.query("SELECT c.first_name, c.last_name, c.email, COUNT(o.id) as order_count FROM api.customers c JOIN api.orders o ON o.customer_id = c.id WHERE o.status = 'pending' GROUP BY c.id, c.first_name, c.last_name, c.email")

    * print '📋 Clientes con órdenes pendientes:', pendientes.length
    * assert pendientes.length >= 1

    # Cada fila debe tener los campos esperados
    * match each pendientes contains
      """
      {
        "first_name":  "#string",
        "last_name":   "#string",
        "email":       "#string",
        "order_count": "#number"
      }
      """


  # ── Scenario 4: Validar SKU únicos ────────────────────────────
  @smoke @db
  Scenario: Los SKUs de productos deben ser únicos
    * def duplicados = db.count('SELECT COUNT(*) FROM (SELECT sku FROM api.products GROUP BY sku HAVING COUNT(*) > 1) t')
    * assert duplicados == 0
    * print '✅ Todos los SKUs son únicos'
