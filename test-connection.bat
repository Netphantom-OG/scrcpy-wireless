@echo off
title SCRCPY Connection Test
color 0E

echo ========================================
echo        SCRCPY CONNECTION TEST
echo ========================================
echo.

cd /d "%~dp0"

if not exist "scrcpy\adb.exe" (
    echo [ERROR] adb.exe not found in scrcpy folder
    echo Please download official scrcpy binaries first
    pause
    exit /b 1
)

echo [INFO] Testing ADB connection...
echo.

echo [STEP 1] Starting ADB server...
scrcpy\adb.exe start-server
echo.

echo [STEP 2] Checking for devices...
scrcpy\adb.exe devices
echo.

echo [STEP 3] Testing USB connection...
echo Please connect your phone via USB and enable USB Debugging
echo.
scrcpy\adb.exe devices
echo.

echo [STEP 4] If device is detected, testing TCP/IP...
for /f "tokens=1,2" %%a in ('scrcpy\adb.exe devices ^| findstr /r ".*device$"') do (
    echo [INFO] USB device found: %%a
    echo [INFO] Enabling TCP/IP mode...
    scrcpy\adb.exe tcpip 5555
    echo [INFO] Waiting 5 seconds...
    timeout /t 5 /nobreak >nul
    
    echo [INFO] Device should now be in TCP/IP mode
    echo [INFO] Wireless connection is now active and stable
    echo.
    echo [INFO] Testing IP detection methods...
    echo.
    
    echo Method 1: Android properties
    scrcpy\adb.exe shell getprop dhcp.wlan0.ipaddress
    scrcpy\adb.exe shell getprop dhcp.eth0.ipaddress
    echo.
    
    echo Method 2: Network interfaces
    scrcpy\adb.exe shell ip -f inet addr show wlan0
    echo.
    
    echo Method 3: Route information
    scrcpy\adb.exe shell ip route
    echo.
    
    goto :end_test
)

echo [WARNING] No USB device detected
echo Please check:
echo - USB cable connection
echo - USB Debugging enabled on phone
echo - Allow USB Debugging when prompted
echo.

:end_test
echo ========================================
echo           TEST COMPLETE
echo ========================================
echo.
echo If you see IP addresses above, the connection is working
echo If not, check your phone's WiFi connection and try again
echo.
pause
