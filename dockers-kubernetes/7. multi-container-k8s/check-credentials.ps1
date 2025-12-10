# Script para verificar credenciales del repositorio
# Run this script in PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Verificacion de Credenciales GCP      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$credFile = "multik8s-480817-178af3bdc5fd.json"

# Check if file exists locally
if (Test-Path $credFile) {
    Write-Host "[!] ADVERTENCIA: El archivo $credFile existe localmente." -ForegroundColor Yellow
    Write-Host "    Este archivo NO debe estar en Git." -ForegroundColor Yellow
    Write-Host ""
}

# Check if file is staged
$gitStatus = git status --porcelain 2>$null
if ($gitStatus -match $credFile) {
    Write-Host "[!] ADVERTENCIA: $credFile esta en staging!" -ForegroundColor Red
    Write-Host "    Ejecuta: git reset HEAD $credFile" -ForegroundColor Yellow
    Write-Host ""
}

# Check Git history
Write-Host "Verificando historial de Git..." -ForegroundColor Cyan
$inHistory = git log --all --full-history --oneline -- $credFile 2>$null

if ($inHistory) {
    Write-Host ""
    Write-Host "[X] CRITICO: El archivo esta en el historial de Git!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Debes eliminarlo del historial y rotar las credenciales." -ForegroundColor Red
    Write-Host "Consulta GITHUB_ACTIONS_SETUP.md para instrucciones." -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "[OK] El archivo NO esta en el historial de Git." -ForegroundColor Green
    Write-Host ""
}

# Check .gitignore
Write-Host "Verificando .gitignore..." -ForegroundColor Cyan
if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    if ($gitignoreContent -match $credFile) {
        Write-Host "[OK] El archivo esta protegido en .gitignore" -ForegroundColor Green
    } else {
        Write-Host "[!] ADVERTENCIA: Verifica .gitignore" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] ADVERTENCIA: No existe .gitignore" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Proximos pasos                         " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Lee GITHUB_ACTIONS_SETUP.md" -ForegroundColor White
Write-Host "2. Configura los secrets en GitHub" -ForegroundColor White
Write-Host "3. NO subas $credFile a GitHub" -ForegroundColor White
Write-Host "4. Haz push y verifica en Actions" -ForegroundColor White
Write-Host ""
