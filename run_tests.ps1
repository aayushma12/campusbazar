# Flutter Test Coverage Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running Flutter Tests with Coverage" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Clean previous coverage data
Write-Host "Cleaning previous coverage data..." -ForegroundColor Yellow
if (Test-Path "coverage") {
    Remove-Item -Recurse -Force coverage
}

# Run tests with coverage
Write-Host ""
Write-Host "Running all tests..." -ForegroundColor Yellow
flutter test --coverage

# Check if tests passed
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "All tests passed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # Display coverage information
    if (Test-Path "coverage/lcov.info") {
        Write-Host "Coverage report generated at: coverage/lcov.info" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To view detailed coverage report:" -ForegroundColor Yellow
        Write-Host "1. Install lcov tools (if not already installed)" -ForegroundColor White
        Write-Host "2. Run: genhtml coverage/lcov.info -o coverage/html" -ForegroundColor White
        Write-Host "3. Open: coverage/html/index.html in your browser" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Some tests failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}
