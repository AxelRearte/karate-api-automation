@local @smoke @lock=customers
Feature: Gestión de Clientes (Customers API)

  Background:
    * url localApiUrl
    * def DbUtils = Java.type('util.DbUtils')
    * def db      = new DbUtils(dbConfig)

  Scenario: Obtener todos los clientes y validar su estructura
    Given path '/customers'
    When method GET
    Then status 200
    And match response == '#[] #object'
    And match each response contains
      """
      {
        "id":         "#number",
        "first_name": "#string",
        "last_name":  "#string",
        "email":      "#string",
        "active":     "#boolean"
      }
      """
    * print '✅ Total de clientes recibidos:', response.length


  Scenario: Obtener un cliente por ID y validar su información
    Given path '/customers'
    And param id = 'eq.1'
    When method GET
    Then status 200
    And match response == '#[] #object'
    And match response[0] contains
      """
      {
        "id":         1,
        "first_name": "Emily",
        "last_name":  "#string",
        "email":      "#string",
        "active":     "#boolean"
      }
      """
    * print '✅ Cliente obtenido con ID 1:', response[0].first_name, response[0].last_name


  Scenario: Crear un nuevo cliente via POST y verificar en DB
    * def nuevoCliente =
      """
      {
        "first_name": "Axel",
        "last_name":  "QA",
        "email":      "axel.qa@example.com",
        "phone":      "+54-11-9999"
      }
      """

    Given path '/customers'
    And header Prefer = 'return=representation'
    And request nuevoCliente
    When method POST
    Then status 201

    * def creado = response[0]
    * def nuevoId = creado.id
    * print '✅ Cliente creado via API con ID:', nuevoId

    * def clienteDb = db.queryOne('SELECT * FROM api.customers WHERE id = ' + nuevoId)
    * assert clienteDb != null
    And match clienteDb.first_name == nuevoCliente.first_name
    And match clienteDb.email      == nuevoCliente.email
    * print '✅ Confirmado en PostgreSQL: cliente guardado con email', clienteDb.email

    * db.execute('DELETE FROM api.customers WHERE id = ' + nuevoId)
    * print '🧹 Cleanup: cliente', nuevoId, 'eliminado de la DB'


  Scenario: Intentar crear un cliente con email existente devuelve 409 Conflict
    * def clienteDuplicado =
      """
      {
        "first_name": "Clon",
        "last_name":  "Prueba",
        "email":      "emily.j@example.com",
        "phone":      "+54-11-1234"
      }
      """

    Given path '/customers'
    And request clienteDuplicado
    When method POST
    Then status 409
    And match response.message contains 'duplicate key value violates unique constraint'
    * print '🛑 Error esperado recibido correctamente:', response.message


  Scenario: Actualizar el telefono de un cliente via PATCH y auditar en DB
    # Guardar teléfono original para restaurarlo al final
    * def original = db.queryOne('SELECT phone FROM api.customers WHERE id = 1')
    * def telefonoOriginal = original.phone

    Given path '/customers'
    And param id = 'eq.1'
    And header Prefer = 'return=representation'
    And request { "phone": "+54-11-8888-9999" }
    When method PATCH
    Then status 200

    # 1. Validar respuesta de la API
    And match response[0].phone == '+54-11-8888-9999'
    And match response[0].first_name == 'Emily'

    # 2. Auditar directamente en PostgreSQL
    * def clienteDb = db.queryOne('SELECT * FROM api.customers WHERE id = 1')
    And match clienteDb.phone == '+54-11-8888-9999'
    * print '✅ Teléfono auditado en PostgreSQL con éxito:', clienteDb.phone

    # 3. Cleanup: restaurar el teléfono original
    * db.executeWithParams('UPDATE api.customers SET phone = ? WHERE id = 1', telefonoOriginal)
    * print '🔄 Teléfono original restaurado a:', telefonoOriginal
