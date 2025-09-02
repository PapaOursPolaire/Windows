@echo off
setlocal

where winget >nul 2>nul
if %errorlevel% neq 0 (
    echo Winget n'est pas disponible. Ce script nécessite Windows 10/11 avec Winget.
    pause
    exit /b
)

echo Installation de Fastfetch...
winget install fastfetch.fastfetch -h --accept-package-agreements --accept-source-agreements

where fastfetch >nul 2>nul
if %errorlevel% neq 0 (
    echo Fastfetch n'est pas accessible dans le PATH. Vérifie l'installation manuellement.
    pause
    exit /b
)

echo Configuration du registre pour lancer Fastfetch dans chaque CMD...
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d fastfetch /f

echo.
echo Fastfetch est installé et se lancera automatiquement dans chaque fenêtre CMD.
pause
endlocal
