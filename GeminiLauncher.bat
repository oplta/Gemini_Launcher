@echo off
setlocal EnableDelayedExpansion

:: ---------------------------------------------------------
:: Gemini Launcher v3
:: Language Support, Menu System, Advanced Tools
:: ---------------------------------------------------------

title Gemini Launcher v3
color 0B

:: 1. Admin Privilege Check
:: ---------------------------------------------------------
:CheckAdmin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    echo Requesting Administrator privileges...
    echo Yonetici haklari isteniyor...
    goto UACPrompt
) else ( goto Init )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:: 2. Initialization & Language Selection
:: ---------------------------------------------------------
:Init
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
    cls

    echo ===================================================
    echo             GEMINI LAUNCHER v3
    echo ===================================================
    echo.
    echo Please select your language / Lutfen dil secin:
    echo.
    echo [1] Turkce
    echo [2] English
    echo.
    
    choice /C 12 /M "Selection/Secim: "
    if errorlevel 2 goto LangEN
    if errorlevel 1 goto LangTR

:LangTR
    set LANG=TR
    set TXT_MENU_TITLE=ANA MENU
    set TXT_OPT1=Gemini'yi Baslat (Onerilen)
    set TXT_OPT2=Guncelle
    set TXT_OPT3=Onar / Yeniden Kur
    set TXT_OPT4=Masaustu Kisayolu Olustur
    set TXT_OPT5=Kaldir (Uninstall)
    set TXT_OPT6=Cikis
    set TXT_CHOICE=Seciminiz
    set TXT_PREREQ=Altyapi kontrol ediliyor...
    set TXT_NODE_ERR=HATA: Node.js bulunamadi! https://nodejs.org/ adresinden yukleyin.
    set TXT_NPM_ERR=HATA: NPM bulunamadi!
    set TXT_GEM_CHECK=Gemini CLI kontrol ediliyor...
    set TXT_GEM_INS=Gemini CLI yukleniyor...
    set TXT_GEM_UPD=Guncelleme kontrol ediliyor...
    set TXT_GEM_OK=Gemini CLI hazir.
    set TXT_MEM=Bellek limiti ayarlaniyor (4GB)...
    set TXT_LAUNCH=Gemini CLI baslatiliyor...
    set TXT_CRASH=Gemini beklenmedik sekilde kapandi.
    set TXT_SHORTCUT=Masaustu kisayolu olusturuldu!
    set TXT_REMOVED=Gemini CLI sistemden kaldirildi.
    set TXT_PRESS=Devam etmek icin bir tusa basin...
    goto MainMenu

:LangEN
    set LANG=EN
    set TXT_MENU_TITLE=MAIN MENU
    set TXT_OPT1=Launch Gemini (Recommended)
    set TXT_OPT2=Update
    set TXT_OPT3=Repair / Reinstall
    set TXT_OPT4=Create Desktop Shortcut
    set TXT_OPT5=Uninstall
    set TXT_OPT6=Exit
    set TXT_CHOICE=Your Choice
    set TXT_PREREQ=Checking prerequisites...
    set TXT_NODE_ERR=ERROR: Node.js not found! Please install from https://nodejs.org/
    set TXT_NPM_ERR=ERROR: NPM not found!
    set TXT_GEM_CHECK=Checking Gemini CLI...
    set TXT_GEM_INS=Installing Gemini CLI...
    set TXT_GEM_UPD=Checking for updates...
    set TXT_GEM_OK=Gemini CLI is ready.
    set TXT_MEM=Setting memory limit (4GB)...
    set TXT_LAUNCH=Launching Gemini CLI...
    set TXT_CRASH=Gemini closed unexpectedly.
    set TXT_SHORTCUT=Desktop shortcut created!
    set TXT_REMOVED=Gemini CLI has been removed.
    set TXT_PRESS=Press any key to continue...
    goto MainMenu

:: 3. Main Menu
:: ---------------------------------------------------------
:MainMenu
    cls
    echo ===================================================
    echo             %TXT_MENU_TITLE%
    echo ===================================================
    echo.
    echo [1] %TXT_OPT1%
    echo [2] %TXT_OPT2%
    echo [3] %TXT_OPT3%
    echo [4] %TXT_OPT4%
    echo [5] %TXT_OPT5%
    echo [6] %TXT_OPT6%
    echo.
    
    choice /C 123456 /M "%TXT_CHOICE%: "
    
    if errorlevel 6 goto Exit
    if errorlevel 5 goto Uninstall
    if errorlevel 4 goto Shortcut
    if errorlevel 3 goto Repair
    if errorlevel 2 goto Update
    if errorlevel 1 goto Launch

:: 4. Functions
:: ---------------------------------------------------------

:Launch
    cls
    echo %TXT_PREREQ%
    call :CheckNode
    call :CheckGeminiLaunch
    echo.
    echo %TXT_MEM%
    set NODE_OPTIONS=--max-old-space-size=4096
    echo.
    echo %TXT_LAUNCH%
    echo ---------------------------------------------------
    call gemini --yolo
    if %errorlevel% NEQ 0 (
        echo.
        echo %TXT_CRASH%
    )
    echo.
    echo %TXT_PRESS%
    pause >nul
    goto MainMenu

:Update
    cls
    echo %TXT_GEM_UPD%
    call npm update -g @google/gemini-cli
    echo.
    echo %TXT_GEM_OK%
    timeout /t 3 >nul
    goto MainMenu

:Repair
    cls
    echo %TXT_GEM_INS%
    call npm uninstall -g @google/gemini-cli
    call npm install -g @google/gemini-cli
    echo.
    echo %TXT_GEM_OK%
    timeout /t 3 >nul
    goto MainMenu

:Shortcut
    cls
    echo Creating shortcut...
    set SCRIPT="%temp%\create_shortcut.vbs"
    echo Set oWS = WScript.CreateObject("WScript.Shell") > %SCRIPT%
    echo sLinkFile = oWS.ExpandEnvironmentStrings("%%USERPROFILE%%\Desktop\Gemini CLI.lnk") >> %SCRIPT%
    echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
    echo oLink.TargetPath = "%~f0" >> %SCRIPT%
    echo oLink.IconLocation = "%SystemRoot%\System32\cmd.exe" >> %SCRIPT%
    echo oLink.Save >> %SCRIPT%
    cscript /nologo %SCRIPT%
    del %SCRIPT%
    echo.
    echo %TXT_SHORTCUT%
    timeout /t 3 >nul
    goto MainMenu

:Uninstall
    cls
    echo Uninstalling...
    call npm uninstall -g @google/gemini-cli
    echo.
    echo %TXT_REMOVED%
    echo.
    echo %TXT_PRESS%
    pause >nul
    goto MainMenu

:Exit
    exit

:: Helper Functions
:CheckNode
    where node >nul 2>nul
    if %errorlevel% NEQ 0 (
        echo %TXT_NODE_ERR%
        pause
        exit
    )
    where npm >nul 2>nul
    if %errorlevel% NEQ 0 (
        echo %TXT_NPM_ERR%
        pause
        exit
    )
    exit /B

:CheckGeminiLaunch
    where gemini >nul 2>nul
    if %errorlevel% NEQ 0 (
        echo %TXT_GEM_INS%
        call npm install -g @google/gemini-cli
    )
    exit /B
