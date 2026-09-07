@local @smoke
Feature: Gestión de Clientes (Customers API)

  Background:
    * url localApiUrl

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
