@external @regression
Feature: Users API - Práctica con JSONPlaceholder

  Background:
    * url 'https://jsonplaceholder.typicode.com'

  Scenario: Obtener todos los usuarios
    Given path '/users'
    When method GET
    Then status 200
    And match response == '#[] #object'
    And match response[0] contains { id: '#number', name: '#string', email: '#string' }

  Scenario: Obtener un usuario por ID
    Given path '/users/1'
    When method GET
    Then status 200
    And match response contains
      """
      {
        id: 1,
        name: 'Leanne Graham',
        username: 'Bret',
        email: '#string',
        address: '#object',
        phone: '#string',
        website: '#string',
        company: '#object'
      }
      """

  Scenario: Crear un usuario nuevo (mock POST)
    Given path '/users'
    And request
      """
      {
        name: 'Axel Ramirez',
        username: 'axelr',
        email: 'axel@example.com'
      }
      """
    When method POST
    Then status 201
    And match response.id == '#number'
    And match response.name == 'Axel Ramirez'

  Scenario: Validar que los emails de todos los usuarios tienen formato correcto
    Given path '/users'
    When method GET
    Then status 200
    * def emails = $response[*].email
    * print 'Emails encontrados:', emails
    And match each response contains { email: '#regex .+@.+\\..+' }
