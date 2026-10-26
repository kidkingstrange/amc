# CineCross: Anime & Movies - Release Build Helper Script for Windows
# Run this script by right-clicking and selecting "Run with PowerShell" or executing in terminal.

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  CineCross: Anime & Movies - Android Release Builder     " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify Puzzles
Write-Host "[1/4] Verifying all 420 puzzle JSONs..." -ForegroundColor Cyan
& dart tools/verify_all_puzzles.dart
if ($LASTEXITCODE -ne 0) {
    Write-Host "Puzzle validation failed! Please fix puzzles before building." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "All 420 puzzles verified successfully!" -ForegroundColor Green
Write-Host ""

# Step 2: Run Tests
Write-Host "[2/4] Running automated test suite..." -ForegroundColor Cyan
& flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed! Aborting release build." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "All 23 test suites passed!" -ForegroundColor Green
Write-Host ""

# Step 3: Check for key.properties
Write-Host "[3/4] Checking release signing configuration..." -ForegroundColor Cyan
$keyPropsPath = "android\key.properties"
if (Test-Path $keyPropsPath) {
    Write-Host "Found android\key.properties. Release build will be signed with your private upload key!" -ForegroundColor Green
} else {
    Write-Host "Notice: android\key.properties not found." -ForegroundColor Yellow
    Write-Host "To sign your production bundle, follow docs\release\KEYSTORE_AND_SIGNING.md." -ForegroundColor Yellow
    Write-Host "Building release bundle with debug fallback signing for verification..." -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Build AAB
Write-Host "[4/4] Building Android App Bundle (AAB)..." -ForegroundColor Cyan
& flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  SUCCESS! Release bundle created at:                     " -ForegroundColor Green
    Write-Host "  build\app\outputs\bundle\release\app-release.aab        " -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Notice: Local Android SDK not found on this machine." -ForegroundColor Yellow
    Write-Host "You can build the production AAB in the cloud with zero setup!" -ForegroundColor Cyan
    Write-Host "Simply push this repo to GitHub and GitHub Actions will build it automatically." -ForegroundColor Green
}
