@echo off
title Installation Spotify & Spicetify
echo      Installation automatique
echo   Spotify + Spicetify + Marketplace
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Ce script doit etre lance en tant qu'administrateur.
    pause
    exit /b
)

echo [1/3] Téléchargement et installation de Spotify...
powershell -NoLogo -NoProfile -Command ^
    "$spotifyInstaller = '$env:TEMP\SpotifySetup.exe';" ^
    "Invoke-WebRequest 'https://download.scdn.co/SpotifySetup.exe' -OutFile $spotifyInstaller;" ^
    "Start-Process $spotifyInstaller -ArgumentList '/silent' -Wait"

echo Spotify installe avec succes.
echo.

echo [2/3] Installation de Spicetify...
powershell -NoLogo -NoProfile -Command ^
    "iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex"

echo Spicetify installe avec succes.
echo.

echo [3/3] Installation du Marketplace...
powershell -NoLogo -NoProfile -Command ^
    "iwr -useb https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1 | iex"

echo Marketplace installe avec succes.
echo.

echo Configuration finale de Spicetify...
powershell -NoLogo -NoProfile -Command ^
    "spicetify backup apply enable-devtools"

echo   Installation terminee !
echo   Lance Spotify pour voir les changements.
pause
exit
