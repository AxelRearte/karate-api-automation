@ignore
Feature: Helper — Buscar producto por ID y validar contrato
# Recibe: { id, categoriaEsperada, precioMinimo }
# Retorna: producto completo

  Scenario: Obtener y validar un producto por ID
    Given url baseUrl
    And header Authorization = 'Bearer ' + authToken
    And path '/products/' + id
    When method GET
    Then status 200

    # Validar que el ID devuelto coincide con el solicitado
    And match response.id == id

    # Validar que la categoría es la esperada
    And match response.category == categoriaEsperada

    # Validar precio mínimo como regla de negocio
    And assert response.price >= precioMinimo

    # Validar estructura mínima del contrato (schema validation)
    And match response contains
      """
      {
        "id":          "#number",
        "title":       "#string",
        "description": "#string",
        "price":       "#number",
        "rating":      "#number",
        "stock":       "#number",
        "category":    "#string",
        "thumbnail":   "#string"
      }
      """

    # Retornar el producto para que el caller pueda inspeccionarlo
    * def producto = response
    * print '  ↳ ID [' + id + '] ' + response.title + ' - $' + response.price
