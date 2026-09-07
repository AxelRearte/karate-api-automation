@external @regression
Feature: Data-Driven Testing — 3 niveles
# Objetivo: aprender a correr el mismo test con distintos datos
# sin duplicar código. Cuanto más datos, más valor.
# API: dummyjson.com — búsqueda de productos

  Background:
    * url baseUrl
    * header Authorization = 'Bearer ' + authToken


  # ════════════════════════════════════════════════════════════
  # NIVEL 3A — Scenario Outline con tabla inline
  # ════════════════════════════════════════════════════════════
  # Cuándo usarlo: cuando los datos son pocos y fijos.
  # Cómo funciona: Karate genera UN scenario por cada fila de la tabla.
  # Las columnas de Examples se referencian con <nombre_columna>.
  # ════════════════════════════════════════════════════════════

  Scenario Outline: [3A] Buscar productos por categoría — <categoria>
    Given path '/products/category/<categoria>'
    When method GET
    Then status 200

    # Cada fila de la tabla genera un assert diferente
    And assert response.products.length > 0
    And match each response.products contains { category: '<categoria>' }

    * print '[3A] Categoría:', '<categoria>', '→ Productos:', response.total

    # La tabla de datos — una fila = un test
    Examples:
      | categoria    |
      | smartphones  |
      | laptops      |
      | fragrances   |


  # ════════════════════════════════════════════════════════════
  # NIVEL 3B — Datos desde archivo JSON externo
  # ════════════════════════════════════════════════════════════
  # Cuándo usarlo: cuando los datos son muchos, cambian seguido,
  # o los mantiene alguien de negocio (no dev).
  # BEST PRACTICE: separar datos del código del test.
  # El archivo JSON puede tenerlo un analista de negocio.
  # ════════════════════════════════════════════════════════════

  Scenario: [3B] Buscar por categorías desde archivo JSON externo
    * def categorias = read('data/categorias.json')

    # 'call read()' con un array ejecuta el feature UNA VEZ POR ELEMENTO
    # El pause (500ms) está dentro del helper para respetar rate limits
    * def resultados = call read('buscar-categoria.feature') categorias

    And assert resultados.length == 5
    * print '[3B] ✅ Categorías verificadas:', resultados.length


  # ════════════════════════════════════════════════════════════
  # NIVEL 3B-CSV — Datos desde archivo CSV
  # ════════════════════════════════════════════════════════════
  # Cuándo usarlo: cuando los datos vienen de Excel/Sheets
  # o de un equipo de QA manual que los gestiona en planillas.
  # Karate lee CSV y lo convierte automáticamente a array de objetos.
  # La primera fila del CSV se usa como nombre de las columnas.
  # NOTA: los valores del CSV siempre llegan como String,
  # usar karate.toInt() para convertir cuando se necesita comparar números
  # ════════════════════════════════════════════════════════════

  Scenario Outline: [3B-CSV] Buscar productos por keyword — <q>
    Given path '/products/search'
    And param q = '<q>'
    When method GET
    Then status 200

    # CSV trae los valores como String → convertimos a número con JS estándar
    * def minEsperado = parseInt('<resultadoEsperadoMinimo>')
    And assert response.total >= minEsperado
    And match response.products == '#[] #object'

    * print '[3B-CSV] Búsqueda:', '<q>', '→ Total:', response.total

    # Karate convierte el CSV a tabla de Examples automáticamente
    Examples:
      | read('data/busquedas.csv') |


  # ════════════════════════════════════════════════════════════
  # NIVEL 3C — call con array dinámico (el más poderoso)
  # ════════════════════════════════════════════════════════════
  # Cuándo usarlo: cuando necesitás lógica compleja por cada fila
  # o cuando los datos se generan dinámicamente en runtime.
  # Permite pasar variables entre el caller y el feature llamado.
  # BEST PRACTICE: para validaciones de contrato end-to-end.
  # ════════════════════════════════════════════════════════════

  Scenario: [3C] Verificar múltiples productos por ID con call dinámico
    # Definimos los datos como array de objetos directamente en el feature
    # En proyectos reales esto vendría de una DB, de otro endpoint, etc.
    * def productos =
      """
      [
        { "id": 1,  "categoriaEsperada": "beauty",    "precioMinimo": 1 },
        { "id": 2,  "categoriaEsperada": "beauty",    "precioMinimo": 1 },
        { "id": 3,  "categoriaEsperada": "beauty",    "precioMinimo": 1 },
        { "id": 11, "categoriaEsperada": "furniture", "precioMinimo": 1 },
        { "id": 22, "categoriaEsperada": "groceries", "precioMinimo": 1 }
      ]
      """

    # 'call' con un array → ejecuta el feature UNA VEZ POR ELEMENTO
    # Es como un forEach pero con la potencia completa de Karate
    # El feature llamado recibe cada objeto como sus variables locales
    * def resultados = call read('buscar-por-id.feature') productos

    # Después del call, 'resultados' es un array con la respuesta de cada llamada
    * print '[3C] Total de productos verificados:', resultados.length
    And assert resultados.length == 5
