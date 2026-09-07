package karate;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * KarateRunner Enterprise — Parallel Execution Runner
 *
 * Este runner reemplaza el runner simple de JUnit.
 * Corre todos los features en paralelo y falla si alguno tiene errores.
 *
 * Comandos útiles:
 *
 *   # Toda la suite en paralelo (5 threads)
 *   .\mvnw.cmd test -Dtest=karate.KarateRunner
 *
 *   # Solo tests rápidos (smoke) — para CI en cada commit
 *   .\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags @smoke"
 *
 *   # Solo tests externos (sin Docker)
 *   .\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags @external"
 *
 *   # Solo tests con Docker levantado
 *   .\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags @local"
 *
 *   # Excluir tests que requieren Docker
 *   .\mvnw.cmd test -Dtest=karate.KarateRunner -Dkarate.options="--tags ~@local ~@db"
 *
 *   # Cambiar ambiente
 *   .\mvnw.cmd test -Dkarate.env=qa
 */
public class KarateRunner {

    @Test
    void testParallel() {
        Results results = Runner
            .path("classpath:karate")      // Escanea todos los features bajo /karate
            .tags("~@ignore")              // Excluye features marcados con @ignore
            .outputCucumberJson(true)      // Genera reporte compatible con Cucumber
            .parallel(5);                  // 5 threads simultáneos

        // El reporte HTML se genera en: target/karate-reports/karate-summary.html
        assertEquals(0, results.getFailCount(),
            results.getFailCount() + " scenario(s) fallaron.\n" +
            "Ver reporte en: target/karate-reports/karate-summary.html");
    }
}
