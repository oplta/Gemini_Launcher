@echo off
setlocal EnableDelayedExpansion

:: ---------------------------------------------------------
:: Gemini Launcher v2
:: Gelismis Baslatma, Kaynak Yonetimi ve Otomatik Guncelleme
:: ---------------------------------------------------------

title Gemini Launcher v2
color 0B

:: 1. Yonetici Haklari Kontrolu
:: ---------------------------------------------------------
:CheckAdmin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    echo [BILGI] Yonetici haklari gerekiyor. Izin isteniyor...
    goto UACPrompt
) else ( goto Init )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:: 2. Baslangic ve Kontroller
:: ---------------------------------------------------------
:Init
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
    cls

    echo ===================================================
    echo             GEMINI LAUNCHER v2
    echo ===================================================
    echo.

:: 3. Altyapi Kontrolu (Node.js & NPM)
:: ---------------------------------------------------------
:CheckPrerequisites
    echo [1/4] Altyapi kontrol ediliyor (Node.js & NPM)...
    
    where node >nul 2>nul
    if %errorlevel% NEQ 0 (
        color 0C
        echo.
        echo [HATA] Node.js bulunamadi!
        echo Gemini CLI calismak icin Node.js'e ihtiyac duyar.
        echo Lutfen https://nodejs.org/ adresinden LTS surumunu yukleyin.
        echo.
        pause
        exit
    )

    where npm >nul 2>nul
    if %errorlevel% NEQ 0 (
        color 0C
        echo.
        echo [HATA] NPM paket yoneticisi bulunamadi!
        echo Node.js kurulumunuz eksik olabilir.
        echo.
        pause
        exit
    )
    echo [OK] Node.js ve NPM mevcut.

:: 4. Gemini CLI Varlik ve Guncelleme Kontrolu
:: ---------------------------------------------------------
:CheckGemini
    echo [2/4] Gemini CLI kontrol ediliyor...

    :: Once global npm path'ini alalim
    for /f "tokens=*" %%g in ('npm root -g') do (set GLOBAL_NPM_PATH=%%g)
    set GEMINI_CMD_PATH=!GLOBAL_NPM_PATH!\gemini.cmd
    
    :: Klasik metod (path kontrolu)
    where gemini >nul 2>nul
    if %errorlevel% EQU 0 (
        set GEMINI_INSTALLED=1
    ) else (
        if exist "!GEMINI_CMD_PATH!" (
            set GEMINI_INSTALLED=1
        ) else (
            set GEMINI_INSTALLED=0
        )
    )

    if !GEMINI_INSTALLED! EQU 0 (
        echo.
        echo [BILGI] Gemini CLI yuklu degil. v2 Otomatik Kurulum baslatiliyor...
        echo.
        call npm install -g @google/gemini-cli
        if !errorlevel! NEQ 0 (
            color 0C
            echo.
            echo [HATA] Kurulum basarisiz oldu. Internet baglantinizi kontrol edin.
            pause
            exit
        )
        echo [OK] Gemini CLI basariyla kuruldu!
    ) else (
        echo [BILGI] Gemini CLI bulundu. Guncelleme kontrolu yapiliyor...
        :: Sessizce guncellemeyi dene (hizli gecis icin timeout konabilir ama batch'de zor)
        :: Kullaniciyi bekletmemek icin sadece kurulu oldugunu teyit edip devam ediyoruz 
        :: veya istege bagli update acilabilir. Simdilik 'update' komutunu calistiralim.
        call npm update -g @google/gemini-cli
        echo [OK] Gemini CLI guncel.
    )

:: 5. Bellek Ayarlari ve Baslatma Hazirligi
:: ---------------------------------------------------------
:PrepareLaunch
    echo [3/4] Bellek limiti ayarlaniyor (4GB)...
    set NODE_OPTIONS=--max-old-space-size=4096
    echo [OK] Hazir.

:: 6. Baslatma ve Hata Toleransi
:: ---------------------------------------------------------
:Launch
    echo.
    echo [4/4] Gemini CLI baslatiliyor...
    echo ===================================================
    echo.

    call gemini --yolo
    
    if %errorlevel% NEQ 0 (
        echo.
        echo ===================================================
        echo [UYARI] Gemini beklenmedik bir sekilde kapandi (Kod: %errorlevel%).
        echo.
        echo Olasiliklar:
        echo 1. API Anahtari eksik olabilir.
        echo 2. Kurulum bozulmus olabilir.
        echo.
        choice /C EH /M "Kurulumu onarmayi denemek ister misiniz? (E=Evet, H=Hayir)"
        if errorlevel 1 goto Repair
        if errorlevel 2 goto End
    )
    goto End

:Repair
    cls
    echo [ONARIM] Gemini CLI kaldirilip yeniden kuruluyor...
    echo.
    call npm uninstall -g @google/gemini-cli
    echo.
    call npm install -g @google/gemini-cli
    echo.
    echo [OK] Onarim tamamlandi. Yeniden baslatiliyor...
    pause
    goto Init

:End
    echo.
    echo Gemini kapatildi.
    pause
