
```markdown
# 📱 SCRCPY Wireless Launcher

[![Made with PowerShell](https://img.shields.io/badge/Made%20with-PowerShell-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/en-us/powershell/)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue?logo=windows)](https://www.microsoft.com/windows)
[![Android Debug](https://img.shields.io/badge/Supports-Android-green?logo=android)](https://developer.android.com/studio/command-line/adb)
[![License](https://img.shields.io/badge/License-Apache%202.0-orange)](NOTICE.txt)
[![Author](https://img.shields.io/badge/Author-netphantom.og-black)](https://github.com/netphantomog)
[![Download](https://img.shields.io/badge/⬇️%20Download-Release-brightgreen)](https://github.com/netphantomog/scrcpy-wireless-launcher/releases)

A **one-click tool** to run [scrcpy](https://github.com/Genymobile/scrcpy) wirelessly.  
This launcher automatically handles ADB setup, detects your phone IP, connects wirelessly, and runs scrcpy with **zero manual commands**.

---

## 📂 Folder Structure

```

C:\scrcpy-wireless
│   scrcpy-wireless.ps1      ← Main PowerShell launcher
│   Run-ScrcpyWireless.bat   ← Double-click friendly starter
│   NOTICE.txt               ← License notice for scrcpy
│   README.md                ← Documentation
│   scrcpy.ico               ← Icon for shortcut
│
├── scrcpy\                  ← Official scrcpy binaries
│   ├── adb.exe
│   ├── AdbWinApi.dll
│   ├── AdbWinUsbApi.dll
│   ├── scrcpy.exe
│   ├── scrcpy-server.jar
│   └── (other scrcpy files…)

```

---

## 🚀 Getting Started

1. **Download & Extract** from [Releases](https://github.com/netphantomog/scrcpy-wireless-launcher/releases) into:
   `C:\scrcpy-wireless\`

2. On your **Android phone**:
   * Enable **Developer Options** → **USB Debugging**.

3. Connect your phone via **USB cable** (only for the first setup, or if ADB server was restarted).

4. Double-click **`Run-ScrcpyWireless.bat`**:
   * Detects your phone IP.
   * Enables wireless debugging (`adb tcpip 5555`).
   * Connects automatically.
   * Launches **scrcpy**.

5. From the **second run onwards**, you can launch wirelessly using the Desktop shortcut.

---

## ⚠️ Troubleshooting

* **ADB server killed / System restarted** → Connect via USB once, then re-run.
* **Phone IP not detected** → Ensure your device is connected to WiFi or hotspot.
* **scrcpy not launching** → Check that the `scrcpy\` folder contains all official binaries.
* **Permission issues** → Run PowerShell as **Administrator**.

---

## 📜 License & Credits

* [scrcpy](https://github.com/Genymobile/scrcpy) is licensed under **Apache 2.0** by **Genymobile**.
* This launcher is created and maintained by **netphantom.og**.
* `NOTICE.txt` includes scrcpy’s original license notice.

---

## 🔗 Author

👨‍💻 **netphantom.og**

* GitHub: [@netphantomog](https://github.com/netphantomog)
* Instagram: [@netphantom.og](https://instagram.com/netphantom.og)
```

