@ignore
# ─────────────────────────────────────────────────────────────
# BEST PRACTICE: @ignore
# Este tag le dice a Karate que NO corra este feature solo.
# Solo se ejecuta cuando otro feature lo llama con 'call' o
# cuando karate-config.js lo llama con 'callSingle'.
#
# Recibe como parámetros todo lo que le pase el caller:
#   - baseUrl       → viene de karate-config.js
#   - credentials   → viene de karate-config.js
# ─────────────────────────────────────────────────────────────
Feature: Common - Login reutilizable

  Scenario: Autenticarse y retornar el access token
    # BEST PRACTICE: usar '#(variable)' para interpolar variables en el body
    # Las variables credentials.username y credentials.password
    # vienen del config que pasó el caller
    Given url baseUrl + '/auth/login'
    And request
      """
      {
        "username": "#(credentials.username)",
        "password": "#(credentials.password)"
      }
      """
    When method POST
    Then status 200

    # BEST PRACTICE: validar la estructura antes de usar el token
    And match response.accessToken == '#string'
    And match response.id          == '#number'

    # 'accessToken' queda disponible para quien llame este feature
    # El caller lo recibe en: var result = karate.callSingle(...) → result.accessToken
    * def accessToken = response.accessToken
