<html>
<head>
  <meta charset="UTF-8">
  <meta name="google-site-verification" content="C69qm2NVXzJh9a8cIzDz6wqMqlA5_sUBr1cciWuKouQ" />
</head>
</html>

# SCRCPY Wireless Launcher

> **One-click wireless Android screen mirroring** for Windows, macOS, and Linux

[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)](https://github.com/netphantom-og/scrcpy-wireless)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-orange.svg)](https://github.com/netphantom-og/scrcpy-wireless/releases)

## ✨ **Features**

✅ **Universal Support** - Works on Windows, macOS, and Linux  
✅ **Smart Detection** - Automatically finds existing wireless connections  
✅ **One-Click Setup** - No complex configuration needed  
✅ **Desktop Shortcuts** - Creates platform-appropriate shortcuts  
✅ **Error Handling** - Comprehensive error messages and solutions  
✅ **Architecture Detection** - Automatically detects system architecture  
✅ **Cross-Platform** - Same experience across all operating systems  

## 🚀 **Quick Start**

### Step 1: Download Official scrcpy Binaries

**⚠️ IMPORTANT**: You need to download the official scrcpy binaries first!

**For Windows:**
- **64-bit**: Download [scrcpy-win64-v2.4.0.zip](https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-win64-v2.4.0.zip)
- **32-bit**: Download [scrcpy-win32-v2.4.0.zip](https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-win32-v2.4.0.zip)

**For macOS:**
- **Apple Silicon**: Download [scrcpy-v2.4.0-macos-arm64.tar.gz](https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-macos-arm64.tar.gz)
- **Intel Mac**: Download [scrcpy-v2.4.0-macos-x86_64.tar.gz](https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-macos-x86_64.tar.gz)

**For Linux:**
- **x86_64**: Download [scrcpy-v2.4.0-linux-x86_64.tar.gz](https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-linux-x86_64.tar.gz)
- **ARM64**: Download [scrcpy-v2.4.0-linux-arm64.tar.gz](https://github.com/Genymobile/scrcpy/releases/download/v2.4.0/scrcpy-v2.4.0-linux-arm64.tar.gz)

**Then:**
1. Extract the downloaded file
2. Copy all files from the extracted folder to your `scrcpy/` folder

### Step 2: Setup

1. Extract this launcher to a folder of your choice
2. Enable **USB Debugging** on your Android phone
3. Connect phone with USB (only for first setup or after reboot)

### Step 3: Run

**Windows:**
1. Double-click **Run-ScrcpyWireless.bat** (recommended)

**macOS/Linux:**
1. Open Terminal
2. Navigate to the launcher folder: `cd /path/to/scrcpy-wireless`
3. Make executable: `chmod +x scrcpy-wireless.sh`
4. Run: `./scrcpy-wireless.sh`

**All Platforms:**
- Script auto-detects phone IP → connects via **ADB WiFi** → launches **scrcpy**
- Next time, you can launch wirelessly without USB

---

## 📱 **Android Setup**

### Enable Developer Options
1. **Settings** → **About Phone**
2. **Tap Build Number** 7 times
3. **Go back** → **Developer Options**
4. **Enable USB Debugging**

### First Connection
1. **Connect phone** via USB cable
2. **Allow USB Debugging** on phone when prompted
3. **Run the launcher**
4. **Disconnect USB** when wireless is connected

## 📁 **Folder Structure**

```
scrcpy-wireless/
├── scrcpy-wireless.sh   ← macOS/Linux launcher
├── Run-ScrcpyWireless.bat ← Windows launcher (recommended)
├── scrcpy-wireless.ps1  ← Windows PowerShell launcher
├── scrcpy.ico           ← Windows icon
├── README.md            ← This file
├── LICENSE              ← License information
├── Notice.txt           ← License notice
│
└── scrcpy/ ← YOU NEED TO ADD OFFICIAL BINARIES HERE
    ├── adb              ← Download from official scrcpy release
    ├── scrcpy           ← Download from official scrcpy release
    ├── scrcpy-server    ← Download from official scrcpy release
    └── (other required files…)
```

## 🖥️ **System Compatibility**

### **Windows**
- **Versions**: Windows 7, 8, 8.1, 10, 11
- **Architectures**: 32-bit, 64-bit
- **Features**: One-click execution, PowerShell integration, desktop shortcuts

### **macOS**
- **Versions**: macOS 10.15 (Catalina) to 14.0 (Sonoma)
- **Architectures**: Intel (x86_64), Apple Silicon (ARM64)
- **Features**: Native ARM64 support, Terminal integration, Homebrew support

### **Linux**
- **Distributions**: Ubuntu, Debian, Fedora, Arch Linux, and more
- **Architectures**: x86_64, ARM64, ARM32 (limited)
- **Features**: Package manager support, udev integration, resource efficient

### **Android**
- **Versions**: Android 5.0+ (API level 21+)
- **Recommended**: Android 8.0+ for best experience
- **Requirements**: USB Debugging enabled, same WiFi network as PC

## 🔧 **Alternative Installation Methods**

### **macOS (Homebrew)**
```bash
brew install scrcpy
# Then use our launcher script
```

### **Linux (Package Managers)**
```bash
# Ubuntu/Debian
sudo apt install scrcpy

# Fedora
sudo dnf install scrcpy

# Arch Linux
sudo pacman -S scrcpy
```

## 🛠️ **Troubleshooting**

### **Common Issues**

#### "Missing adb/scrcpy" Error
- **Download** the correct scrcpy binaries for your platform (see Step 1)
- **Extract** and copy files to the `scrcpy/` folder
- **Make executable** (macOS/Linux): `chmod +x scrcpy/adb scrcpy/scrcpy`

#### "Permission Denied" Error (macOS/Linux)
```bash
chmod +x scrcpy/adb scrcpy/scrcpy scrcpy-wireless.sh
```

#### "No Device Detected" Error
- **Check USB cable** - try a different cable
- **Enable USB Debugging** on phone
- **Allow USB Debugging** when prompted
- **Try different USB port**

#### "Cannot Connect Wirelessly" Error
- **Same WiFi network** - ensure phone and PC are on same network
- **Firewall settings** - allow scrcpy through firewall
- **Reconnect USB** once to reinitialize

### **Platform-Specific Issues**

#### **Windows**
- **Antivirus**: Windows Defender may flag files (add to exclusions)
- **SmartScreen**: May show warnings (click "More info" → "Run anyway")
- **Execution Policy**: PowerShell scripts may be blocked

#### **macOS**
- **Gatekeeper**: May block downloads (System Preferences → Security & Privacy)
- **Developer Tools**: May need Xcode Command Line Tools

#### **Linux**
- **udev Rules**: May need to create USB device access rules
- **Dependencies**: May need to install additional packages

## 🔒 **Security & Verification**

### **Why Antivirus Flags This**
- **System-level access** - scrcpy needs to control your phone
- **Network operations** - communicates with Android device
- **Process creation** - launches scrcpy application
- **Unsigned binaries** - official scrcpy binaries are not code-signed

### **This Project is Safe Because**
- ✅ **Open source** - All code is visible and auditable
- ✅ **Based on official scrcpy** - Uses Genymobile's official project
- ✅ **No obfuscation** - Clear, readable code
- ✅ **Local network only** - No internet access
- ✅ **No data collection** - Doesn't send any data anywhere

### **How to Verify**
1. **Check file hashes** against official scrcpy releases
2. **Review source code** - all scripts are plain text
3. **Use VirusTotal** - scan individual files
4. **Check GitHub** - official scrcpy project

## 📊 **Performance Tips**

### **For Best Performance**
- **5GHz WiFi** - faster than 2.4GHz
- **Close other apps** - free up system resources
- **Keep phone screen on** - prevents disconnection
- **Use USB 3.0** - for initial connection

### **Platform-Specific Optimization**
- **Windows**: Use batch file for best compatibility
- **macOS**: Native ARM64 binaries for Apple Silicon
- **Linux**: Package manager installation for dependencies

## 📞 **Support**

### **Getting Help**
1. **Check troubleshooting** section above
2. **Verify file permissions** and structure
3. **Test USB connection** first
4. **Check system compatibility**

### **Useful Commands**

**Windows:**
```cmd
echo %PROCESSOR_ARCHITECTURE%
winver
```

**macOS:**
```bash
uname -m
sw_vers
```

**Linux:**
```bash
uname -m
cat /etc/os-release
```

### **Contact**
- **GitHub Issues**: Open an issue for technical support
- **Documentation**: Check this README for detailed guides

## 🔗 **Useful Links**

- 📦 **[Releases & Downloads](https://github.com/netphantom-og/scrcpy-wireless/releases)**  
- 📖 **[Official scrcpy Project](https://github.com/Genymobile/scrcpy)**
- ⭐ **[Star this Repository](https://github.com/netphantom-og/scrcpy-wireless/stargazers)** and support my project  

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ by [netphantom.og](https://github.com/netphantom-og)**


<details>
<summary>🔑 SEO Keywords (for search engines)</summary>

- scrcpy wireless launcher  
- mirror Android screen to PC wirelessly  
- scrcpy wireless Windows 10  
- adb wireless connect tool  
- android screen mirroring tool  
- one click scrcpy wireless  
- scrcpy wireless without USB  
- alternative to Miracast for Android  
- free android screen mirroring PC  
- android wireless display with scrcpy  
- scrcpy launcher for Windows  
- connect Android to PC without cable  
- scrcpy adb connect automatically  
- best tool to mirror Android phone to PC  
- android screen control from PC wireless  
</details>

*Our launcher now supports **Windows**, **macOS**, and **Linux** with native implementations for each platform! 🌍✨*
