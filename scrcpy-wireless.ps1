
# SCRCPY Wireless Launcher
# Author: netphantom.og
# GitHub: https://github.com/netphantom-og
# Instagram: https://instagram.com/netphantom.og

# Set console title and colors
$Host.UI.RawUI.WindowTitle = "SCRCPY Wireless Launcher"
$Host.UI.RawUI.ForegroundColor = "White"

# Banner
Write-Host "`n" -NoNewline
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "                                                                " -ForegroundColor Cyan
Write-Host "                    SCRCPY WIRELESS LAUNCHER                  " -ForegroundColor Green
Write-Host "                        Version 1.0.0                         " -ForegroundColor Yellow
Write-Host "                                                                " -ForegroundColor Cyan
Write-Host "                    Author: netphantom.og                     " -ForegroundColor Magenta
Write-Host "                                                                " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "`n" -NoNewline

# Error handling
trap {
    Write-Host "`n[FATAL] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "See details above. The script will now exit." -ForegroundColor Yellow
    Read-Host "Press Enter to close this window"
    break
}

# Resolve base directory and scrcpy tool directory
$baseDir = Split-Path -Parent $PSCommandPath
$scrcpyDir = Join-Path $baseDir "scrcpy"

# Create Desktop shortcut if missing
try {
    $shortcutName = "SCRCPY Wireless Launcher.lnk"
    $userDesktop = [System.Environment]::GetFolderPath('Desktop')
    $shortcutPath = Join-Path $userDesktop $shortcutName
    
    if (-not (Test-Path $shortcutPath)) {
        Write-Host "[INFO] Creating desktop shortcut..." -ForegroundColor Cyan
        $wsh = New-Object -ComObject WScript.Shell
        $sc = $wsh.CreateShortcut($shortcutPath)
        $sc.TargetPath = "powershell.exe"
        $sc.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $sc.WorkingDirectory = $baseDir
        $iconPath = Join-Path $baseDir 'scrcpy.ico'
        if (Test-Path $iconPath) { $sc.IconLocation = $iconPath }
        $sc.Save()
    }
} catch {
    Write-Host "[WARNING] Could not create desktop shortcut" -ForegroundColor Yellow
}

# Check required files
$adbPath = Join-Path $scrcpyDir "adb.exe"
$scrcpyPath = Join-Path $scrcpyDir "scrcpy.exe"

$requiredFiles = @($adbPath, $scrcpyPath)
foreach ($filePath in $requiredFiles) {
    if (-Not (Test-Path $filePath)) {
        Write-Host "[ERROR] Missing file: $(Split-Path $filePath -Leaf)" -ForegroundColor Red
        Write-Host "Expected at: $filePath" -ForegroundColor Yellow
        Write-Host "Please ensure the 'scrcpy' folder is next to this script." -ForegroundColor Yellow
        Read-Host "Press Enter to close this window"
        exit
    }
}

# Initialize ADB server
Write-Host "[INFO] Starting ADB server..." -ForegroundColor Cyan
& $adbPath start-server 2>$null | Out-Null

# Function to get phone IP address using multiple methods
function Get-PhoneIP {
    Write-Host "[INFO] Detecting phone IP address..." -ForegroundColor Cyan
    
    # Method 1: Android properties (most reliable)
    Write-Host "[INFO] Trying Android properties method..." -ForegroundColor Gray
    $properties = @('dhcp.wlan0.ipaddress', 'dhcp.eth0.ipaddress', 'dhcp.wlan1.ipaddress')
    foreach ($prop in $properties) {
        try {
            $ip = & $adbPath shell getprop $prop 2>$null
            if ($ip -and $ip -match "^([0-9]{1,3}\.){3}[0-9]{1,3}$") {
                Write-Host "[SUCCESS] IP found via property $prop`: $ip" -ForegroundColor Green
                return $ip.Trim()
            }
        } catch {}
    }
    
    # Method 2: Network interfaces
    Write-Host "[INFO] Trying network interface method..." -ForegroundColor Gray
    $interfaces = @('wlan0', 'eth0', 'wlan1', 'rmnet_data0')
    foreach ($iface in $interfaces) {
        try {
            $output = & $adbPath shell "ip -f inet addr show $iface 2>/dev/null" 2>$null
            if ($output) {
                $ip = $output | Select-String -Pattern "inet\s+([0-9]{1,3}\.){3}[0-9]{1,3}" | ForEach-Object {
                    ($_ -split "\s+")[2].Split('/')[0]
                } | Select-Object -First 1
                if ($ip) {
                    Write-Host "[SUCCESS] IP found via interface $iface`: $ip" -ForegroundColor Green
                    return $ip
                }
            }
        } catch {}
    }
    
    # Method 3: Route information
    Write-Host "[INFO] Trying route-based method..." -ForegroundColor Gray
    try {
        $route = & $adbPath shell "ip route 2>/dev/null" 2>$null
        if ($route) {
            $ip = $route | Select-String -Pattern "src\s+([0-9]{1,3}\.){3}[0-9]{1,3}" | ForEach-Object {
                ($_ -split "src\s+")[1].Split(' ')[0]
            } | Select-Object -First 1
            if ($ip) {
                Write-Host "[SUCCESS] IP found via route: $ip" -ForegroundColor Green
                return $ip
            }
        }
    } catch {}
    
    # Method 4: Compact address list
    Write-Host "[INFO] Trying compact address method..." -ForegroundColor Gray
    try {
        $addrList = & $adbPath shell "ip -o -4 addr show 2>/dev/null" 2>$null
        if ($addrList) {
            $ip = $addrList | ForEach-Object {
                ($_ -split "\s+")[3].Split('/')[0]
            } | Where-Object { $_ -match "^([0-9]{1,3}\.){3}[0-9]{1,3}$" } | Select-Object -First 1
            if ($ip) {
                Write-Host "[SUCCESS] IP found via compact method: $ip" -ForegroundColor Green
                return $ip
            }
        }
    } catch {}
    
    Write-Host "[ERROR] Could not detect phone IP address" -ForegroundColor Red
    return $null
}

# Function to check if device is connected wirelessly
function Test-WirelessConnection {
    param([string]$IP)
    
    try {
        $result = & $adbPath connect "$IP`:5555" 2>&1
        Start-Sleep -Seconds 3
        
        $devices = & $adbPath devices 2>$null
        $wirelessDevice = $devices | Select-String -Pattern "$IP`:5555\s+device"
        
        if ($wirelessDevice) {
            Write-Host "[SUCCESS] Wireless connection established!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "[ERROR] Wireless connection failed" -ForegroundColor Red
            Write-Host "Connection output: $result" -ForegroundColor Gray
            return $false
        }
    } catch {
        Write-Host "[ERROR] Failed to establish wireless connection" -ForegroundColor Red
        return $false
    }
}

# Main connection logic
Write-Host "[INFO] Checking for existing wireless connections..." -ForegroundColor Cyan
$devices = & $adbPath devices 2>$null
$serial = $null
$foundWireless = $false
$readyToLaunch = $false # New variable to track if we are ready to launch scrcpy

# Check for existing wireless connections
if ($devices) {
    $wirelessDevice = $devices | Select-String -Pattern "([0-9]{1,3}\.){3}[0-9]{1,3}:5555\s+device"
    if ($wirelessDevice) {
        $serial = ($wirelessDevice -split "\s+")[0]
        $foundWireless = $true
        Write-Host "[INFO] Using existing wireless device: $serial" -ForegroundColor Green
        
        # Reconnect to ensure connection is active
        $null = & $adbPath connect $serial 2>$null
        Start-Sleep -Seconds 2
        
        # Verify connection is still active
        $devices = & $adbPath devices 2>$null
        $activeDevice = $devices | Select-String -Pattern "$serial\s+device"
        if ($activeDevice) {
            Write-Host "[SUCCESS] Wireless connection verified" -ForegroundColor Green
            $readyToLaunch = $true
        } else {
            Write-Host "[WARNING] Existing wireless connection is inactive, will re-establish" -ForegroundColor Yellow
            $foundWireless = $false
            $serial = $null
            $readyToLaunch = $false
        }
    }
}

# If no wireless connection, check for USB device
if (-not $foundWireless) {
    Write-Host "[INFO] Checking for USB devices..." -ForegroundColor Cyan
    $usbDevice = $devices | Select-String -Pattern "\s+device$" | ForEach-Object {
        ($_ -split "\s+")[0]
    } | Select-Object -First 1
    
    if ($usbDevice) {
        Write-Host "[INFO] USB device detected: $usbDevice" -ForegroundColor Green
        $serial = $usbDevice
    } else {
        Write-Host "[WARNING] No device detected over USB or wireless" -ForegroundColor Yellow
        Write-Host "➡ If you used this before, ensure the phone stayed on the same WiFi" -ForegroundColor Gray
        Write-Host "➡ Otherwise, connect via USB once to initialize wireless mode" -ForegroundColor Gray
        Write-Host "➡ Make sure USB Debugging is enabled on your phone" -ForegroundColor Gray
        Read-Host "Press Enter to continue"
        exit
    }
}

# Enable TCP/IP mode if we have a USB device
if ($serial -and -not $foundWireless) {
    Write-Host "[INFO] Enabling TCP/IP mode (port 5555)..." -ForegroundColor Cyan
    & $adbPath tcpip 5555 2>$null | Out-Null
    
    Write-Host "[INFO] Device switching to TCP/IP mode..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    
    # Get phone IP address (device is now in TCP/IP mode)
    $ip = Get-PhoneIP
    if (-not $ip) {
        Write-Host "[ERROR] Could not detect phone IP address" -ForegroundColor Red
        Write-Host "➡ Ensure your phone is connected to WiFi" -ForegroundColor Gray
        Write-Host "➡ Try reconnecting USB and running again" -ForegroundColor Gray
        Read-Host "Press Enter to continue"
        exit
    }
    
    Write-Host "[INFO] Phone IP detected: $ip" -ForegroundColor Green
    
    # Establish wireless connection
    if (Test-WirelessConnection -IP $ip) {
        $serial = "$ip`:5555"
        $readyToLaunch = $true
    } else {
        Write-Host "[ERROR] Could not establish wireless connection" -ForegroundColor Red
        Write-Host "➡ Ensure PC and phone are on the same WiFi network" -ForegroundColor Gray
        Write-Host "➡ Check firewall settings" -ForegroundColor Gray
        Write-Host "➡ Reconnect USB once and re-run this script" -ForegroundColor Gray
        Read-Host "Press Enter to continue"
        exit
    }
}

# Launch scrcpy if we have a valid connection
if ($readyToLaunch) {
    Write-Host "`n[INFO] Starting scrcpy..." -ForegroundColor Green
    Write-Host "[NOTE] If you restart your PC or kill ADB," -ForegroundColor Yellow
    Write-Host "you must reconnect your phone via USB once to restore wireless mode" -ForegroundColor Yellow
    Write-Host "`nDo not close this window.!!!" -ForegroundColor Red
    Write-Host "`nWireless connection is now active and stable" -ForegroundColor Yellow
    Write-Host "`nUse the Desktop shortcut 'SCRCPY Wireless Launcher' for everyday use. Happy journey!" -ForegroundColor Green
    Write-Host "`n"
    
    # Launch scrcpy with the detected serial
    try {
        & $scrcpyPath -s $serial --verbosity=error
    } catch {
        Write-Host "[ERROR] Failed to launch scrcpy: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Keep window open
    Write-Host "`n[NOTE] scrcpy has exited. You can close this window." -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
} else {
    Write-Host "[ERROR] No valid connection established" -ForegroundColor Red
    Read-Host "Press Enter to continue"
}
