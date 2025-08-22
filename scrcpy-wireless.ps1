# SCRCPY Wireless Launcher
# Author: netphantom.og
# GitHub: https://github.com/netphantomog
# Instagram: https://instagram.com/netphantom.og

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "   SCRCPY Wireless Launcher v1.2" -ForegroundColor Green
Write-Host "   Author: netphantom.og" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan

# Ensure correct working directory
$expectedDir = "C:\scrcpy-wireless"
$currentDir  = (Get-Location).Path
if ($currentDir -ne $expectedDir) {
    Write-Host "`n[ERROR] Please extract or clone this tool to:" -ForegroundColor Red
    Write-Host "  $expectedDir" -ForegroundColor Yellow
    exit
}

# Check required files
$requiredFiles = @("adb.exe", "scrcpy.exe")
foreach ($file in $requiredFiles) {
    if (-Not (Test-Path "$expectedDir\$file")) {
        Write-Host "[ERROR] Missing file: $file" -ForegroundColor Red
        Write-Host "Please re-download the package." -ForegroundColor Yellow
        exit
    }
}

# Kill any previous adb session
& "$expectedDir\adb.exe" kill-server | Out-Null
& "$expectedDir\adb.exe" start-server | Out-Null

# Check if device detected over USB
$devices = & "$expectedDir\adb.exe" devices
if ($devices -notmatch "device") {
    Write-Host "`n[WARNING] No device detected over USB." -ForegroundColor Yellow
    Write-Host "➡ Ensure USB Debugging is enabled in Developer Options." -ForegroundColor Gray
    Write-Host "➡ Use a data-capable USB cable." -ForegroundColor Gray
    Write-Host "➡ Run 'adb devices' manually to confirm." -ForegroundColor Gray
    pause
    exit
}

# Enable TCP/IP mode on port 5555
Write-Host "`n[INFO] Enabling TCP/IP mode (port 5555)..." -ForegroundColor Cyan
& "$expectedDir\adb.exe" tcpip 5555

# Get device IP
$ip = & "$expectedDir\adb.exe" shell ip -f inet addr show wlan0 | Select-String -Pattern "inet " | ForEach-Object {
    ($_ -split " +")[2].Split("/")[0]
}

if (-Not $ip) {
    Write-Host "`n[ERROR] Could not detect phone IP address." -ForegroundColor Red
    Write-Host "➡ Ensure your phone is connected to WiFi." -ForegroundColor Gray
    Write-Host "➡ You may need to edit the script (replace wlan0 with eth0)." -ForegroundColor Gray
    pause
    exit
}

Write-Host "`n[INFO] Phone IP detected: $ip" -ForegroundColor Green

# Connect wirelessly
Write-Host "[INFO] Connecting wirelessly to $ip:5555..." -ForegroundColor Cyan
$connect = & "$expectedDir\adb.exe" connect "$ip`:5555"

if ($connect -match "failed" -or $connect -match "unable") {
    Write-Host "`n[ERROR] Could not connect wirelessly." -ForegroundColor Red
    Write-Host "➡ Ensure PC and phone are on the same WiFi network." -ForegroundColor Gray
    Write-Host "➡ Reconnect USB once and re-run this script." -ForegroundColor Gray
    pause
    exit
}

# Launch scrcpy
Write-Host "`n[INFO] Starting scrcpy..." -ForegroundColor Green
& "$expectedDir\scrcpy.exe"

# Confirmation after launch
Write-Host "`n✅ SCRCPY launched successfully over wireless connection!" -ForegroundColor Green

# Reminder
Write-Host "`n[NOTE] If you restart your PC or kill ADB," -ForegroundColor Yellow
Write-Host "you must reconnect your phone via USB once to restore wireless mode." -ForegroundColor Yellow
