@echo off
setlocal enabledelayedexpansion
title SCRCPY Wireless Launcher
color 0A

:: Set color codes for Windows 10/11
set "CYAN=[36m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "MAGENTA=[35m"
set "GRAY=[37m"
set "RESET=[0m"

echo.
echo %CYAN%==================================================================%RESET%
echo %CYAN%                                                                %RESET%
echo %GREEN%                    SCRCPY WIRELESS LAUNCHER                  %RESET%
echo %YELLOW%                        Version 1.0.0                         %RESET%
echo %CYAN%                                                                %RESET%
echo %MAGENTA%                    Author: netphantom.og                     %RESET%
echo %CYAN%                                                                %RESET%
echo %CYAN%==================================================================%RESET%
echo.

:: Resolve base directory and scrcpy tool directory relative to this script
set "baseDir=%~dp0"
set "scrcpyDir=%baseDir%scrcpy"

:: Check required files
set "adbPath=%scrcpyDir%\adb.exe"
set "scrcpyPath=%scrcpyDir%\scrcpy.exe"

if not exist "%adbPath%" (
    echo %RED%[ERROR] Missing file: adb.exe%RESET%
    echo %YELLOW%Expected at: %adbPath%%RESET%
    echo.
    echo %CYAN%[SOLUTION] You need to download official scrcpy binaries:%RESET%
    
    :: Detect system architecture
    if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
        echo %GRAY%1. Download (64-bit): https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-win64-v2.4.0.zip%RESET%
    ) else (
        echo %GRAY%1. Download (32-bit): https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-win32-v2.4.0.zip%RESET%
    )
    
    echo %GRAY%2. Extract and copy all files to the 'scrcpy' folder%RESET%
    echo %GRAY%3. See README.md for detailed instructions%RESET%
    echo.
    pause
    exit /b 1
)

if not exist "%scrcpyPath%" (
    echo %RED%[ERROR] Missing file: scrcpy.exe%RESET%
    echo %YELLOW%Expected at: %scrcpyPath%%RESET%
    echo.
    echo %CYAN%[SOLUTION] You need to download official scrcpy binaries:%RESET%
    
    :: Detect system architecture
    if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
        echo %GRAY%1. Download (64-bit): https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-win64-v2.4.0.zip%RESET%
    ) else (
        echo %GRAY%1. Download (32-bit): https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-win32-v2.4.0.zip%RESET%
    )
    
    echo %GRAY%2. Extract and copy all files to the 'scrcpy' folder%RESET%
    echo %GRAY%3. See README.md for detailed instructions%RESET%
    echo.
    pause
    exit /b 1
)

:: Create Desktop shortcut if missing
echo %CYAN%[INFO] Checking for desktop shortcut...%RESET%
set "shortcutName=SCRCPY Wireless Launcher.lnk"
set "userDesktop=%USERPROFILE%\Desktop"
set "shortcutPath=%userDesktop%\%shortcutName%"

if not exist "%shortcutPath%" (
    echo %CYAN%[INFO] Creating desktop shortcut...%RESET%
    powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $sc = $wsh.CreateShortcut('%shortcutPath%'); $sc.TargetPath = 'cmd.exe'; $sc.Arguments = '/k \"cd /d \"%baseDir%\" ^& \"%baseDir%Run-ScrcpyWireless.bat\"\"'; $sc.WorkingDirectory = '%baseDir%'; $iconPath = '%baseDir%scrcpy.ico'; if (Test-Path $iconPath) { $sc.IconLocation = $iconPath }; $sc.Save()" 2>nul
)

:: Initialize adb server (do not kill to preserve existing wireless sessions)
echo %CYAN%[INFO] Starting ADB server...%RESET%
"%adbPath%" start-server >nul 2>&1

:: Detect existing TCP/IP device first (reconnect without USB)
echo %CYAN%[INFO] Checking for existing wireless connections...%RESET%
"%adbPath%" devices > "%temp%\adb_devices.txt" 2>&1
set "serial="
set "foundWireless="
set "readyToLaunch="

for /f "tokens=1,2" %%a in ('"%adbPath%" devices ^| findstr /r ".*:5555.*device"') do (
    set "serial=%%a"
    set "foundWireless=1"
    echo %GREEN%[INFO] Using existing wireless device %%a%RESET%
    "%adbPath%" connect %%a >nul 2>&1
    timeout /t 2 /nobreak >nul
    
    :: Verify connection is still active
    "%adbPath%" devices > "%temp%\adb_devices_check.txt" 2>&1
    findstr /r "%%a.*device" "%temp%\adb_devices_check.txt" >nul
    if not errorlevel 1 (
        echo %GREEN%[SUCCESS] Wireless connection verified%RESET%
        set "readyToLaunch=1"
        goto :launch_scrcpy
    ) else (
        echo %YELLOW%[WARNING] Existing wireless connection is inactive, will re-establish%RESET%
        set "foundWireless="
        set "serial="
        set "readyToLaunch="
    )
)

:: If no TCP/IP serial, try USB path
if not defined foundWireless (
    echo %CYAN%[INFO] Checking for USB devices...%RESET%
    for /f "tokens=1,2" %%a in ('"%adbPath%" devices ^| findstr /r ".*device$"') do (
        set "serial=%%a"
        echo %GREEN%[INFO] USB device detected: %%a%RESET%
        goto :enable_wireless
    )
)

:: No devices found
echo %YELLOW%[WARNING] No device detected over USB or wireless.%RESET%
echo %GRAY%➡ If you used this before, just ensure the phone stayed on the same WiFi and try again.%RESET%
echo %GRAY%➡ Otherwise, connect via USB once to initialize wireless mode.%RESET%
echo %GRAY%➡ Make sure USB Debugging is enabled on your phone.%RESET%
pause
exit /b 1

:enable_wireless
:: Enable TCP/IP mode on port 5555
echo %CYAN%[INFO] Enabling TCP/IP mode (port 5555)...%RESET%
"%adbPath%" tcpip 5555 >nul 2>&1
echo %YELLOW%[INFO] Device switching to TCP/IP mode...%RESET%
timeout /t 3 /nobreak >nul

:: Get device IP using improved strategies
echo %CYAN%[INFO] Detecting phone IP address...%RESET%
set "ip="

:: Method 1: Try Android properties first (most reliable)
echo %CYAN%[INFO] Trying Android properties method...%RESET%
for %%p in (dhcp.wlan0.ipaddress dhcp.eth0.ipaddress dhcp.wlan1.ipaddress) do (
    if not defined ip (
        for /f %%a in ('"%adbPath%" shell getprop %%p 2^>nul') do (
            echo %%a | findstr /r "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul && (
                set "ip=%%a"
                echo %GREEN%[INFO] IP found via property %%p: %%a%RESET%
                goto :found_ip
            )
        )
    )
)

:: Method 2: Try different network interfaces
if not defined ip (
    echo %CYAN%[INFO] Trying network interface method...%RESET%
    for %%i in (wlan0 eth0 wlan1 rmnet_data0) do (
        if not defined ip (
            for /f "tokens=2 delims= " %%a in ('"%adbPath%" shell ip -f inet addr show %%i 2^>nul ^| findstr /r "inet [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (
                set "ip=%%a"
                echo %GREEN%[INFO] IP found via interface %%i: %%a%RESET%
                goto :found_ip
            )
        )
    )
)

:: Method 3: Try route-based detection
if not defined ip (
    echo %CYAN%[INFO] Trying route-based method...%RESET%
    for /f "tokens=2 delims= " %%a in ('"%adbPath%" shell ip route 2^>nul ^| findstr /r "src [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (
        set "ip=%%a"
        echo %GREEN%[INFO] IP found via route: %%a%RESET%
        goto :found_ip
    )
)

:: Method 4: Try compact addr list
if not defined ip (
    echo %CYAN%[INFO] Trying compact address method...%RESET%
    for /f "tokens=3 delims= " %%a in ('"%adbPath%" shell ip -o -4 addr show 2^>nul ^| findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (
        set "ip=%%a"
        set "ip=!ip:/=!"
        echo %GREEN%[INFO] IP found via compact method: %%a%RESET%
        goto :found_ip
    )
)

:: Method 5: Try to ping common network ranges
if not defined ip (
    echo %CYAN%[INFO] Trying network discovery method...%RESET%
    for /f "tokens=2 delims= " %%a in ('"%adbPath%" shell "for i in 192.168.1 192.168.0 10.0.0 172.16.0; do ping -c 1 -W 100 $i.1 >/dev/null 2>&1 && echo $i.1 && break; done" 2^>nul') do (
        set "ip=%%a"
        echo %GREEN%[INFO] IP found via network discovery: %%a%RESET%
        goto :found_ip
    )
)

:found_ip
if not defined ip (
    echo %RED%[ERROR] Could not detect phone IP address.%RESET%
    echo %GRAY%➡ Ensure your phone is connected to WiFi.%RESET%
    echo %GRAY%➡ Try reconnecting USB and running again.%RESET%
    echo %GRAY%➡ Check if your phone's WiFi is enabled.%RESET%
    del "%temp%\adb_devices_check.txt" 2>nul
    pause
    exit /b 1
)

echo %GREEN%[INFO] Phone IP detected: %ip%%RESET%

:: Connect wirelessly
set "serial=%ip%:5555"
echo %CYAN%[INFO] Connecting wirelessly to %serial%...%RESET%
"%adbPath%" connect %serial% > "%temp%\adb_connect.txt" 2>&1

:: Wait a moment for connection to establish
timeout /t 3 /nobreak >nul

:: Check if connection succeeded
"%adbPath%" devices > "%temp%\adb_devices_final.txt" 2>&1
findstr /r ".*:5555.*device" "%temp%\adb_devices_final.txt" >nul
if errorlevel 1 (
    echo %RED%[ERROR] Could not connect wirelessly.%RESET%
    echo %GRAY%➡ Ensure PC and phone are on the same WiFi network.%RESET%
    echo %GRAY%➡ Reconnect USB once and re-run this script.%RESET%
    echo %GRAY%➡ Check firewall settings.%RESET%
    type "%temp%\adb_connect.txt"
    del "%temp%\adb_connect.txt" 2>nul
    del "%temp%\adb_devices_final.txt" 2>nul
    del "%temp%\adb_devices_check.txt" 2>nul
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS] Wireless connection established!%RESET%
set "readyToLaunch=1"
del "%temp%\adb_connect.txt" 2>nul
del "%temp%\adb_devices_final.txt" 2>nul
del "%temp%\adb_devices_check.txt" 2>nul

:launch_scrcpy
:: Launch scrcpy only if we have a valid connection
if not defined readyToLaunch (
    echo %RED%[ERROR] No valid connection established%RESET%
    pause
    exit /b 1
)

echo %GREEN%[INFO] Starting scrcpy...%RESET%
echo.
echo %YELLOW%[NOTE] If you restart your PC or kill ADB,%RESET%
echo %YELLOW%you must reconnect your phone via USB once to restore wireless mode.%RESET%
echo.
echo %RED%Do not close this window.!!!%RESET%
echo.
echo %YELLOW%Wireless connection is now active and stable.%RESET%
echo.
echo %GREEN%Use the Desktop shortcut 'SCRCPY Wireless Launcher' for everyday use. Happy journey!%RESET%
echo.

:: Launch scrcpy with the detected serial
"%scrcpyPath%" -s "%serial%" --verbosity=error

:: Keep window open if scrcpy exits
echo.
echo %YELLOW%[NOTE] scrcpy has exited. You can close this window.%RESET%
pause
