@echo off
setlocal
title Installation FastFetch

echo.
echo ========================================
echo   Installation de FastFetch
echo ========================================
echo.

REM Vérifier si curl est disponible
where curl >nul 2>&1
if errorlevel 1 (
    echo Erreur : curl n'est pas installe.
    echo.
    echo Téléchargez curl depuis : https://curl.se/windows/
    echo Copiez curl.exe dans C:\Windows\System32\
    echo.
    pause
    exit /b
)

REM Vérifier les droits admin
net session >nul 2>&1
if errorlevel 1 (
    echo Erreur : Droits administrateur requis.
    echo Lancez ce script en tant qu'administrateur.
    echo.
    pause
    exit /b
)

set "URL=https://github.com/fastfetch-cli/fastfetch/releases/download/2.57.1/fastfetch-windows-amd64.zip"
set "ZIP=%TEMP%\fastfetch.zip"
set "DEST=%USERPROFILE%\fastfetch"
set "EXE=%DEST%\fastfetch.exe"

echo [1/4] Téléchargement...
curl -L -o "%ZIP%" "%URL%"
if errorlevel 1 (
    echo Erreur lors du téléchargement.
    pause
    exit /b
)

echo [2/4] Préparation du dossier...
if exist "%DEST%" rmdir /s /q "%DEST%" 2>nul
mkdir "%DEST%" 2>nul

echo [3/4] Extraction...
tar -xf "%ZIP%" -C "%DEST%" 2>nul
if errorlevel 1 (
    echo Erreur tar, tentative avec PowerShell...
    powershell -Command "Expand-Archive -Path '%ZIP%' -DestinationPath '%DEST%' -Force" 2>nul
    if errorlevel 1 (
        echo Erreur d'extraction. Extrayez manuellement %ZIP% dans %DEST%
        pause
        exit /b
    )
)

echo [4/4] Configuration et démarrage...
if exist "%EXE%" (
    cd /d "%DEST%"
    %EXE% --gen-config 2>nul
    
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v FastFetch /t REG_SZ /d "\"%EXE%\"" /f 2>nul
    if errorlevel 0 (
        echo Ajoute au demarrage Windows.
    )
    
    echo.
    echo Test de FastFetch :
    %EXE%
) else (
    echo Erreur : Fichier non trouve : %EXE%
    dir "%DEST%"
)

echo.
echo ========================================
echo   Installation terminee
echo ========================================
echo.
del "%ZIP%" 2>nul
pause
