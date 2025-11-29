@echo off
echo ========================================
echo   KONTARO - Ejecutar en Android
echo ========================================
echo.
echo Iniciando aplicacion en emulador...
echo Por favor espera 2-3 minutos la primera vez.
echo.
cd /d "%~dp0"
flutter run -d emulator-5554
pause
