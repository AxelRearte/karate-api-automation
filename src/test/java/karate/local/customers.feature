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
    # Caso negativo: validación de unicidad de email
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

    # Validar que el mensaje de error mencione la restricción de clave duplicada
    And match response.message contains 'duplicate key value violates unique constraint'
    * print '🛑 Error esperado recibido correctamente:', response.message
