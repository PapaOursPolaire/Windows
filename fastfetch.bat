@echo off
setlocal EnableDelayedExpansion

:: Vérification des droits administrateur (non requis pour scoop)
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ATTENTION] Les droits administrateur ne sont pas obligatoires pour scoop.
    echo.
)

:: Vérifier si scoop est déjà installé
where scoop >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] Installation de Scoop...
    echo.
    echo Scoop sera installe dans: %USERPROFILE%\scoop
    echo.
    
    :: Installation de scoop sans droits admin
    powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    powershell -Command "irm get.scoop.sh | iex"
    
    :: Mise à jour du PATH
    set "PATH=%PATH%;%USERPROFILE%\scoop\shims"
    
    timeout /t 10 /nobreak >nul
)

:: Installation de fastfetch
echo [INFO] Installation de fastfetch...
scoop install fastfetch

:: Vérification de l'installation
where fastfetch >nul 2>&1
if %errorLevel% equ 0 (
    echo [INFO] Configuration de l'autorun...
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Command Processor" /v "AutoRun" /d "fastfetch" /f
    echo [SUCCES] Installation terminée! Fastfetch se lancera automatiquement.
) else (
    echo [ERREUR] Fastfetch non installé.
    echo Essayez d'installer manuellement avec: scoop install fastfetch
)

pause
