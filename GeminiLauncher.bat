@echo off
setlocal

:: Check for Administrator privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Bu islem yonetici haklari gerektirir. Izin isteniyor...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

echo.
echo ==========================================
echo Gemini CLI Baslatiliyor...
echo ==========================================
echo.

:: Guncelleme simdilik devre disi (Hizlandirma icin)
:: echo Guncellemeler kontrol ediliyor...
:: call npm install -g @google/gemini-cli@latest

echo Bellek limiti artiriliyor (4GB)...
set NODE_OPTIONS=--max-old-space-size=4096

echo.
echo Hedef yol: "%APPDATA%\npm\gemini.cmd"

if exist "%APPDATA%\npm\gemini.cmd" (
    echo Gemini bulundu, baslatiliyor...
    call "%APPDATA%\npm\gemini.cmd" --yolo
) else (
    echo.
    echo HATA: Belirtilen yolda Gemini bulunamadi.
    echo Global 'gemini' komutu deneniyor...
    call gemini --yolo
)

if %errorlevel% NEQ 0 (
    echo.
    echo Gemini bir hata ile kapandi veya bulunamadi. Hata kodu: %errorlevel%
)

echo.
echo Gemini kapatildi. Cikmak icin bir tusa basin...
pause >nul
