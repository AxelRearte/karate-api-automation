@ignore
Feature: Helper — Buscar por categoría (reutilizable)
# Recibe: { categoria, precioMinimo }
# Retorna: total (número de productos encontrados)

  Scenario: Buscar productos de una categoría
    # Pausa para respetar rate limits de la API pública (429 Too Many Requests)
    * karate.pause(500)
    Given url baseUrl
    And header Authorization = 'Bearer ' + authToken
    And path '/products/category/' + categoria
    When method GET
    Then status 200

    # Guardar productos
    * def productos = response.products

    # BEST PRACTICE: validar que el array no esté vacío
    * assert productos.length > 0

    # Validar que cada producto pertenece a la categoría pedida
    # Loop JS en una línea (requerido por el parser de Karate en steps * def)
    * def cat = categoria
    * def checkCats = function(arr) { for (var i=0; i<arr.length; i++) { if (arr[i].category !== cat) { karate.fail('ID=' + arr[i].id + ' categoría "' + arr[i].category + '" != "' + cat + '"'); } } }
    * checkCats(productos)

    # Retorna al caller (disponible como resultados[i].total)
    * def total = response.total
    * print '  ↳ [' + categoria + ']: ' + total + ' productos, primero: ' + productos[0].title
