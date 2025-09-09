@echo off
title Installation Spotify & Spicetify
echo === Début de l'installation ===

echo [1/3] Téléchargement de Spotify...
powershell -Command "Start-Process 'https://download.scdn.co/SpotifySetup.exe'"

echo Veuillez installer Spotify manuellement si ce n'est pas déjà fait.
pause

echo [2/3] Installation de Spicetify...
powershell -Command "iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex"

echo [3/3] Activation du Marketplace...
powershell -Command "Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1' | Invoke-Expression"

echo Ouverture de PowerShell pour configuration finale...
start powershell

echo Installation terminée
pause
exit
