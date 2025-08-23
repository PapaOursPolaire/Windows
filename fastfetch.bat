@echo off
setlocal ENABLEDELAYEDEXPANSION

echo === [Fastfetch Setup - CMD Edition] ===

REM Définir le dossier d'installation
set "FF_DIR=%USERPROFILE%\fastfetch"
if not exist "%FF_DIR%" mkdir "%FF_DIR%"

REM Indiquer à l'utilisateur de télécharger Fastfetch manuellement
echo.
echo ❗ Etape 1 : Télécharger Fastfetch manuellement
echo ► Ouvre ce lien dans ton navigateur :
echo   https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch_windows.exe
echo ► Enregistre-le sous :
echo   %FF_DIR%\fastfetch.exe
echo.
pause

REM Vérifier si l'exécutable est présent
if not exist "%FF_DIR%\fastfetch.exe" (
    echo ❌ Erreur : fastfetch.exe est introuvable dans %FF_DIR%
    echo Télécharge-le d'abord, puis relance ce script.
    pause
    exit /b
)

REM Générer la config si elle n'existe pas
if not exist "%APPDATA%\fastfetch\config.json" (
    "%FF_DIR%\fastfetch.exe" --gen-config
)

REM Copier le logo personnalisé
if exist logo.txt (
    copy /Y logo.txt "%FF_DIR%\logo.txt"
) else (
    echo ⚠️  Aucun logo.txt détecté. Le logo Windows par défaut sera utilisé.
)

REM Modifier le fichier config.json manuellement
REM (On n'utilise pas powershell, donc on ne modifie pas dynamiquement le JSON)

echo.
echo ❗ Etape 2 : Modifier config.json pour utiliser le logo personnalisé
echo ► Ouvre ce fichier avec Notepad :
echo   %APPDATA%\fastfetch\config.json
echo ► Remplace :
echo   "logo": "windows"
echo     par
echo   "logo": "ascii",
echo   "ascii_logo_path": "%FF_DIR:\\=\\%\\logo.txt"
echo.
pause

REM Ajouter l'exécution automatique à CMD via Regedit
echo.
echo ❗ Etape 3 : Activer le lancement automatique dans CMD
echo ► Appuie sur Windows + R puis tape : regedit
echo ► Va ici :
echo   HKEY_CURRENT_USER\Software\Microsoft\Command Processor
echo ► Clique droit > Nouveau > Valeur chaîne
echo ► Nom : AutoRun
echo ► Donne-lui comme valeur :
echo   "%FF_DIR%\fastfetch.exe"
echo.
pause

echo ✅ Fastfetch est installé et prêt à l’emploi.
echo Il s’exécutera automatiquement à chaque ouverture de CMD (une fois le registre modifié).
endlocal
pause
