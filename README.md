# GDParchis 🎲 🏆

[![Tests Workflows](https://github.com/turulomio/gdparchis/actions/workflows/test.yml/badge.svg)](https://github.com/turulomio/gdparchis/actions/workflows/test.yml)
[![Linux Downloads](https://img.shields.io/badge/Linux_Downloads-33-FCC624?logo=linux&logoColor=white)](https://github.com/turulomio/gdparchis/releases)
[![Windows Downloads](https://img.shields.io/badge/Windows_Downloads-34-0078D6?logo=windows&logoColor=white)](https://github.com/turulomio/gdparchis/releases)
[![Android Downloads](https://img.shields.io/badge/Android_Downloads-1-3DDC84?logo=android&logoColor=white)](https://github.com/turulomio/gdparchis/releases)
[![Total Downloads](https://img.shields.io/github/downloads/turulomio/gdparchis/total?label=Total%20Downloads&color=blue)](https://github.com/turulomio/gdparchis/releases)

**GDParchis** is a modern 3D implementation of the traditional **Parchís** board game, built with **Godot Engine 4.7** featuring native **Wayland** support on Linux, Windows desktop executables, and Android APK packages.

---

## 🌟 Key Features

- 🎮 **Flexible Game Modes:** Configure 2, 3, or 4 players with any combination of **Human** or **AI (Artificial Intelligence)** players.
- 🎲 **Comparative Starting Roll:** Simultaneous display of all initial dice rolls to determine the starting player, with automatic tie-breaker round management.
- 📐 **Official Parchís Rules Enforcement:**
  - Leaving home requires rolling a **5**.
  - Strict **2-piece capacity limit** per square.
  - **Barrier / Bridge formation** with 2 pieces of the same color and mandatory barrier break rules on rolling a **6**.
  - **Safe squares** and **Home Exit squares**.
  - Automatic bonus moves: **+20** for capturing an opponent piece and **+10** for reaching the goal square.
- 📜 **Match History Viewer:** Persistent match recording (`user://game_history.json`) logging winners, duration, turn counts, and roll logs stored in standard OS user data locations (`~/.local/share/gdparchis/` on Linux, `%APPDATA%\gdparchis\` on Windows).
- 🧪 **Automated Testing Suite:** Integrated 48-test GDScript headless testing system with a **99.6% Code Coverage Engine**.
- 🐧 **Multiplatform Distributions:** Native Linux binary/PCK, Windows `.exe`, and Android `.apk`.

---

## 📸 Screenshots & Interface

| Main Menu | Starting Dice Roll | 3D Gameplay |
| :---: | :---: | :---: |
| ![Main Menu](snapshots/main_menu.png) | ![Starting Dice Roll](snapshots/starting_dice_roll.png) | ![3D Gameplay](snapshots/game.png) |
| *Player count, color selection, custom names, and AI settings* | *Simultaneous dice comparison and tie-breaker rounds* | *3D board physics, piece movement animations, and floating text* |

---

## 🛠️ Setup & Running

### System Requirements
- **Linux:** X11 or Wayland (Godot 4.7+). Supports native binary and PCK package.
- **Windows:** Windows 10/11 (64-bit).
- **Android:** Android 7.0+ (ARM64 / x86_64).
- **Python:** 3.10+ (for the management CLI script `management.py`).

### Development Execution
To run the game in development mode using Godot:
```bash
python3 management.py --play
```

---

## 🧪 Automated Testing & Code Coverage

The project features a headless GDScript test suite that runs without opening a graphical window:

```bash
python3 management.py --test
```

---

## 📦 Building Executables & Distributions

Export packages for Linux, Windows, and Android using the CLI:

```bash
# Export Linux, Windows (.exe), and Android (.apk)
python3 management.py --export
```

Output distributions are generated in `dist/`:
- 🐧 **Linux:** `dist/Linux/gdparchis-<VERSION>.x86_64` & `dist/Linux/gdparchis-<VERSION>.pck`
- 🪟 **Windows Desktop:** `dist/Windows/gdparchis-<VERSION>.exe`
- 🤖 **Android:** `dist/Android/gdparchis-<VERSION>.apk`

---

## 📊 Download Statistics by Release & Platform

| Platform | Cumulative Downloads | Live Asset Badges by Release |
| :--- | :---: | :--- |
| 🐧 **Linux** | [![Linux Total](https://img.shields.io/badge/Linux-33_downloads-FCC624?logo=linux&logoColor=white)](https://github.com/turulomio/gdparchis/releases) | [![v1.0.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-1.0.0.x86_64?label=v1.0.0)](https://github.com/turulomio/gdparchis/releases/tag/1.0.0) [![v0.3.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-0.3.0.Linux_x86_64?label=v0.3.0)](https://github.com/turulomio/gdparchis/releases/tag/0.3.0) [![v0.2.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-0.2.0.Linux_x86_64?label=v0.2.0)](https://github.com/turulomio/gdparchis/releases/tag/0.2.0) [![v0.1.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-0.1.0.Linux_x86_64?label=v0.1.0)](https://github.com/turulomio/gdparchis/releases/tag/0.1.0) [![v0.0.1](https://img.shields.io/github/downloads/turulomio/gdparchis/Gdparchis.x86_64?label=v0.0.1)](https://github.com/turulomio/gdparchis/releases/tag/0.0.1) |
| 🪟 **Windows** | [![Windows Total](https://img.shields.io/badge/Windows-34_downloads-0078D6?logo=windows&logoColor=white)](https://github.com/turulomio/gdparchis/releases) | [![v1.0.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-1.0.0.exe?label=v1.0.0)](https://github.com/turulomio/gdparchis/releases/tag/1.0.0) [![v0.3.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-0.3.0.exe?label=v0.3.0)](https://github.com/turulomio/gdparchis/releases/tag/0.3.0) [![v0.2.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-0.2.0.exe?label=v0.2.0)](https://github.com/turulomio/gdparchis/releases/tag/0.2.0) [![v0.1.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-0.1.0.exe?label=v0.1.0)](https://github.com/turulomio/gdparchis/releases/tag/0.1.0) [![v0.0.1](https://img.shields.io/github/downloads/turulomio/gdparchis/Gdparchis.exe?label=v0.0.1)](https://github.com/turulomio/gdparchis/releases/tag/0.0.1) |
| 🤖 **Android** | [![Android Total](https://img.shields.io/badge/Android-1_download-3DDC84?logo=android&logoColor=white)](https://github.com/turulomio/gdparchis/releases) | [![v1.0.0](https://img.shields.io/github/downloads/turulomio/gdparchis/gdparchis-1.0.0.apk?label=v1.0.0)](https://github.com/turulomio/gdparchis/releases/tag/1.0.0) |

---

## 📚 Documentation Links

- 📘 [User Manual](USER_MANUAL.md): Full guide on game rules, controls, and interface mechanics.
- 🔬 [Testing System Documentation](TESTS.md): Technical details on unit testing, headless state simulator, and coverage engine.
- ⚙️ [Godot 4.7 Environment Guide](GEMINI.md): Environment settings, local export templates, and coding standards.
- 📱 [Android Setup Guide](ANDROID.md): Gentoo Portage dependencies, Android SDK installation, and APK signing steps.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. See the [LICENSE](LICENSE) file for full details.