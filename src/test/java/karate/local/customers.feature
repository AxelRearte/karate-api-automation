@local @smoke @lock=customers
Feature: Gestión de Clientes (Customers API)

  Background:
    * url localApiUrl
    * def DbUtils = Java.type('util.DbUtils')
    * def db      = new DbUtils(dbConfig)

  Scenario: Obtener todos los clientes y validar su estructura
    # 1. Definir el endpoint (http://localhost:3000/customers)
    Given path '/customers'

    # 2. Ejecutar la petición HTTP tipo GET
    When method GET

    # 3. Validar que el servidor respondió 200 OK
    Then status 200

    # 4. Validar que la respuesta es una lista de objetos
    And match response == '#[] #object'

    # 5. Validar que CADA cliente de la lista tiene los campos correctos
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
    # Escenario escrito por Axel
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
    # Datos de prueba para el alta
    * def nuevoCliente =
      """
      {
        "first_name": "Axel",
        "last_name":  "QA",
        "email":      "axel.qa@example.com",
        "phone":      "+54-11-9999"
      }
      """

    # 1. Enviar el POST a la API
    Given path '/customers'
    And header Prefer = 'return=representation'
    And request nuevoCliente
    When method POST
    Then status 201

    * def creado = response[0]
    * def nuevoId = creado.id
    * print '✅ Cliente creado via API con ID:', nuevoId

    # 2. Auditar en la Base de Datos PostgreSQL
    * def clienteDb = db.queryOne('SELECT * FROM api.customers WHERE id = ' + nuevoId)
    * assert clienteDb != null
    And match clienteDb.first_name == nuevoCliente.first_name
    And match clienteDb.email      == nuevoCliente.email
    * print '✅ Confirmado en PostgreSQL: cliente guardado con email', clienteDb.email

    # 3. Cleanup: eliminar el registro de prueba para dejar la DB limpia
    * db.execute('DELETE FROM api.customers WHERE id = ' + nuevoId)
    * print '🧹 Cleanup: cliente', nuevoId, 'eliminado de la DB'
