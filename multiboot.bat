@echo off
chcp 65001 >nul
title Préparateur Multiboot Linux - 40+ Distributions
color 0A

echo ═══════════════════════════════════════════════════════════════════════
echo          PRÉPARATEUR MULTIBOOT LINUX - 40+ DISTRIBUTIONS
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo 🐧 Ce script prépare votre disque pour installer plusieurs OS Linux
echo ⚠️  ATTENTION: Sauvegardez vos données importantes avant de continuer!
echo.
pause

:check_admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Privilèges administrateur requis!
    echo    → Clic droit → "Exécuter en tant qu'administrateur"
    pause
    exit /b 1
)

:select_disk
echo.
echo 📀 Disques disponibles:
echo.
echo list disk > temp_cmd.txt
diskpart /s temp_cmd.txt
del temp_cmd.txt
echo.
set /p disk_num="Sélectionnez le disque (numéro): "

:get_disk_info
echo.
echo 📊 Analyse du disque %disk_num%...
(
echo select disk %disk_num%
echo detail disk
) > temp_cmd.txt
diskpart /s temp_cmd.txt > disk_info.txt
del temp_cmd.txt

for /f "tokens=2" %%a in ('findstr /i "Disk ID" disk_info.txt') do set disk_id=%%a
for /f "tokens=3" %%a in ('findstr /i "Free Space" disk_info.txt') do set free_space=%%a

echo.
echo 💾 Informations du disque:
type disk_info.txt | findstr /i "Type\|Status\|Health\|Capacity\|Free"
del disk_info.txt

:get_total_capacity
echo.
(
echo select disk %disk_num%
echo list partition
) > temp_cmd.txt
diskpart /s temp_cmd.txt > partition_info.txt
del temp_cmd.txt

echo.
echo 📋 Partitions actuelles:
type partition_info.txt
echo.
set /p source_partition="Partition à diviser (numéro): "

REM Calcul de la capacité totale approximative
for /f "tokens=3" %%a in ('findstr /i "Primary\|Logical" partition_info.txt') do (
    set partition_size=%%a
    set partition_size=!partition_size:~0,-2!
    set /a total_capacity+=!partition_size!
)
del partition_info.txt

if not defined total_capacity set total_capacity=500000
echo Capacité estimée disponible: %total_capacity% MB

:count_os
echo.
echo 🔢 Combien d'OS Linux voulez-vous installer au total ?
set /p os_count="Nombre d'OS (1-20): "
if %os_count% LSS 1 set os_count=1
if %os_count% GTR 20 set os_count=20

REM Calcul des recommandations selon la capacité
set /a base_size=%total_capacity%/(%os_count%*2)
set /a small_size=%base_size%/3
set /a medium_size=%base_size%*2/3
set /a large_size=%base_size%
set /a huge_size=%base_size%*3/2

:show_linux_list
echo.
echo ═══════════════════════════════════════════════════════════════════════
echo                    🐧 DISTRIBUTIONS LINUX DISPONIBLES
echo ═══════════════════════════════════════════════════════════════════════
echo.
echo 📱 DISTRIBUTIONS DÉBUTANT:
echo  1. Ubuntu LTS           11. Linux Mint Cinnamon  21. Elementary OS
echo  2. Pop!_OS              12. Linux Mint MATE      22. Zorin OS
echo  3. Ubuntu MATE          13. Linux Mint XFCE      23. Peppermint OS
echo  4. Kubuntu              14. Manjaro XFCE         24. MX Linux
echo  5. Xubuntu              15. Manjaro KDE
echo  6. Lubuntu              16. Manjaro GNOME
echo  7. Ubuntu Budgie        17. EndeavourOS
echo  8. Ubuntu Studio        18. Garuda Linux
echo  9. Edubuntu             19. ArcoLinux
echo 10. Ubuntu Unity         20. Artix Linux
echo.
echo ⚙️  DISTRIBUTIONS INTERMÉDIAIRES:
echo 25. Fedora Workstation   31. openSUSE Leap        37. Mageia
echo 26. Fedora KDE           32. openSUSE Tumbleweed  38. PCLinuxOS
echo 27. Fedora XFCE          33. Debian Stable        39. Solus
echo 28. CentOS Stream        34. Debian Testing       40. Void Linux
echo 29. Rocky Linux          35. Kali Linux           41. Alpine Linux
echo 30. AlmaLinux            36. Parrot Security
echo.
echo 🔧 DISTRIBUTIONS AVANCÉES:
echo 42. Arch Linux           46. Gentoo               50. NixOS
echo 43. Artix Linux          47. Calculate Linux      51. GuixSD
echo 44. BlackArch            48. Funtoo               52. CRUX
echo 45. ArchBang             49. Slackware            53. Linux From Scratch
echo.
echo 🎯 DISTRIBUTIONS SPÉCIALISÉES:
echo 54. Kali Linux           58. Pentoo               62. Tails
echo 55. Parrot Security      59. BlackArch            63. Kodachi
echo 56. BackBox              60. CAINE                64. Qubes OS
echo 57. Samurai WTF          61. DEFT
echo.

set selected_os=
set partition_configs=

:select_os_loop
echo.
echo 🎯 SÉLECTION DES OS (%os_count% à choisir):
for /L %%i in (1,1,%os_count%) do (
    echo.
    echo === OS numéro %%i ===
    set /p "os_choice=Choisissez l'OS %%i (1-64): "
    call :get_os_name !os_choice! os_name
    echo Sélectionné: !os_name!
    call :configure_os_partition %%i !os_choice! "!os_name!"
)

:show_configuration_summary
echo.
echo ═══════════════════════════════════════════════════════════════════════
echo                      📋 RÉSUMÉ DE LA CONFIGURATION
echo ═══════════════════════════════════════════════════════════════════════

call :display_all_configs

set /a total_size_mb=0
for /L %%i in (1,1,%os_count%) do (
    if defined partition_size_%%i (
        call set size=%%partition_size_%%i%%
        set /a total_size_mb+=!size!
    )
)

echo.
echo 📊 STATISTIQUES:
echo - Nombre total d'OS: %os_count%
echo - Espace total requis: %total_size_mb% MB (≈ %total_size_mb%/%1024% GB)
echo - Espace disponible estimé: %total_capacity% MB
if %total_size_mb% GTR %total_capacity% (
    echo ⚠️  ATTENTION: Espace insuffisant! Réduisez les tailles.
)

echo.
echo 🔧 DÉTAILS DES PARTITIONS À CRÉER:
call :show_partition_details

:confirm_creation
echo.
echo ⚠️  CONFIRMATION FINALE:
echo ═══════════════════════════════════════════════════════════════════════
echo Disque cible: %disk_num%
echo Partition source: %source_partition%
echo Nombre de nouvelles partitions: %os_count%
echo.
set /p confirm="Procéder au partitionnement? (OUI/non): "
if /i not "%confirm%"=="OUI" (
    echo ❌ Opération annulée par l'utilisateur
    pause
    exit /b 0
)

:create_partitions
echo.
echo 🚀 CRÉATION DES PARTITIONS EN COURS...
echo.

REM Calcul de l'espace à libérer
set /a shrink_size=%total_size_mb%

echo 1️⃣  Réduction de la partition %source_partition% de %shrink_size% MB...
(
echo select disk %disk_num%
echo select partition %source_partition%
echo shrink desired=%shrink_size%
) > temp_cmd.txt
diskpart /s temp_cmd.txt
if %errorLevel% neq 0 (
    echo ❌ Erreur lors de la réduction
    del temp_cmd.txt
    pause
    exit /b 1
)
del temp_cmd.txt

echo ✅ Réduction terminée!

echo.
echo 2️⃣  Création des nouvelles partitions...

for /L %%i in (1,1,%os_count%) do (
    call set size=%%partition_size_%%i%%
    call set name=%%partition_name_%%i%%
    echo Création partition %%i: !name! (!size! MB)
    
    (
    echo select disk %disk_num%
    echo create partition primary size=!size!
    echo assign
    echo format fs=ext4 quick label="!name!"
    ) > temp_cmd.txt
    diskpart /s temp_cmd.txt >nul
    del temp_cmd.txt
    
    echo   ✅ Partition %%i créée
)

echo.
echo 🎉 PARTITIONNEMENT TERMINÉ AVEC SUCCÈS!
echo.

:show_final_results
echo 📋 Nouvelles partitions créées:
(
echo select disk %disk_num%
echo list partition
) > temp_cmd.txt
diskpart /s temp_cmd.txt
del temp_cmd.txt

echo.
echo 🎯 ÉTAPES SUIVANTES:
echo ═══════════════════════════════════════════════════════════════════════
echo 1️⃣  Redémarrez avec le premier OS à installer
echo 2️⃣  Installez les OS dans l'ordre de votre choix
echo 3️⃣  Le dernier OS installé configurera automatiquement GRUB
echo 4️⃣  Utilisez 'update-grub' après chaque nouvelle installation
echo.
echo 💡 CONSEILS:
echo - Gardez ce script et ses résultats pour référence
echo - Notez les numéros de partitions pour chaque OS
echo - Installez Ubuntu/Debian en dernier pour un meilleur GRUB
echo - Sauvegardez la table de partition: 'sudo sfdisk -d /dev/sdX > backup.txt'
echo.

pause
exit /b 0

:get_os_name
set choice=%1
if "%choice%"=="1" set "%2=Ubuntu LTS"
if "%choice%"=="2" set "%2=Pop!_OS"
if "%choice%"=="3" set "%2=Ubuntu MATE"
if "%choice%"=="4" set "%2=Kubuntu"
if "%choice%"=="5" set "%2=Xubuntu"
if "%choice%"=="6" set "%2=Lubuntu"
if "%choice%"=="7" set "%2=Ubuntu Budgie"
if "%choice%"=="8" set "%2=Ubuntu Studio"
if "%choice%"=="9" set "%2=Edubuntu"
if "%choice%"=="10" set "%2=Ubuntu Unity"
if "%choice%"=="11" set "%2=Linux Mint Cinnamon"
if "%choice%"=="12" set "%2=Linux Mint MATE"
if "%choice%"=="13" set "%2=Linux Mint XFCE"
if "%choice%"=="14" set "%2=Manjaro XFCE"
if "%choice%"=="15" set "%2=Manjaro KDE"
if "%choice%"=="16" set "%2=Manjaro GNOME"
if "%choice%"=="17" set "%2=EndeavourOS"
if "%choice%"=="18" set "%2=Garuda Linux"
if "%choice%"=="19" set "%2=ArcoLinux"
if "%choice%"=="20" set "%2=Artix Linux"
if "%choice%"=="21" set "%2=Elementary OS"
if "%choice%"=="22" set "%2=Zorin OS"
if "%choice%"=="23" set "%2=Peppermint OS"
if "%choice%"=="24" set "%2=MX Linux"
if "%choice%"=="25" set "%2=Fedora Workstation"
if "%choice%"=="26" set "%2=Fedora KDE"
if "%choice%"=="27" set "%2=Fedora XFCE"
if "%choice%"=="28" set "%2=CentOS Stream"
if "%choice%"=="29" set "%2=Rocky Linux"
if "%choice%"=="30" set "%2=AlmaLinux"
if "%choice%"=="31" set "%2=openSUSE Leap"
if "%choice%"=="32" set "%2=openSUSE Tumbleweed"
if "%choice%"=="33" set "%2=Debian Stable"
if "%choice%"=="34" set "%2=Debian Testing"
if "%choice%"=="35" set "%2=Kali Linux"
if "%choice%"=="36" set "%2=Parrot Security"
if "%choice%"=="37" set "%2=Mageia"
if "%choice%"=="38" set "%2=PCLinuxOS"
if "%choice%"=="39" set "%2=Solus"
if "%choice%"=="40" set "%2=Void Linux"
if "%choice%"=="41" set "%2=Alpine Linux"
if "%choice%"=="42" set "%2=Arch Linux"
if "%choice%"=="43" set "%2=Artix Linux"
if "%choice%"=="44" set "%2=BlackArch"
if "%choice%"=="45" set "%2=ArchBang"
if "%choice%"=="46" set "%2=Gentoo"
if "%choice%"=="47" set "%2=Calculate Linux"
if "%choice%"=="48" set "%2=Funtoo"
if "%choice%"=="49" set "%2=Slackware"
if "%choice%"=="50" set "%2=NixOS"
if "%choice%"=="51" set "%2=GuixSD"
if "%choice%"=="52" set "%2=CRUX"
if "%choice%"=="53" set "%2=Linux From Scratch"
if "%choice%"=="54" set "%2=Kali Linux Security"
if "%choice%"=="55" set "%2=Parrot Security OS"
if "%choice%"=="56" set "%2=BackBox"
if "%choice%"=="57" set "%2=Samurai WTF"
if "%choice%"=="58" set "%2=Pentoo"
if "%choice%"=="59" set "%2=BlackArch Security"
if "%choice%"=="60" set "%2=CAINE"
if "%choice%"=="61" set "%2=DEFT"
if "%choice%"=="62" set "%2=Tails"
if "%choice%"=="63" set "%2=Kodachi"
if "%choice%"=="64" set "%2=Qubes OS"
goto :eof

:configure_os_partition
set slot=%1
set choice=%2
set os_name=%3

REM Définition des tailles recommandées selon le type d'OS
set recommended_size=%medium_size%

REM Ajustements selon l'OS spécifique
if %choice% LEQ 24 set recommended_size=%medium_size%
if %choice% GEQ 25 if %choice% LEQ 41 set recommended_size=%large_size%
if %choice% GEQ 42 if %choice% LEQ 53 set recommended_size=%huge_size%
if %choice% GEQ 54 set recommended_size=%large_size%

REM Ajustements spéciaux
if "%choice%"=="8" set recommended_size=%huge_size%
if "%choice%"=="35" set recommended_size=%huge_size%
if "%choice%"=="36" set recommended_size=%huge_size%
if "%choice%"=="44" set recommended_size=%huge_size%
if "%choice%"=="64" set recommended_size=%huge_size%

echo Taille recommandée pour %os_name%: %recommended_size% MB
set /p "partition_size=Taille désirée en MB (recommandé: %recommended_size%): "
if "%partition_size%"=="" set partition_size=%recommended_size%

set partition_size_%slot%=%partition_size%
set partition_name_%slot%=%os_name%
goto :eof

:display_all_configs
for /L %%i in (1,1,%os_count%) do (
    call set name=%%partition_name_%%i%%
    call set size=%%partition_size_%%i%%
    echo %%i. !name! - !size! MB
)
goto :eof

:show_partition_details
echo.
for /L %%i in (1,1,%os_count%) do (
    call set name=%%partition_name_%%i%%
    call set size=%%partition_size_%%i%%
    echo Partition %%i: !name!
    echo   - Taille: !size! MB
    echo   - Format: ext4 (modifiable lors de l'installation)
    echo   - Label: !name!
    echo.
)
goto :eof