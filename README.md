# 🔐 Zed-Secure VPN

<div align="center">

![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.35.5-02569B?logo=flutter)
![Android](https://img.shields.io/badge/Android-7.0%2B-3DDC84?logo=android)
![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)

**A professional, modern VPN application for Android with support for V2Ray/Xray protocols**

[Features](#-features) • [Installation](#-installation) • [Build](#-build-from-source) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---
Telegram Channel = https://t.me/CluvexStudio

## ✨ Features

### 🚀 Core Features
- 🔒 **Multiple Protocols**: VMess, VLESS, Trojan, Shadowsocks
- 🌐 **Advanced Transports**: TCP, WebSocket, HTTP/2, gRPC, QUIC, **XHTTP**, **HTTPUpgrade**
- 📊 **Real-time Statistics**: Live upload/download speed, connection duration, data usage
- ⚡ **Concurrent Ping Testing**: Fast latency testing for all servers simultaneously
- 🔄 **Subscription Management**: Auto-update servers from subscription URLs
- 🎯 **Per-App Proxy**: Route specific apps through VPN (Split Tunneling)

### 🎨 UI/UX Features
- 📱 **Modern Fluent Design**: Beautiful UI with Glassmorphism effects
- 🌓 **Light/Dark Mode**: Seamless theme switching with persistence
- 🎛️ **Smart Config Cards**: Click-to-select, individual ping, context menu
- 📋 **QR Code Support**: Scan and generate QR codes for easy sharing
- 🗑️ **Smart Cleanup**: Auto-delete failed/dead configurations

### 💾 Data Management
- 💾 **Backup & Restore**: Export/import configs as JSON to Downloads folder
- 📤 **Easy Import**: Clipboard, QR scanner, manual entry
- 🔍 **Search & Sort**: Find and organize your servers efficiently

### 🔧 Advanced Features
- 🔁 **Individual Ping**: Test specific server latency on demand
- 📊 **Connection Monitoring**: Track network status and VPN health
- 🎯 **Auto-Connect**: Remember last selected server
- 🔐 **Secure Storage**: Encrypted local storage for sensitive data

---

## 📱 Screenshots

<div align="center">

| Home Screen | Servers | Settings |
|------------|---------|----------|
| *Coming Soon* | *Coming Soon* | *Coming Soon* |

</div>

---

## 🔧 Tech Stack

- **Frontend**: Flutter 3.35.5 (Dart 3.9.2)
- **UI Framework**: Fluent UI 4.11.5
- **Backend**: Kotlin 2.2.20
- **VPN Core**: Xray-core 1.25.3
- **Build System**: Gradle 8.7.3
- **Target SDK**: Android 16 (API 36)
- **Min SDK**: Android 7.0 (API 24)
- **Architecture**: Hybrid (Flutter UI + Kotlin Native Layer)

---

## 📥 Installation

### Download APK

Download the latest APK from [GitHub Releases](https://github.com/CluvexStudio/ZedSecure/releases)

**Recommended**: `app-arm64-v8a-release.apk` (for most modern devices)

### System Requirements

- **Android**: 7.0 (Nougat) or higher
- **Architecture**: ARM64-v8a, ARMv7, x86_64
- **Storage**: ~50 MB
- **RAM**: Minimum 2 GB recommended

---

## 🛠️ Build from Source

### Prerequisites

- Flutter SDK: 3.35.5+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Android SDK: 34
- Java JDK: 11 or higher
- Git

### Step 1: Clone Repository

```bash
git clone https://github.com/CluvexStudio/ZedSecure.git
cd ZedSecure
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Setup Signing (Optional for Debug)

For **development** builds, skip this step. For **release** builds:

1. **Create your keystore**:
```bash
keytool -genkey -v -keystore android/app/your-release-key.keystore \
  -alias your-alias -keyalg RSA -keysize 4096 -validity 10000
```

2. **Create `key.properties`** in project root:
```properties
storeFile=android/app/your-release-key.keystore
storePassword=YOUR_PASSWORD
keyAlias=your-alias
keyPassword=YOUR_PASSWORD
```

3. **Add to `.gitignore`** (already configured):
```
key.properties
android/app/*.keystore
```

### Step 4: Build APK

**Option 1: Build for specific architecture (Recommended)**
```bash
# ARM64 (most devices, smallest size)
flutter build apk --release --target-platform android-arm64

# ARMv7 (older devices)
flutter build apk --release --target-platform android-arm

# x86_64 (emulators)
flutter build apk --release --target-platform android-x64
```

**Option 2: Build all architectures**
```bash
flutter build apk --release --split-per-abi
```

**Option 3: Universal APK (larger size)**
```bash
flutter build apk --release
```

**Debug Build**:
```bash
flutter build apk --debug
```

### Output Location

APK files will be located at:
```
build/app/outputs/flutter-apk/
```

---

## 📖 Usage Guide

### Adding Servers

#### Method 1: Subscription URL
1. Open **Subscriptions** tab
2. Tap **Add Subscription** button
3. Enter URL and name
4. Tap **Update** to fetch servers

#### Method 2: Clipboard
1. Copy a config link (vmess://, vless://, trojan://, ss://)
2. Open **Servers** tab
3. Tap **Paste** button (clipboard icon)

#### Method 3: QR Code
1. Open **Servers** tab
2. Tap **QR Scanner** button
3. Scan QR code

### Connecting to VPN

1. **Select a server**: Tap on any server card to select it
2. **Test latency** (optional): Tap **ping** icon or use **Sort by Ping**
3. **Connect**: Tap the **plug** icon on your selected server
4. **Grant VPN permission** when prompted
5. Monitor connection stats on **Home** screen

### Managing Configs

- **Ping Single Server**: Tap speed icon on server card
- **Ping All Servers**: Tap sort icon in toolbar (concurrent, fast!)
- **Copy Config**: Open three-dot menu → Copy Config
- **Show QR Code**: Open three-dot menu → Show QR Code
- **Delete Config**: Open three-dot menu → Delete
- **Delete Dead Configs**: After pinging, tap delete icon to remove failed servers

### Backup & Restore

**Backup**:
1. Settings → Data → **Backup Configs**
2. File saved to: `Downloads/zedsecure_backup_YYYYMMDD_HHMMSS.json`

**Restore**:
1. Settings → Data → **Restore Configs**
2. Select backup file from Downloads

---

## 🌐 Supported Protocols

### VMess
```
vmess://base64-encoded-json-config
```

### VLESS
```
vless://uuid@host:port?encryption=none&security=tls&type=ws&path=/path#remark
```

### Trojan
```
trojan://password@host:port?security=tls&type=tcp#remark
```

### Shadowsocks
```
ss://base64(method:password)@host:port#remark
```

### Supported Transports
- TCP
- WebSocket (ws)
- HTTP/2 (h2)
- gRPC
- QUIC
- **XHTTP** (New!)
- **HTTPUpgrade** (New!)

---

## 🏗️ Project Structure

```
zedsecure/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/zedsecure/vpn/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── PingService.kt         # Native ping
│   │   │   │   ├── PingMethodChannel.kt
│   │   │   │   ├── AppListMethodChannel.kt
│   │   │   │   └── SettingsMethodChannel.kt
│   │   │   ├── AndroidManifest.xml
│   │   │   └── res/                        # App resources
│   │   └── build.gradle.kts                # App-level Gradle
│   └── settings.gradle.kts                  # Project Gradle
├── lib/
│   ├── main.dart                            # App entry point
│   ├── models/
│   │   ├── v2ray_config.dart               # Config model
│   │   └── subscription.dart               # Subscription model
│   ├── screens/
│   │   ├── home_screen.dart                # Connection screen
│   │   ├── servers_screen.dart             # Server list
│   │   ├── subscriptions_screen.dart       # Subscription management
│   │   └── settings_screen.dart            # Settings
│   ├── services/
│   │   ├── v2ray_service.dart              # VPN logic
│   │   └── theme_service.dart              # Theme management
│   └── theme/
│       └── app_theme.dart                   # UI theme
├── local_packages/
│   └── flutter_v2ray_client/               # Xray integration (local)
├── pubspec.yaml                             # Flutter dependencies
├── key.properties.example                   # Signing template
└── README.md
```

---

## 🔐 Security & Privacy

### Data Protection
- ✅ All configs encrypted with `SharedPreferences`
- ✅ Keystore with 4096-bit RSA key
- ✅ No user data collection
- ✅ No telemetry or analytics
- ✅ Local storage only

### Permissions

| Permission | Usage |
|------------|-------|
| `INTERNET` | VPN connection |
| `FOREGROUND_SERVICE` | VPN service |
| `POST_NOTIFICATIONS` | Connection status |
| `WRITE_EXTERNAL_STORAGE` | Backup files |
| `CAMERA` | QR code scanner |

### Open Source
- Full source code available
- Audit the code yourself
- No hidden backdoors
- Community-driven

---

## 🆕 What's New in v1.2.0

### Major Features
- ✨ **Light/Dark Mode**: Toggle between themes in Settings
- ⚡ **Concurrent Ping**: Test all servers simultaneously (much faster!)
- 💾 **Backup & Restore**: Export/import your configs as JSON
- 📷 **QR Code Scanner**: Scan configs with camera
- 🎨 **Improved UI**: Better config cards, click-to-select, 2-line names

### Enhancements
- 🎯 **Individual Ping Button**: Test specific servers on demand
- 🗑️ **Delete Dead Configs**: Remove failed servers with one tap
- 📋 **Three-Dot Menu**: Copy config, show QR, delete per config
- 🔧 **Better About Section**: Developer info with GitHub link
- 📦 **Updated Dependencies**: Flutter 3.35.5, Dart 3.9.2, Kotlin 2.2.20

### Bug Fixes
- 🐛 Fixed config name display (now shows 2 lines)
- 🐛 Fixed UI overflow in header icons
- 🐛 Fixed card size after ping
- 🐛 Removed select button, click card to select
- 🐛 Fixed notification persistence issue

### Protocol Support
- 🚀 **XHTTP Transport** (new in Xray 1.25.3)
- 🚀 **HTTPUpgrade Transport** (new in Xray 1.25.3)

---

## 📦 Dependencies

### Production Dependencies
```yaml
flutter: sdk
fluent_ui: ^4.11.5          # Modern UI framework
glassmorphism: ^3.0.0       # Glass effects
provider: ^6.1.5            # State management
shared_preferences: ^2.2.2  # Local storage
connectivity_plus: ^5.0.2   # Network monitoring
http: ^1.4.0                # HTTP requests
path_provider: ^2.1.1       # File paths
mobile_scanner: ^7.1.2      # QR scanner
qr_flutter: ^4.1.0          # QR generator
permission_handler: ^11.4.0 # Permissions
```

### Dev Dependencies
```yaml
flutter_lints: ^5.0.0
flutter_launcher_icons: ^0.14.3
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/AmazingFeature`
3. **Commit your changes**: `git commit -m 'Add some AmazingFeature'`
4. **Push to the branch**: `git push origin feature/AmazingFeature`
5. **Open a Pull Request**

### Contribution Guidelines

- Follow Dart/Flutter style guide
- Write clear commit messages
- Add comments for complex logic
- Test your changes on real devices
- Update README if adding features

### Areas for Contribution

- 🐛 Bug fixes
- ✨ New features
- 📝 Documentation improvements
- 🌍 Translations
- 🎨 UI/UX enhancements
- ⚡ Performance optimizations

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)** with additional terms.

### ✅ You Can:
- ✔️ Use for personal/educational purposes
- ✔️ Modify and distribute
- ✔️ Fork and create derivatives
- ✔️ Study the code

### ⚠️ You Must:
- ✅ **Credit CluvexStudio** in your app and repository
- ✅ **Keep it open source** (GPL-3.0)
- ✅ **Link to this repository**: https://github.com/CluvexStudio/ZedSecure
- ✅ **Share modifications** under GPL-3.0
- ✅ **Preserve license notices**

### ❌ You Cannot:
- ❌ Remove credits or claim as your own
- ❌ Use commercially without permission
- ❌ Close source or make proprietary
- ❌ Violate user privacy
- ❌ Use for illegal activities

### 💼 Commercial Use

Requires **explicit written permission** from CluvexStudio. Contact via GitHub Issues.

### Attribution Template

When forking/modifying:
```
Based on Zed-Secure VPN by CluvexStudio
https://github.com/CluvexStudio/ZedSecure
Licensed under GPL-3.0
```

See the [LICENSE](LICENSE) file for full legal terms.

---

## 🙏 Acknowledgments

- [flutter_v2ray](https://pub.dev/packages/flutter_v2ray) - V2Ray integration
- [Xray-core](https://github.com/XTLS/Xray-core) - High-performance VPN core
- [Fluent UI](https://pub.dev/packages/fluent_ui) - Microsoft Fluent Design for Flutter
- [mobile_scanner](https://pub.dev/packages/mobile_scanner) - QR code scanning

---

## ⚠️ Disclaimer

This application is intended for **educational and research purposes** only. Users are solely responsible for:
- Complying with local laws and regulations
- Respecting Terms of Service of networks
- Ethical and legal use of the software

The developers are **not responsible** for misuse, illegal activities, or damages arising from the use of this application.

---

## 💡 Support & Community

### Get Help
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/CluvexStudio/ZedSecure/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/CluvexStudio/ZedSecure/discussions)
- 📧 **Contact**: Open an issue on GitHub

### Show Support
- ⭐ **Star this repository** if you find it helpful!
- 🍴 **Fork and contribute**
- 📢 **Share** with others who need privacy tools
- 💬 **Spread the word** about open-source privacy

---

## 👨‍💻 Developed by

<div align="center">

**CluvexStudio**

[![GitHub](https://img.shields.io/badge/GitHub-CluvexStudio-181717?logo=github)](https://github.com/CluvexStudio)
[![Project](https://img.shields.io/badge/Project-ZedSecure-00D9E1)](https://github.com/CluvexStudio/ZedSecure)

*Building open-source tools for digital freedom and privacy*

</div>

---

## 📊 Stats

![GitHub stars](https://img.shields.io/github/stars/CluvexStudio/ZedSecure?style=social)
![GitHub forks](https://img.shields.io/github/forks/CluvexStudio/ZedSecure?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/CluvexStudio/ZedSecure?style=social)

---

<div align="center">

**Made with ❤️ for digital freedom**

If you find this project useful, please consider giving it a ⭐!

[Report Bug](https://github.com/CluvexStudio/ZedSecure/issues) • [Request Feature](https://github.com/CluvexStudio/ZedSecure/issues) • [Contribute](https://github.com/CluvexStudio/ZedSecure/pulls)

</div>
