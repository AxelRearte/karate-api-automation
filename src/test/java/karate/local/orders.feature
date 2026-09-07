@local @regression
Feature: Orders — Flujo E2E completo con API + DB
# El escenario más común en fintech/banking:
# crear una orden → validar API → validar base de datos → verificar items

  Background:
    * url localApiUrl
    * def DbUtils = Java.type('util.DbUtils')
    * def db      = new DbUtils(dbConfig)


  # ── Scenario 1: Crear orden completa y validar toda la cadena ─
  @smoke @local
  Scenario: Crear orden y verificar API + DB + items
    # PASO 1: Crear la orden
    * def nuevaOrden =
      """
      {
        "customer_id": 5,
        "status":      "pending",
        "total":       1299.99,
        "notes":       "Test E2E Karate"
      }
      """

    Given path '/orders'
    And header Prefer = 'return=representation'
    And request nuevaOrden
    When method POST
    Then status 201

    * def ordenCreada = response[0]
    * def ordenId     = ordenCreada.id
    * print '✅ Orden creada con ID:', ordenId

    # PASO 2: Verificar que la API la devuelve correctamente
    Given path '/orders'
    And param id = 'eq.' + ordenId
    When method GET
    Then status 200

    * def ordenApi = response[0]
    And match ordenApi.customer_id == 5
    And match ordenApi.status      == 'pending'
    And match ordenApi.notes       == 'Test E2E Karate'

    # PASO 3: Verificar en la DB (fuente de verdad)
    * def ordenDb = db.queryOne('SELECT * FROM api.orders WHERE id = ' + ordenId)
    * assert ordenDb != null
    * assert ordenDb.customer_id == 5
    * assert ordenDb.status      == 'pending'
    * print '✅ Orden confirmada en DB:', ordenDb

    # PASO 4: Agregar un item a la orden
    Given path '/order_items'
    And header Prefer = 'return=representation'
    And request { "order_id": '#(ordenId)', "product_id": 1, "quantity": 1, "unit_price": 1299.99 }
    When method POST
    Then status 201

    # PASO 5: Verificar el item en la DB
    * def itemDb = db.queryOne('SELECT * FROM api.order_items WHERE order_id = ' + ordenId)
    * assert itemDb != null
    * assert itemDb.product_id == 1
    * assert itemDb.quantity   == 1
    * print '✅ Item de orden confirmado en DB'

    # CLEANUP: eliminar en orden correcta (FK: items antes que order)
    * db.execute('DELETE FROM api.order_items WHERE order_id = ' + ordenId)
    * db.execute('DELETE FROM api.orders WHERE id = ' + ordenId)
    * print '🧹 Cleanup: orden', ordenId, 'y sus items eliminados'


  # ── Scenario 2: Transición de estados de una orden ────────────
  @regression @local
  Scenario: Validar transiciones de estado de una orden
    # Consultar una orden existente
    * def ordenExistente = db.queryOne('SELECT id, status FROM api.orders WHERE id = 2')
    * print '📋 Estado actual:', ordenExistente.status

    # Confirmar la orden: pending → confirmed
    Given path '/orders'
    And param id = 'eq.2'
    And header Prefer = 'return=representation'
    And request { "status": "confirmed" }
    When method PATCH
    Then status 200

    # Verificar el cambio en DB
    * def estadoEnDb = db.queryOne('SELECT status FROM api.orders WHERE id = 2')
    * assert estadoEnDb.status == 'confirmed'
    * print '✅ Estado en DB:', estadoEnDb.status

    # Restaurar estado original
    * db.executeWithParams('UPDATE api.orders SET status = ? WHERE id = 2', ordenExistente.status)
    * print '🔄 Estado restaurado a:', ordenExistente.status


  # ── Scenario 3: Validar integridad referencial ────────────────
  @regression @local
  Scenario: Intentar crear orden con customer inexistente devuelve error
    Given path '/orders'
    And request { "customer_id": 99999, "status": "pending", "total": 0 }
    When method POST
    # PostgREST devuelve 409 cuando viola una FK constraint
    Then status 409
    * print '✅ FK constraint validada: no se puede crear orden con customer_id inexistente'
