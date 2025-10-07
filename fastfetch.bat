@echo off
setlocal EnableDelayedExpansion

:: Vérification des droits administrateur
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERREUR] Ce script necessite des droits administrateur.
    echo Veuillez executer en tant qu'administrateur.
    pause
    exit /b
)

:: Vérifier si Chocolatey est déjà installé
where choco >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Installation de Chocolatey...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    :: Attente et mise à jour du PATH
    timeout /t 30 /nobreak >nul
    set "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
)

:: Installation de fastfetch
echo [INFO] Installation de fastfetch...
choco install fastfetch -y

:: Vérification de l'installation
where fastfetch >nul 2>&1
if %errorLevel% equ 0 (
    echo [INFO] Configuration de l'autorun...
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Command Processor" /v "AutoRun" /d "fastfetch" /f
    echo [SUCCES] Installation terminée! Fastfetch se lancera automatiquement.
) else (
    echo [ERREUR] Fastfetch non installé.
    echo Tentative avec le chemin complet...
    "%ALLUSERSPROFILE%\chocolatey\bin\fastfetch.exe" --version >nul 2>&1
    if !errorLevel! equ 0 (
        reg add "HKEY_CURRENT_USER\Software\Microsoft\Command Processor" /v "AutoRun" /d "%ALLUSERSPROFILE%\chocolatey\bin\fastfetch.exe" /f
        echo [SUCCES] Installation vérifiée avec chemin complet!
    ) else (
        echo [ERREUR] Échec de l'installation.
        echo Essayez de redémarrer votre terminal et relancer le script.
    )
)

pause