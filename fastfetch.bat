@echo off
setlocal enabledelayedexpansion

:: Vérification des privilèges administrateur
echo Vérification des privilèges administrateur...
net session >nul 2>nul
if %errorlevel% equ 0 (
    echo [ADMIN] Exécution en tant qu'administrateur confirmé
) else (
    echo [ERREUR] Script non exécuté en tant qu'administrateur
    echo.
    echo Veuillez exécuter ce script en tant qu'administrateur.
    pause
    exit /b
)

echo.
echo Vérification de Winget...
where winget >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Winget n'est pas disponible. Ce script nécessite Windows 10/11 avec Winget.
    pause
    exit /b
)
echo [OK] Winget disponible

echo.
echo Vérification de Chocolatey...
where choco >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Chocolatey n'est pas installé. Installation en cours...
    
    echo Installation de Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    timeout /t 8 /nobreak >nul
    
    :: Vérification alternative de l'installation Chocolatey
    if exist "C:\ProgramData\chocolatey\bin\choco.exe" (
        echo [OK] Chocolatey installé avec succès.
        :: Ajout temporaire de Chocolatey au PATH pour cette session
        set "PATH=%PATH%;C:\ProgramData\chocolatey\bin"
    ) else (
        echo [ERREUR] Échec de l'installation de Chocolatey.
        pause
        exit /b
    )
) else (
    echo [OK] Chocolatey est déjà installé.
)

echo.
echo Installation de Fastfetch via Chocolatey...
choco install fastfetch -y --force

echo.
echo Vérification de l'installation de Fastfetch...
where fastfetch >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Fastfetch n'est pas accessible dans le PATH. Vérification dans le dossier Chocolatey...
    
    :: Plusieurs chemins possibles pour fastfetch avec Chocolatey
    set "CHOCO_PATHS=C:\ProgramData\chocolatey\lib\fastfetch\tools;C:\ProgramData\chocolatey\bin;%USERPROFILE%\AppData\Local\Temp\chocolatey"
    
    set FOUND=0
    for %%P in (%CHOCO_PATHS%) do (
        if exist "%%P\fastfetch.exe" (
            echo [OK] Fastfetch trouvé dans %%P
            set "FASTFETCH_PATH=%%P"
            set FOUND=1
        )
    )
    
    if !FOUND! equ 1 (
        echo Ajout de Fastfetch au PATH...
        setx PATH "!PATH!;!FASTFETCH_PATH!" /M
        echo [OK] Fastfetch ajouté au PATH. Redémarrage nécessaire.
    ) else (
        echo [INFO] Tentative d'installation via Winget en alternative...
        winget install fastfetch.fastfetch -h --accept-package-agreements --accept-source-agreements
        
        where fastfetch >nul 2>nul
        if %errorlevel% neq 0 (
            echo [ERREUR] Fastfetch n'a pas été trouvé après installation.
            echo Veuillez vérifier manuellement l'installation.
            pause
            exit /b
        ) else (
            echo [OK] Fastfetch installé via Winget
        )
    )
) else (
    echo [OK] Fastfetch accessible dans le PATH
)

echo.
echo Configuration du registre pour CMD...
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "fastfetch" /f
if %errorlevel% equ 0 (
    echo [OK] Configuration CMD terminée
) else (
    echo [ERREUR] Échec de la configuration CMD
)

echo Configuration pour PowerShell...
:: Création du profil PowerShell avec la bonne commande
set "PS_PROFILE_DIR=%USERPROFILE%\Documents\WindowsPowerShell"
if not exist "!PS_PROFILE_DIR!" (
    mkdir "!PS_PROFILE_DIR!" >nul 2>nul
)

set "PS_PROFILE_FILE=!PS_PROFILE_DIR!\Microsoft.PowerShell_profile.ps1"

:: Vérifier si fastfetch est dans le PATH
where fastfetch >nul 2>nul
if %errorlevel% equ 0 (
    set "FASTFETCH_CMD=fastfetch"
) else (
    :: Chercher le chemin exact de fastfetch
    set FOUND=0
    for /f "delims=" %%F in ('dir /s /b "fastfetch.exe" 2^>nul') do (
        set "FASTFETCH_CMD=%%F"
        set FOUND=1
    )
    if !FOUND! equ 0 (
        set "FASTFETCH_CMD=fastfetch"
    )
)

:: Créer ou mettre à jour le profil PowerShell
(
    echo @'
:: Auto-run fastfetch in PowerShell
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch
}
'@
) > "!PS_PROFILE_FILE!"

echo [OK] Profil PowerShell configuré correctement

:: Configuration pour PowerShell Core (7+)
set "PS_CORE_PROFILE_DIR=%USERPROFILE%\Documents\PowerShell"
if not exist "!PS_CORE_PROFILE_DIR!" (
    mkdir "!PS_CORE_PROFILE_DIR!" >nul 2>nul
)

set "PS_CORE_PROFILE_FILE=!PS_CORE_PROFILE_DIR!\Microsoft.PowerShell_profile.ps1"
(
    echo @'
:: Auto-run fastfetch in PowerShell Core
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch
}
'@
) > "!PS_CORE_PROFILE_FILE!"

echo [OK] Profil PowerShell Core configuré

:: Configuration supplémentaire pour PowerShell - Execution Policy
echo Configuration de la politique d'exécution PowerShell...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" >nul 2>nul
echo [OK] Politique d'exécution configurée

echo.
echo Test de la configuration PowerShell...
powershell -NoProfile -Command "if (Test-Path '!PS_PROFILE_FILE!') { Write-Host '[OK] Profil PowerShell vérifié' -ForegroundColor Green } else { Write-Host '[ERREUR] Profil non trouvé' -ForegroundColor Red }"

echo.
echo ==================================================
echo [SUCCÈS] Fastfetch est installé et configuré !
echo.
echo Configuration effectuée pour :
echo - CMD (via registre AutoRun)
echo - PowerShell Windows (profil utilisateur)
echo - PowerShell Core 7+ (profil utilisateur)
echo.
echo Pour tester PowerShell : ouvrez une nouvelle fenêtre PowerShell
echo Pour tester CMD : ouvrez une nouvelle fenêtre CMD
echo.
echo Note: Les changements prennent effet dans les nouvelles fenêtres
echo ==================================================
echo.

pause
endlocal
