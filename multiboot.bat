@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

# NE PAS OUBLIER QUE LE BATCH NE GERE PAS LES CARACTERES SPECIAUX

# Configure l'affichage en vert sur noir
color 0A

echo.
echo    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ██╗      ██████╗  ██████╗ ██╗ ██████╗██╗███████╗██╗     ███████╗
echo    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██║     ██╔═══██╗██╔════╝ ██║██╔════╝██║██╔════╝██║     ██╔════╝
echo    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║    ██║     ██║   ██║██║  ███╗██║██║     ██║█████╗  ██║     ███████╗
echo    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ██║     ██║   ██║██║   ██║██║██║     ██║██╔══╝  ██║     ╚════██║
echo    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ███████╗╚██████╔╝╚██████╔╝██║╚██████╗██║███████╗███████╗███████║
echo    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝╚═╝╚══════╝╚══════╝╚══════╝
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERREUR] Ce script necessite des droits administrateur.
    echo    Faites un clic droit sur le fichier et "Executer en tant qu'administrateur"
    pause
    exit /b
)

echo [OK] Droits administrateur detectes
echo.

# WIngeet est dispo directement sur Windows 11 ?
echo [INFO] Verification de Winget...
winget --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ATTENTION] Winget non detecte. Installation automatique en cours...
    echo    Telechargement depuis GitHub...
    
    # Telecharge et installe Winget avec ses dependances via PowerShell
    powershell -Command "& {
        $progressPreference = 'silentlyContinue'
        $latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith('.msixbundle')}
        $latestWingetMsixBundle = $latestWingetMsixBundleUri.Split('/')[-1]
        Write-Information 'Telechargement du dernier package Microsoft.VCLibs.x64.14.00.Desktop...'
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
        Write-Information 'Telechargement du dernier package Microsoft.UI.Xaml.2.8...'  
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
        Write-Information 'Telechargement du dernier Winget...'
        Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile $latestWingetMsixBundle
        Write-Information 'Installation des dependances...'
        Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
        Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
        Write-Information 'Installation de Winget...'
        Add-AppxPackage $latestWingetMsixBundle
        Write-Information 'Nettoyage des fichiers temporaires...'
        Remove-Item Microsoft.VCLibs.x64.14.00.Desktop.appx
        Remove-Item Microsoft.UI.Xaml.2.8.x64.appx 
        Remove-Item $latestWingetMsixBundle
    }"
    
    # Verifie que Winget s'est bien installé
    timeout /t 5 /nobreak >nul
    winget --version >nul 2>&1
    if %errorLevel% neq 0 (
        echo [ERREUR] Echec de l'installation automatique de Winget.
        echo    Installation manuelle requise depuis : https://aka.ms/getwinget
        pause
        exit /b
    ) else (
        echo [OK] Winget installe avec succes !
    )
) else (
    echo [OK] Winget est disponible
)

# Installe Chocolatey s'il n'est pas deja present
echo.
echo [INFO] Installation de Chocolatey...
powershell -Command "if (!(Get-Command choco -ErrorAction SilentlyContinue)) { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) }"
echo [OK] Chocolatey pret

echo.
echo                      DEBUT DE L'INSTALLATION

echo.
echo Outils et applications pour developpeurs, creatifs et usage quotidien

# Outils de controle de version
set /p install_git="Installer Git ? (o/N): "
if /i "!install_git!"=="o" (
    echo Installation de Git...
    winget install --id Git.Git -e --silent
)

set /p install_lazygit="Installer Lazygit ? (o/N): "
if /i "!install_lazygit!"=="o" (
    echo Installation de Lazygit...
    winget install --id JesseDuffield.lazygit -e --silent
)

# Docker pour la conteneurisation
set /p install_docker="Installer Docker Desktop ? (o/N): "
if /i "!install_docker!"=="o" (
    echo Installation de Docker Desktop...
    winget install --id Docker.DockerDesktop -e --silent
)

# Editeurs de code et IDE
set /p install_vscode="Installer Visual Studio Code ? (o/N): "
if /i "!install_vscode!"=="o" (
    echo Installation de VS Code...
    winget install --id Microsoft.VisualStudioCode -e --silent
)

set /p install_vscodium="Installer VSCodium ? (o/N): "
if /i "!install_vscodium!"=="o" (
    echo Installation de VSCodium...
    winget install --id VSCodium.VSCodium -e --silent
)

set /p install_neovim="Installer Neovim ? (o/N): "
if /i "!install_neovim!"=="o" (
    echo Installation de Neovim...
    winget install --id Neovim.Neovim -e --silent
)

# Terminaux avances
set /p install_terminal="Installer Windows Terminal ? (o/N): "
if /i "!install_terminal!"=="o" (
    echo Installation de Windows Terminal...
    winget install --id Microsoft.WindowsTerminal -e --silent
)

set /p install_alacritty="Installer Alacritty ? (o/N): "
if /i "!install_alacritty!"=="o" (
    echo Installation d'Alacritty...
    winget install --id Alacritty.Alacritty -e --silent
)

# Langages de programmation et leurs outils
set /p install_nodejs="Installer Node.js ? (o/N): "
if /i "!install_nodejs!"=="o" (
    echo Installation de Node.js...
    winget install --id OpenJS.NodeJS -e --silent
)

set /p install_python="Installer Python ? (o/N): "
if /i "!install_python!"=="o" (
    echo Installation de Python...
    winget install --id Python.Python.3.12 -e --silent
)

set /p install_go="Installer Go ? (o/N): "
if /i "!install_go!"=="o" (
    echo Installation de Go...
    winget install --id GoLang.Go -e --silent
)

set /p install_rust="Installer Rust ? (o/N): "
if /i "!install_rust!"=="o" (
    echo Installation de Rust...
    winget install --id Rustlang.Rustup -e --silent
)

set /p install_java="Installer OpenJDK ? (o/N): "
if /i "!install_java!"=="o" (
    echo Installation d'OpenJDK...
    winget install --id Microsoft.OpenJDK.17 -e --silent
)

set /p install_dotnet="Installer .NET SDK ? (o/N): "
if /i "!install_dotnet!"=="o" (
    echo Installation du .NET SDK...
    winget install --id Microsoft.DotNet.SDK.8 -e --silent
)

# Clients pour tester les API
set /p install_postman="Installer Postman ? (o/N): "
if /i "!install_postman!"=="o" (
    echo Installation de Postman...
    winget install --id Postman.Postman -e --silent
)

# Outils de gestion de bases de donnees
set /p install_dbeaver="Installer DBeaver ? (o/N): "
if /i "!install_dbeaver!"=="o" (
    echo Installation de DBeaver...
    winget install --id dbeaver.dbeaver -e --silent
)

set /p install_mysql="Installer MySQL Workbench ? (o/N): "
if /i "!install_mysql!"=="o" (
    echo Installation de MySQL Workbench...
    winget install --id Oracle.MySQLWorkbench -e --silent
)
    
echo.
echo Editeurs de texte et outils de prise de notes

set /p install_obsidian="Installer Obsidian ? (o/N): "
if /i "!install_obsidian!"=="o" (
    echo Installation d'Obsidian...
    winget install --id Obsidian.Obsidian -e --silent
)

set /p install_joplin="Installer Joplin ? (o/N): "
if /i "!install_joplin!"=="o" (
    echo Installation de Joplin...
    winget install --id Joplin.Joplin -e --silent
)

echo.
echo Bureautique et utilitaires systeme

set /p install_powertoys="Installer PowerToys ? (o/N): "
if /i "!install_powertoys!"=="o" (
    echo Installation de PowerToys...
    winget install --id Microsoft.PowerToys -e --silent
)

set /p install_ccleaner="Installer CCleaner ? (o/N): "
if /i "!install_ccleaner!"=="o" (
    echo Installation de CCleaner...
    winget install --id Piriform.CCleaner -e --silent
)

set /p install_7zip="Installer 7-Zip ? (o/N): "
if /i "!install_7zip!"=="o" (
    echo Installation de 7-Zip...
    winget install --id 7zip.7zip -e --silent
)

echo.
echo Internet et communication

# Navigateurs web alternatifs
set /p install_firefox="Installer Firefox ? (o/N): "
if /i "!install_firefox!"=="o" (
    echo Installation de Firefox...
    winget install --id Mozilla.Firefox -e --silent
)

set /p install_brave="Installer Brave Browser ? (o/N): "
if /i "!install_brave!"=="o" (
    echo Installation de Brave...
    winget install --id Brave.Brave -e --silent
)

set /p install_chrome="Installer Google Chrome ? (o/N): "
if /i "!install_chrome!"=="o" (
    echo Installation de Google Chrome...
    winget install --id Google.Chrome -e --silent
)

# Applications de messagerie et communication
set /p install_discord="Installer Discord ? (o/N): "
if /i "!install_discord!"=="o" (
    echo Installation de Discord...
    winget install --id Discord.Discord -e --silent
)

set /p install_signal="Installer Signal ? (o/N): "
if /i "!install_signal!"=="o" (
    echo Installation de Signal...
    winget install --id OpenWhisperSystems.Signal -e --silent
)

set /p install_telegram="Installer Telegram ? (o/N): "
if /i "!install_telegram!"=="o" (
    echo Installation de Telegram...
    winget install --id Telegram.TelegramDesktop -e --silent
)

set /p install_thunderbird="Installer Thunderbird ? (o/N): "
if /i "!install_thunderbird!"=="o" (
    echo Installation de Thunderbird...
    winget install --id Mozilla.Thunderbird -e --silent
)

set /p install_slack="Installer Slack ? (o/N): "
if /i "!install_slack!"=="o" (
    echo Installation de Slack...
    winget install --id SlackTechnologies.Slack -e --silent
)

echo.
echo MULTIMEDIA : Lecture, edition audio/video et streaming
# Lecteurs multimedia
set /p install_vlc="Installer VLC Media Player ? (o/N): "
if /i "!install_vlc!"=="o" (
    echo Installation de VLC...
    winget install --id VideoLAN.VLC -e --silent
)

set /p install_mpv="Installer MPV ? (o/N): "
if /i "!install_mpv!"=="o" (
    echo Installation de MPV...
    winget install --id shinchiro.mpv -e --silent
)

# Outils d'edition audio et video
set /p install_obs="Installer OBS Studio ? (o/N): "
if /i "!install_obs!"=="o" (
    echo Installation d'OBS Studio...
    winget install --id OBSProject.OBSStudio -e --silent
)

set /p install_audacity="Installer Audacity ? (o/N): "
if /i "!install_audacity!"=="o" (
    echo Installation d'Audacity...
    winget install --id Audacity.Audacity -e --silent
)

set /p install_kdenlive="Installer Kdenlive ? (o/N): "
if /i "!install_kdenlive!"=="o" (
    echo Installation de Kdenlive...
    winget install --id KDE.Kdenlive -e --silent
)

echo.
echo DESIGN ET IMAGE : Creation graphique, retouche photo et modelisation 3D

set /p install_gimp="Installer GIMP ? (o/N): "
if /i "!install_gimp!"=="o" (
    echo Installation de GIMP...
    winget install --id GIMP.GIMP -e --silent
)

set /p install_krita="Installer Krita ? (o/N): "
if /i "!install_krita!"=="o" (
    echo Installation de Krita...
    winget install --id KDE.Krita -e --silent
)

set /p install_inkscape="Installer Inkscape ? (o/N): "
if /i "!install_inkscape!"=="o" (
    echo Installation d'Inkscape...
    winget install --id Inkscape.Inkscape -e --silent
)

set /p install_blender="Installer Blender ? (o/N): "
if /i "!install_blender!"=="o" (
    echo Installation de Blender...
    winget install --id BlenderFoundation.Blender -e --silent
)

# GAMING - Plateformes de jeux et outils gaming
echo.
echo === GAMING ===

set /p install_steam="Installer Steam ? (o/N): "
if /i "!install_steam!"=="o" (
    echo Installation de Steam...
    winget install --id Valve.Steam -e --silent
)

set /p install_heroic="Installer Heroic Games Launcher ? (o/N): "
if /i "!install_heroic!"=="o" (
    echo Installation d'Heroic Games Launcher...
    winget install --id HeroicGamesLauncher.HeroicGamesLauncher -e --silent
)

echo.
echo SECURITE : Gestionnaires de mots de passe et outils de securite

set /p install_keepass="Installer KeePassXC ? (o/N): "
if /i "!install_keepass!"=="o" (
    echo Installation de KeePassXC...
    winget install --id KeePassXCTeam.KeePassXC -e --silent
)

set /p install_bitwarden="Installer Bitwarden ? (o/N): "
if /i "!install_bitwarden!"=="o" (
    echo Installation de Bitwarden...
    winget install --id Bitwarden.Bitwarden -e --silent
)

echo.
echo AUTRES OUTILS - Utilitaires divers et outils systeme

set /p install_etcher="Installer Balena Etcher ? (o/N): "
if /i "!install_etcher!"=="o" (
    echo Installation de Balena Etcher...
    winget install --id Balena.BalenaEtcher -e --silent
)

set /p install_virtualbox="Installer VirtualBox ? (o/N): "
if /i "!install_virtualbox!"=="o" (
    echo Installation de VirtualBox...
    winget install --id Oracle.VirtualBox -e --silent
)

set /p install_rufus="Installer Rufus ? (o/N): "
if /i "!install_rufus!"=="o" (
    echo Installation de Rufus...
    winget install --id Rufus.Rufus -e --silent
)

echo.
echo OUTILS IA - Applications d'intelligence artificielle et modeles de langage
set /p install_gpt4all="Installer GPT4All ? (o/N): "
if /i "!install_gpt4all!"=="o" (
    echo Installation de GPT4All...
    choco install gpt4all -y
)

set /p install_lmstudio="Installer LM Studio ? (o/N): "
if /i "!install_lmstudio!"=="o" (
    echo Installation de LM Studio...
    winget install --id LMStudio.LMStudio -e --silent
)

echo.
echo EXTENSIONS VS CODE - Installe les extensions les plus utiles pour le dev

where code >nul 2>&1
if %errorLevel% equ 0 (
    set /p install_vscode_ext="Installer les extensions VS Code recommandees ? (o/N): "
    if /i "!install_vscode_ext!"=="o" (
        echo Installation des extensions VS Code...
        code --install-extension ms-python.python --force
        code --install-extension ms-vscode.vscode-typescript-next --force
        code --install-extension bradlc.vscode-tailwindcss --force
        code --install-extension esbenp.prettier-vscode --force
        code --install-extension ms-vscode.vscode-json --force
        code --install-extension humao.rest-client --force
        code --install-extension rangav.vscode-thunder-client --force
        code --install-extension ms-vscode-remote.remote-wsl --force
        code --install-extension GitHub.copilot --force
        code --install-extension ms-vscode.powershell --force
        echo [OK] Extensions VS Code installees
    )
)

echo.
echo Configuration systeme et finalisation

# Configure Git avec nom et email utilisateur
where git >nul 2>&1
if %errorLevel% equ 0 (
    set /p config_git="Configurer Git ? (o/N): "
    if /i "!config_git!"=="o" (
        set /p git_name="Nom d'utilisateur Git: "
        set /p git_email="Email Git: "
        git config --global user.name "!git_name!"
        git config --global user.email "!git_email!"
        git config --global init.defaultBranch main
        echo [OK] Git configure
    )
)

# Lance les mises a jour Windows via PowerShell
set /p update_system="Effectuer une mise a jour Windows ? (o/N): "
if /i "!update_system!"=="o" (
    echo Mise a jour du systeme...
    powershell -Command "Install-Module PSWindowsUpdate -Force; Get-WUInstall -AcceptAll"
)

# FINALISATION - Affiche le resume et propose le redemarrage
echo.
echo                        INSTALLATION TERMINEE
echo.
echo [OK] L'installation des logiciels selectionnes est terminee !
echo.
echo [INFO] Prochaines etapes recommandees :
echo    1. Redemarrer l'ordinateur (optionnel mais conseille)
echo    2. Configurer vos comptes utilisateur dans les applications
echo    3. Personnaliser les parametres selon vos preferences
echo.
echo [CONSEIL] Conseils :
echo    - Verifiez les mises a jour dans chaque application
echo    - Configurez la synchronisation de vos donnees
echo    - Explorez les plugins et extensions disponibles
echo.
set /p restart_now="Redemarrer maintenant ? (o/N): "
if /i "!restart_now!"=="o" (
    echo Redemarrage dans 10 secondes...
    timeout /t 10
    shutdown /r /t 0
)

echo.
echo Merci d'avoir utilise ce script d'installation !
pause
exit /b
