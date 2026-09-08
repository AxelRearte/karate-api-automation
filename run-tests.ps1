param (
    [string]$suite = "local"
)

# 1. Configurar Java 23
$env:JAVA_HOME = "C:\Program Files\Java\jdk-23"

Write-Host "🚀 Ejecutando pruebas de Karate ($suite)..." -ForegroundColor Cyan

# 2. Elegir qué runner ejecutar
if ($suite -eq "all") {
    .\mvnw.cmd test "-Dtest=karate.KarateRunner"
} elseif ($suite -eq "smoke") {
    .\mvnw.cmd test "-Dtest=karate.KarateRunner" "-Dkarate.options=--tags @smoke"
} else {
    .\mvnw.cmd test "-Dtest=karate.local.LocalRunner"
}

# 3. Abrir el reporte HTML automáticamente en el navegador
$reportPath = "target\karate-reports\karate-summary.html"
if (Test-Path $reportPath) {
    Write-Host "📊 Abriendo reporte HTML en tu navegador..." -ForegroundColor Green
    Start-Process $reportPath
} else {
    Write-Host "⚠️ No se encontró el archivo de reporte en $reportPath" -ForegroundColor Yellow
}
