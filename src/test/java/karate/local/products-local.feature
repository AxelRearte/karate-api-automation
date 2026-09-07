@local @regression @lock=products
Feature: Products API Local — CRUD + Validación en Base de Datos
# API: PostgREST corriendo en Docker (localhost:3000)
# DB:  PostgreSQL en Docker (localhost:5432)
# Patrón enterprise: cada operación de API se verifica también en la DB

  Background:
    * url localApiUrl
    # Instanciar DbUtils para consultas JDBC directas
    * def DbUtils = Java.type('util.DbUtils')
    * def db      = new DbUtils(dbConfig)


  # ── Scenario 1: Leer productos y validar contra DB ───────────
  @smoke @local
  Scenario: Listar productos y validar que coinciden con la DB
    Given path '/products'
    When method GET
    Then status 200

    # La API devuelve un array directamente (PostgREST)
    And match response == '#[] #object'
    And match each response contains
      """
      {
        "id":       "#number",
        "name":     "#string",
        "price":    "#number",
        "stock":    "#number",
        "category": "#string",
        "sku":      "#string"
      }
      """

    # BEST PRACTICE: validar que el COUNT de la API coincide con la DB
    * def apiCount = response.length
    * def dbCount  = db.count('SELECT COUNT(*) FROM api.products WHERE active = true')
    * assert apiCount == dbCount
    * print '✅ API devuelve', apiCount, 'productos | DB tiene', dbCount


  # ── Scenario 2: Obtener un producto por ID ────────────────────
  @smoke @local
  Scenario: Obtener producto por ID y comparar con dato en DB
    # En PostgREST se filtra con query params: ?id=eq.1
    Given path '/products'
    And param id = 'eq.1'
    When method GET
    Then status 200

    * def productoApi = response[0]

    # Validar contra DB directamente — fuente de verdad
    * def productoDb = db.queryOne('SELECT * FROM api.products WHERE id = 1')

    # Los datos de la API y la DB deben coincidir exactamente
    And match productoApi.name     == productoDb.name
    And match productoApi.price    == productoDb.price
    And match productoApi.category == productoDb.category
    And match productoApi.sku      == productoDb.sku
    * print '✅ API y DB coinciden para producto ID=1:', productoApi.name


  # ── Scenario 3: Crear producto y verificar en DB (E2E) ────────
  @regression @local
  Scenario: Crear producto via API y verificar que se persistió en la DB
    * def nuevoProducto =
      """
      {
        "name":        "Test Product QA",
        "description": "Creado por Karate para validar persistencia",
        "price":       99.99,
        "stock":       10,
        "category":    "testing",
        "sku":         "TEST-QA-001"
      }
      """

    # PASO 1: Crear via API
    Given path '/products'
    And header Prefer = 'return=representation'
    And request nuevoProducto
    When method POST
    Then status 201

    * def productoCreado = response[0]
    * def nuevoId = productoCreado.id
    * print '✅ Producto creado via API con ID:', nuevoId

    # PASO 2: Verificar en la DB que realmente se guardó
    * def dbRow = db.queryOne('SELECT * FROM api.products WHERE id = ' + nuevoId)
    * assert dbRow != null
    And match dbRow.name     == nuevoProducto.name
    And match dbRow.category == nuevoProducto.category
    And match dbRow.sku      == nuevoProducto.sku
    * print '✅ Confirmado en DB: el producto existe con id=', nuevoId

    # CLEANUP: eliminar el registro de prueba para no ensuciar la DB
    * def deleted = db.execute('DELETE FROM api.products WHERE id = ' + nuevoId)
    * assert deleted == 1
    * print '🧹 Cleanup: producto de prueba eliminado de la DB'


  # ── Scenario 4: Actualizar precio y verificar en DB ───────────
  @regression @local
  Scenario: Actualizar precio via API y verificar cambio en DB
    # Primero leemos el precio original de la DB
    * def original = db.queryOne('SELECT price FROM api.products WHERE id = 2')
    * def precioOriginal = original.price
    * print '📋 Precio original en DB:', precioOriginal

    # Actualizar via API (PATCH en PostgREST actualiza parcialmente)
    Given path '/products'
    And param id = 'eq.2'
    And header Prefer = 'return=representation'
    And request { "price": 999.99 }
    When method PATCH
    Then status 200

    # Verificar que la DB refleja el cambio
    * def actualizado = db.queryOne('SELECT price FROM api.products WHERE id = 2')
    And match actualizado.price == 999.99
    * print '✅ Precio actualizado en DB a:', actualizado.price

    # Restaurar precio original (BEST PRACTICE: dejar la DB como estaba)
    * def restored = db.executeWithParams('UPDATE api.products SET price = ? WHERE id = 2', precioOriginal)
    * print '🔄 Precio restaurado a:', precioOriginal


  # ── Scenario 5: Actualizar stock via API y verificar en DB ────
  @smoke @local
  Scenario: Actualizar stock de un producto via API y auditar en DB
    # 1. Leer stock actual directo de la base de datos
    * def productoAntes = db.queryOne('SELECT stock FROM api.products WHERE id = 1')
    * def stockInicial  = productoAntes.stock
    * print '📦 Stock inicial en DB:', stockInicial

    # 2. Calcular nuevo stock (+1)
    * def nuevoStock = stockInicial + 1

    # 3. Enviar actualización por la API HTTP
    Given path '/products'
    And param id = 'eq.1'
    And header Prefer = 'return=representation'
    And request { "stock": '#(nuevoStock)' }
    When method PATCH
    Then status 200

    # 4. Auditar en la base de datos de PostgreSQL
    * def productoDespues = db.queryOne('SELECT stock FROM api.products WHERE id = 1')
    And match productoDespues.stock == nuevoStock
    * print '✅ Stock auditado en DB con éxito: pasó de', stockInicial, 'a', productoDespues.stock

    # 5. Cleanup: restaurar el stock original en la DB
    * db.executeWithParams('UPDATE api.products SET stock = ? WHERE id = 1', stockInicial)
    * print '🔄 Stock restaurado a:', stockInicial
