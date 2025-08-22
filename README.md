
# SCRCPY Wireless Launcher 🚀

> One-click **scrcpy wireless launcher** for Android screen mirroring over WiFi.
> No manual commands — just plug once, connect, and mirror wirelessly.

![Release](https://img.shields.io/github/v/release/netphantomog/scrcpy-wireless?style=for-the-badge)
![Downloads](https://img.shields.io/github/downloads/netphantomog/scrcpy-wireless/total?style=for-the-badge)
![License](https://img.shields.io/github/license/netphantomog/scrcpy-wireless?style=for-the-badge)

---

## 📌 What is this?

**scrcpy-wireless** is a simple tool that lets you:

* Mirror your **Android screen to PC wirelessly**
* Control your phone using **mouse & keyboard**
* Use **ADB WiFi** without typing long commands

✅ Based on **scrcpy** by [Genymobile](https://github.com/Genymobile/scrcpy).
✅ Works on **Windows 10/11**.
✅ No installation needed — just extract & run.

---

## 📦 Folder Structure

```
C:\scrcpy-wireless
│ scrcpy-wireless.ps1   ← Main PowerShell launcher
│ Run-ScrcpyWireless.bat ← One-click starter
│ scrcpy.ico            ← Icon for shortcuts
│ README.md             ← Documentation
│ NOTICE.txt            ← License notice
│
└── scrcpy\ ← Official scrcpy binaries
    ├── adb.exe
    ├── scrcpy.exe
    ├── scrcpy-server
    ├── (other required files…)
```

---

## 🚀 How to Use

1. Extract the folder to **`C:\scrcpy-wireless\`**
2. Enable **USB Debugging** on your Android phone
3. Connect phone with USB (only for first setup or after reboot)
4. Double-click **Run-ScrcpyWireless.bat**
5. Script auto-detects phone IP → connects via **ADB WiFi** → launches **scrcpy**
6. Next time, you can launch wirelessly without USB

---

## 📸 Screenshots / Demo

*(Add GIFs/screenshots of phone mirroring here for SEO boost)*

---

## ⚠️ Troubleshooting

* If phone not detected → reconnect via USB once
* If scrcpy doesn’t launch → check that the `scrcpy\` folder is complete
* If WiFi IP not found → ensure phone & PC are on the same network

---

## 📜 License

* **scrcpy** is licensed under [Apache 2.0](https://github.com/Genymobile/scrcpy).
* This launcher is by **netphantom.og**.

---

## 🔗 Links

* 📂 [Releases / Download](https://github.com/netphantomog/scrcpy-wireless/releases)
* 📝 [Wiki (Setup + FAQ)](https://github.com/netphantomog/scrcpy-wireless/wiki)
* ⭐ [Star this repo](https://github.com/netphantomog/scrcpy-wireless/stargazers) if useful

---

## 📢 Author

* GitHub: [@netphantomog](https://github.com/netphantomog)
* Instagram: [netphantom.og](https://instagram.com/netphantom.og)

  

---
