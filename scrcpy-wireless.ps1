
# SCRCPY Wireless Launcher
# Author: netphantom.og
# GitHub: https://github.com/netphantom-og
# Instagram: https://instagram.com/netphantom.og

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

# Start a non-blocking loading spinner immediately after banner (timer-based)
$script:spinnerIndex = 0
$spinnerFrames = @('|','/','-','\\')
$script:spinnerTimer = New-Object System.Timers.Timer
$script:spinnerTimer.Interval = 120
$script:spinnerEvent = Register-ObjectEvent -InputObject $script:spinnerTimer -EventName Elapsed -SourceIdentifier 'SpinnerTick' -MessageData $spinnerFrames -Action {
    $frames = $event.MessageData
    $idx = (Get-Variable -Name spinnerIndex -Scope Script -ValueOnly) 2>$null
    if ($null -eq $idx) { $idx = 0 }
    $frame = $frames[$idx % $frames.Count]
    Write-Host ("`r[INFO] Loading... " + $frame) -NoNewline -ForegroundColor Cyan
    Set-Variable -Name spinnerIndex -Scope Script -Value ($idx + 1)
} | Out-Null
$script:spinnerTimer.Start()

# Trap unexpected errors and keep window open
trap {
    Write-Host "`n[FATAL] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "See details above. The script will now exit." -ForegroundColor Yellow
    Read-Host "Press Enter to close this window"
    break
}

# Resolve base directory and scrcpy tool directory relative to this script
$baseDir    = Split-Path -Parent $PSCommandPath
$scrcpyDir  = Join-Path $baseDir "scrcpy"

# Create Desktop shortcut if missing
try {
    $shortcutName = "SCRCPY Wireless Launcher.lnk"
    $userDesktop  = [System.Environment]::GetFolderPath('Desktop')
    $publicDesktop = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
    $shortcutPath = Join-Path $userDesktop $shortcutName
    if (-not (Test-Path $shortcutPath)) {
        $wsh = New-Object -ComObject WScript.Shell
        $powershellExe = Join-Path $PSHOME 'powershell.exe'
        $sc = $wsh.CreateShortcut($shortcutPath)
        $sc.TargetPath = $powershellExe
        $sc.Arguments  = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $sc.WorkingDirectory = $baseDir
        $iconPath = Join-Path $baseDir 'scrcpy.ico'
        if (Test-Path $iconPath) { $sc.IconLocation = $iconPath }
        $sc.Save()
        if (-not (Test-Path $shortcutPath) -and $publicDesktop) {
            $shortcutPath = Join-Path $publicDesktop $shortcutName
            $sc = $wsh.CreateShortcut($shortcutPath)
            $sc.TargetPath = $powershellExe
            $sc.Arguments  = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            $sc.WorkingDirectory = $baseDir
            if (Test-Path $iconPath) { $sc.IconLocation = $iconPath }
            $sc.Save()
        }
    }
} catch {
    # Silent on shortcut creation errors
}

# Check required files
$adbPath      = Join-Path $scrcpyDir "adb.exe"
$scrcpyPath   = Join-Path $scrcpyDir "scrcpy.exe"
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

# Initialize adb server (do not kill to preserve existing wireless sessions)
& $adbPath start-server 2>$null | Out-Null

# Detect existing TCP/IP device first (reconnect without USB)
$devices = & $adbPath devices 2>$null
$serial = $null
if ($devices) {
    $tcpipSerial = ($devices | Select-String -Pattern '(^|\s)([0-9]{1,3}\.){3}[0-9]{1,3}:5555\s+device' | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
    if ($tcpipSerial) {
        $serial = $tcpipSerial
        Write-Host "`n[INFO] Using existing wireless device $serial" -ForegroundColor Green
        $null = & $adbPath connect $serial 2>$null
    }
}

# If no TCP/IP serial, try USB path or last known IP
if (-not $serial) {
    # If still no serial, check for USB device
    if (-not $serial) {
        $usbDevice = ($devices | Select-String -Pattern '\s+device$' | ForEach-Object { ($_ -split "\s+")[0] } | Select-Object -First 1)
        if ($usbDevice) {
            Write-Host "`n[INFO] USB device detected: $usbDevice" -ForegroundColor Green
            $serial = $usbDevice  # Use USB device directly
        } else {
            if ($script:spinnerTimer) { try { $script:spinnerTimer.Stop(); Unregister-Event -SourceIdentifier 'SpinnerTick' -ErrorAction SilentlyContinue | Out-Null; Remove-Job -Name 'SpinnerTick' -ErrorAction SilentlyContinue | Out-Null; $script:spinnerTimer.Dispose() } catch {} }
            Clear-Host
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
            Write-Host "`n[WARNING] No device detected over USB or wireless." -ForegroundColor Yellow
            Write-Host "➡ If you used this before, just ensure the phone stayed on the same WiFi and try again." -ForegroundColor Gray
            Write-Host "➡ Otherwise, connect via USB once to initialize wireless mode." -ForegroundColor Gray
            pause
            exit
        }
    }
}

if (-not $serial) {
    # Enable TCP/IP mode on port 5555
    Write-Host "`n[INFO] Enabling TCP/IP mode (port 5555)..." -ForegroundColor Cyan
    & $adbPath tcpip 5555 2>$null | Tee-Object -Variable tcpipOutput | Out-Null
    # Some devices print "error: closed" even when tcpip mode toggled. Wait briefly and continue.
    Start-Sleep -Seconds 2

    # Re-check adb connection over USB before querying IP
    $null = & $adbPath devices 2>$null | Out-Null
}

# Get device IP (multiple strategies) - only if we don't have a serial yet
function Get-PhoneIPv4 {
    param([string[]] $interfaces = @('wlan0','eth0','wlan1','rmnet_data0'))

    $candidates = New-Object System.Collections.Generic.List[string]

    foreach ($iface in $interfaces) {
        $out = & $adbPath shell ip -f inet addr show $iface 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) {
            $out | Select-String -Pattern "\binet\s+([0-9]{1,3}\.){3}[0-9]{1,3}\b" | ForEach-Object {
                $addr = ($_ -split " +")[2].Split('/')[0]
                if ($addr) { $candidates.Add($addr) }
            }
        }
    }

    # Route-based detection
    $route = & $adbPath shell ip route 2>$null
    if ($route) {
        $route | Select-String -Pattern "\bsrc\s+([0-9]{1,3}\.){3}[0-9]{1,3}\b" | ForEach-Object {
            $parts = ($_ -split 'src ')[1]
            if ($parts) {
                $addr = $parts.Trim().Split(' ')[0]
                if ($addr) { $candidates.Add($addr) }
            }
        }
    }

    # Compact addr list
    $addrList = & $adbPath shell ip -o -4 addr show 2>$null
    if ($addrList) {
        $addrList | ForEach-Object {
            $col = ($_ -split ' +')[3]
            if ($col) { $candidates.Add($col.Split('/')[0]) }
        }
    }

    # Android properties fallback
    foreach ($prop in @('dhcp.wlan0.ipaddress','dhcp.eth0.ipaddress')) {
        $p = & $adbPath shell getprop $prop 2>$null
        if ($p -and $p -match "([0-9]{1,3}\.){3}[0-9]{1,3}") { $candidates.Add($p.Trim()) }
    }

    # Prefer private ranges
    $ordered = $candidates | Where-Object { $_ -match "^10\.|^192\.168\.|^172\.(1[6-9]|2[0-9]|3[0-1])\." } | Select-Object -Unique
    if (-not $ordered) { $ordered = $candidates | Select-Object -Unique }
    return $ordered | Select-Object -First 1
}

$ip = $null
if (-not $serial) { $ip = Get-PhoneIPv4 }

if (-not $serial -and -Not $ip) {
    Write-Host "`n[ERROR] Could not detect phone IP address." -ForegroundColor Red
    Write-Host "➡ Ensure your phone is connected to WiFi." -ForegroundColor Gray
    Write-Host "➡ You may need to edit the script (replace wlan0 with eth0)." -ForegroundColor Gray
    pause
    exit
}

if (-not $serial) { Write-Host "`n[INFO] Phone IP detected: $ip" -ForegroundColor Green }

if (-not $serial) {
    # Connect wirelessly
    $serial = "$ip`:5555"
    Write-Host "[INFO] Connecting wirelessly to $serial..." -ForegroundColor Cyan
    $connect = & $adbPath connect $serial 2>$null
}

if ($connect -match "failed|unable") {
    Write-Host "`n[ERROR] Could not connect wirelessly." -ForegroundColor Red
    Write-Host "➡ Ensure PC and phone are on the same WiFi network." -ForegroundColor Gray
    Write-Host "➡ Reconnect USB once and re-run this script." -ForegroundColor Gray
    pause
    exit
}

# Stop spinner before moving to scrcpy launch
if ($script:spinnerTimer) {
    try {
        $script:spinnerTimer.Stop()
        Unregister-Event -SourceIdentifier 'SpinnerTick' -ErrorAction SilentlyContinue | Out-Null
        Remove-Job -Name 'SpinnerTick' -ErrorAction SilentlyContinue | Out-Null
        $script:spinnerTimer.Dispose()
    } catch {}
}
Write-Host ""  # move to next line after spinner

# Launch scrcpy, do not wait; capture output briefly to extract a success line
Write-Host "`n[INFO] Starting scrcpy..." -ForegroundColor Green
$stdoutPath = [System.IO.Path]::Combine($env:TEMP, "scrcpy_stdout_" + [System.Guid]::NewGuid().ToString() + ".log")
$stderrPath = [System.IO.Path]::Combine($env:TEMP, "scrcpy_stderr_" + [System.Guid]::NewGuid().ToString() + ".log")

$proc = Start-Process -FilePath $scrcpyPath -ArgumentList @('-s', $serial, '--verbosity=error') -NoNewWindow -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath

# Poll logs up to ~2 seconds for a clear success hint (silent)
$observedSuccess = $false
$lastMessage = $null
for ($i = 0; $i -lt 10; $i++) {
    Start-Sleep -Milliseconds 200
    $outLines = @()
    if (Test-Path $stdoutPath) { $outLines += Get-Content $stdoutPath -ErrorAction SilentlyContinue }
    if (Test-Path $stderrPath) { $outLines += Get-Content $stderrPath -ErrorAction SilentlyContinue }
    if ($outLines) {
        $filteredOutput = $outLines | Where-Object {
            $_ -and $_.Trim() -ne '' -and (
                $_ -notmatch "\bfile pushed\b" -and
                $_ -notmatch "scrcpy-server:.*pushed" -and
                $_ -notmatch "^scrcpy\s+\d+" -and
                $_ -notmatch "github\.com"
            )
        }
        if ($filteredOutput) {
            $lastMessage = ($filteredOutput | Select-Object -Last 1)
            if ($filteredOutput | Where-Object { $_ -match "\b(Renderer:|Texture:|\[server\] INFO: Device:)\b" }) {
                $observedSuccess = $true
                break
            }
        }
    }
}

try { } finally {
    if (Test-Path $stdoutPath) { Remove-Item $stdoutPath -Force }
    if (Test-Path $stderrPath) { Remove-Item $stderrPath -Force }
}

# Confirmation after launch
# Compute success but suppress detailed logs at the end
$wasSuccess = ($observedSuccess -or ($proc.HasExited -and $proc.ExitCode -eq 0))

# Clear prior output and show only banner and notes
Clear-Host
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

# Reminder
Write-Host "`n[NOTE] If you restart your PC or kill ADB," -ForegroundColor Yellow
Write-Host "you must reconnect your phone via USB once to restore wireless mode." -ForegroundColor Yellow

# Show the last message from scrcpy
if ($lastMessage) {
    Write-Host "`n$lastMessage" -ForegroundColor Gray
}

# Do not close warning
Write-Host "`nDo not close this window.!!!" -ForegroundColor Red




# Final friendly note for everyday use
Write-Host "`nYou can now disconnect the USB cable; wireless is stable." -ForegroundColor Yellow


# Final friendly note for everyday use
Write-Host "`nUse the Desktop shortcut 'SCRCPY Wireless Launcher' for everyday use. Happy journey!" -ForegroundColor Green

# End quietly; do not prompt
