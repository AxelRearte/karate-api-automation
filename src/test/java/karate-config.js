function fn() {

  var env = karate.env || 'dev';
  karate.log('▶ Ambiente:', env);

  // ── URLs base por ambiente ────────────────────────────────────
  var urls = {
    dev:  { api: 'http://localhost:3000',          external: 'https://dummyjson.com' },
    qa:   { api: 'http://qa-api.miempresa.com',    external: 'https://dummyjson.com' },
    prod: { api: 'http://api.miempresa.com',       external: 'https://dummyjson.com' }
  };

  // ── Configuración de DB por ambiente ─────────────────────────
  var dbs = {
    dev:  { url: 'jdbc:postgresql://localhost:5432/karatedb', username: 'karate', password: 'karate123' },
    qa:   { url: 'jdbc:postgresql://qa-db:5432/karatedb',     username: 'karate', password: 'karate123' },
    prod: { url: 'jdbc:postgresql://prod-db:5432/karatedb',   username: 'karate', password: 'karate123' }
  };

  var config = {
    env:         env,
    baseUrl:     urls[env].external,   // APIs externas (dummyjson)
    localApiUrl: urls[env].api,        // API local (PostgREST en Docker)
    dbConfig:    dbs[env],             // Configuración JDBC

    // Credenciales externas (dummyjson)
    credentials: {
      username: 'emilys',
      password: 'emilyspass'
    }
  };

  // ── Login externo (callSingle = una vez por suite) ────────────
  var loginResult = karate.callSingle(
    'classpath:karate/common/login.feature',
    config
  );
  config.authToken = loginResult.accessToken;

  karate.log('✅ Config lista. env=' + env + ' | localApi=' + config.localApiUrl);
  return config;
}
