@external @smoke
Feature: Autenticación con Bearer Token
# API real: https://dummyjson.com
# Cubre: POST con body, captura de token, uso en header Authorization

# ─────────────────────────────────────────────
# EJERCICIO 1A — Login básico
# Objetivo: hacer POST /auth/login y verificar que devuelve un token
# ─────────────────────────────────────────────
  Scenario: Login exitoso y recibo un token
    # 'url' fija la base — todos los 'path' se agregan acá
    Given url 'https://dummyjson.com'

    # 'path' agrega el endpoint a la URL base → https://dummyjson.com/auth/login
    And path '/auth/login'

    # 'request' es el body que mandamos (JSON automático)
    And request
      """
      {
        "username": "emilys",
        "password": "emilyspass"
      }
      """

    # 'method POST' dispara el HTTP request
    When method POST

    # 'status 200' falla el test si no recibe 200 — simple y directo
    Then status 200

    # 'match' valida el body de la respuesta
    # '#string' = "no me importa el valor exacto, solo que sea un string no vacío"
    And match response.accessToken == '#string'
    And match response.username == 'emilys'

    # 'print' es para debug — aparece en la consola cuando corrés
    * print '✅ Token recibido:', response.accessToken


# ─────────────────────────────────────────────
# EJERCICIO 1B — Capturar el token y usarlo en otro request
# Objetivo: login → guardar token → GET a endpoint protegido
# Esto es lo que hacés en el 99% de los proyectos reales
# ─────────────────────────────────────────────
  Scenario: Login y acceder a endpoint protegido con el token
    # PASO 1: Hacemos el login y guardamos el token
    Given url 'https://dummyjson.com'
    And path '/auth/login'
    And request { "username": "emilys", "password": "emilyspass" }
    When method POST
    Then status 200

    # 'def' guarda un valor en una variable para usarlo después
    # response.accessToken extrae el campo del JSON de respuesta
    * def token = response.accessToken
    * print '🔑 Token capturado, ahora lo usamos...'

    # PASO 2: Usamos el token en el siguiente request
    Given url 'https://dummyjson.com'
    And path '/auth/me'

    # 'header' agrega un header HTTP
    # 'Bearer ' + token construye el valor "Bearer eyJhbGci..."
    And header Authorization = 'Bearer ' + token

    When method GET
    Then status 200

    # Validamos que la respuesta corresponda al usuario logueado
    And match response.username == 'emilys'
    And match response.email == '#string'
    And match response.id == '#number'

    * print '✅ Usuario autenticado:', response.firstName, response.lastName


# ─────────────────────────────────────────────
# EJERCICIO 1C — Qué pasa con credenciales incorrectas
# Objetivo: verificar el comportamiento de error (401)
# En proyectos reales SIEMPRE hay que testear el camino feliz Y el triste
# ─────────────────────────────────────────────
  Scenario: Login con password incorrecto devuelve 400
    Given url 'https://dummyjson.com'
    And path '/auth/login'
    And request { "username": "emilys", "password": "passwordMAL" }
    When method POST

    # dummyjson devuelve 400 para credenciales inválidas
    Then status 400
    And match response.message == '#string'
    * print '✅ Error esperado:', response.message
