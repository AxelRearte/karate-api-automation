@external @regression
Feature: Products API — CRUD completo
# API: https://dummyjson.com/docs/products
# Cubre: GET lista, GET por ID, POST, PUT, DELETE
# Token: viene automáticamente de karate-config.js (callSingle)

  # ── BEST PRACTICE: Background ──────────────────────────────────
  # Todo lo que esté en Background se ejecuta ANTES de cada Scenario.
  # Acá ponemos la configuración que comparten todos los scenarios:
  # la URL base y el header de autenticación.
  # Resultado: ningún scenario necesita repetir esto.
  Background:
    * url baseUrl
    # authToken viene de karate-config.js → ya está logueado
    * header Authorization = 'Bearer ' + authToken


  # ── Scenario 1: Listar productos ────────────────────────────────
  Scenario: Obtener lista de productos con paginación
    Given path '/products'
    # BEST PRACTICE: siempre testear query params relevantes del negocio
    And param limit = 5
    And param skip  = 0
    When method GET
    Then status 200

    # BEST PRACTICE: validar estructura + tipos, no valores exactos
    # '#[]' = es un array
    # '#object' = cada elemento es un objeto
    And match response.products == '#[] #object'

    # Validar que la paginación funciona: pedimos 5, deben volver 5
    And match response.limit == 5
    And match response.skip  == 0
    And assert response.products.length == 5

    # BEST PRACTICE: 'match each' para validar TODOS los elementos del array
    # Si algún producto rompe el schema, el test falla con el índice exacto
    And match each response.products contains
      """
      {
        "id":    "#number",
        "title": "#string",
        "price": "#number",
        "stock": "#number",
        "brand": "##string",
        "thumbnail": "#string"
      }
      """
    # Nota: "##string" = opcional (puede ser null o string). Buena práctica
    # para campos que no siempre están presentes en la API.


  # ── Scenario 2: Obtener un producto por ID ──────────────────────
  Scenario: Obtener producto por ID y validar su estructura completa
    Given path '/products/1'
    When method GET
    Then status 200

    # BEST PRACTICE: 'def' + reusar variable en el mismo scenario
    * def product = response

    And match product.id          == 1
    And match product.title       == '#string'
    And match product.description == '#string'
    And match product.price       == '#number'
    And match product.rating      == '#number'

    # Validar que el rating tiene sentido de negocio (entre 0 y 5)
    And assert product.rating >= 0 && product.rating <= 5

    # Validar array anidado: imágenes del producto
    And match product.images == '#[] #string'


  # ── Scenario 3: Buscar productos por categoría ─────────────────
  Scenario: Filtrar productos por categoría
    Given path '/products/category/smartphones'
    When method GET
    Then status 200

    # Todos los productos deben ser de la categoría solicitada
    And match each response.products contains { category: 'smartphones' }


  # ── Scenario 4: Crear un producto (POST) ────────────────────────
  Scenario: Crear un nuevo producto vía POST
    # BEST PRACTICE: definir el payload antes del request para legibilidad
    * def nuevoProducto =
      """
      {
        "title":       "Laptop de prueba QA",
        "description": "Producto creado por Karate DSL",
        "price":       999.99,
        "stock":       50,
        "brand":       "QA Brand",
        "category":    "laptops"
      }
      """

    Given path '/products/add'
    And request nuevoProducto
    When method POST
    Then status 201

    # Verificar que la respuesta refleja lo que enviamos
    And match response.id          == '#number'
    And match response.title       == nuevoProducto.title
    And match response.price       == nuevoProducto.price
    And match response.brand       == nuevoProducto.brand
    * print '✅ Producto creado con ID:', response.id


  # ── Scenario 5: Actualizar un producto (PUT) ────────────────────
  Scenario: Actualizar precio de un producto existente
    * def precioNuevo = 1299.99

    Given path '/products/1'
    And request { "price": '#(precioNuevo)' }
    When method PUT
    Then status 200

    # La API devuelve el producto actualizado — validamos el campo modificado
    And match response.price == precioNuevo
    And match response.id    == 1
    * print '✅ Precio actualizado a:', response.price


  # ── Scenario 6: Eliminar un producto (DELETE) ───────────────────
  Scenario: Eliminar un producto y verificar la respuesta
    Given path '/products/1'
    When method DELETE
    Then status 200

    # dummyjson devuelve el producto eliminado + flag isDeleted
    And match response.isDeleted  == true
    And match response.deletedOn  == '#string'
    And match response.id         == 1
    * print '✅ Producto eliminado:', response.title
