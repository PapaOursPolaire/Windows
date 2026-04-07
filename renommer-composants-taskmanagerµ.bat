@echo off
title Papa Ours Hardware Spoofer 🐻
color 0A

echo ============================
echo   APPLYING PAPA OURS MOD
echo ============================

:: Attendre que Windows charge
timeout /t 15 >nul

:: ================= CPU =================
reg add "HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0" ^
/v ProcessorNameString /t REG_SZ /d "Papa Ours CPU 🐻" /f

:: ================= RAM / SYSTEM =================
reg add "HKLM\HARDWARE\DESCRIPTION\System\BIOS" ^
/v SystemProductName /t REG_SZ /d "Papa Ours Beast Machine" /f

reg add "HKLM\HARDWARE\DESCRIPTION\System\BIOS" ^
/v SystemManufacturer /t REG_SZ /d "Papa Ours Industries 🐻" /f

:: ================= GPU =================
:: ⚠️ REMPLACE {TON-GPU-ID} !!!
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Video\{TON-GPU-ID}\0000" ^
/v DriverDesc /t REG_SZ /d "Papa Ours GPU 🔥" /f

:: ================= STORAGE =================
reg add "HKLM\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0" ^
/v Identifier /t REG_SZ /d "Papa Ours SSD ⚡" /f

echo.
echo DONE 🐻
timeout /t 3
exit