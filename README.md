# 🥋 Karate DSL — Enterprise Test Automation Framework

Framework de automatización de pruebas a gran escala para **APIs REST y Bases de Datos** construido con **Karate DSL 2.1.2**, **Java 23**, **PostgreSQL** y **Docker Compose**.

---

## 🏛️ Arquitectura

```
┌──────────────────────────────────────────────────────────────┐
│                    KARATE PARALLEL RUNNER                    │
│               (5 Virtual Threads / JUnit 5)                  │
│                                                              │
│     @external                    @local             @db      │
│  (APIs públicas)            (PostgREST API)       (JDBC SQL) │
└────────────┬────────────────────────┬───────────────────┬────┘
             │ HTTP                   │ HTTP              │ SQL
             │                        ▼                   ▼
             │                ┌────────────────────────────────┐
             │                │         DOCKER COMPOSE         │
             │                │                                │
             │                │  ┌───────────┐   ┌───────────┐ │
             │                │  │ PostgREST │──►│PostgreSQL │ │
             │                │  │ Port 3000 │   │ Port 5432 │ │
             │                │  └───────────┘   └─────┬─────┘ │
             │                │                        │       │
             │                │                  ┌─────┴─────┐ │
             │                │                  │  pgAdmin  │ │
             │                │                  │ Port 5050 │ │
             │                │                  └───────────┘ │
             │                └────────────────────────────────┘
             ▼
       Internet APIs
```

---

## 🚀 Tecnologías & Herramientas

- **Karate DSL v2.1.2** — Testing de APIs REST con sintaxis Gherkin (sin glue code).
- **Java 23 & Maven Wrapper (`mvnw`)** — Ejecución paralela con virtual threads.
- **Docker & Docker Compose** — Infraestructura completa en contenedores descartables.
- **PostgreSQL 16** — Base de datos relacional para validación de persistencia.
- **PostgREST v12** — Servidor backend que expone PostgreSQL como API REST en tiempo real.
- **pgAdmin 4** — Panel visual para administración de la base de datos.
- **Spring JDBC & PostgreSQL Driver** — Conectividad directa a base de datos desde los tests.

---

## 🧪 Cobertura de Pruebas

| Módulo | Tipo | Descripción |
|---|---|---|
| `karate/local/products-local.feature` | E2E (API + DB) | CRUD de productos vía HTTP + validación cruzada con consultas JDBC en PostgreSQL. |
| `karate/local/orders.feature` | E2E (Negocio) | Flujo completo de compra: creación de orden, asignación de items y chequeo de constraints FK. |
| `karate/db/db-validation.feature` | DB Puro | Tests directos SQL vía JDBC: integridad referencial, unicidad de SKUs y validación de seeds. |
| `karate/auth/login.feature` | Seguridad | Autenticación con Bearer Tokens (JWT), escenarios positivos y negativos. |
| `karate/products/products.feature` | API Funcional | CRUD completo contra API externa con validación de esquemas y tipos fuzzy. |
| `karate/search/data-driven.feature` | Data-Driven | Pruebas conducidas por datos en 3 niveles (Outline inline, archivos JSON y CSV). |

---

## 💻 Instrucciones de Uso

### 1. Iniciar la infraestructura local (Docker)

```bash
docker compose up -d
```

Servicios disponibles:
- **API REST (PostgREST):** `http://localhost:3000`
- **PostgreSQL:** `localhost:5432` (db: `karatedb`, user: `karate`, pass: `karate123`)
- **pgAdmin UI:** `http://localhost:5050` (user: `admin@karate.com`, pass: `admin123`)

### 2. Ejecutar los tests

```powershell
# Setear JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Java\jdk-23"

# Ejecutar la suite completa en paralelo (35 escenarios)
.\mvnw.cmd test -Dtest=karate.KarateRunner

# Ejecutar solo tests rápidos de humo (Smoke)
.\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags @smoke"

# Ejecutar solo tests contra Docker (API + DB)
.\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags @local"

# Ejecutar solo tests de Base de Datos (JDBC)
.\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags @db"

# Ejecutar solo tests contra APIs externas (sin Docker)
.\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags @external"
```

### 3. Ver Reportes de Ejecución

Tras cada ejecución, Karate genera un reporte HTML interactivo con trazas de red y tiempos de respuesta:

```powershell
Start-Process 'target\karate-reports\karate-summary.html'
```

---

## 🛑 Detener la Infraestructura

```bash
# Pausar contenedores
docker compose stop

# Destruir contenedores y liberar recursos
docker compose down
```
