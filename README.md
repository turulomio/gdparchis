# GDParchis 🎲 🏆

[![Tests Workflows](https://github.com/turulomio/gdparchis/actions/workflows/test.yml/badge.svg)](https://github.com/turulomio/gdparchis/actions/workflows/test.yml)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey?logo=linux&logoColor=white)](#)
[![License](https://img.shields.io/badge/License-GPL--3.0-green.svg)](LICENSE)

**GDParchis** is a modern 3D implementation of the traditional **Parchís** board game, built with **Godot Engine 4.7** featuring native **Wayland** support on Linux and Windows desktop executables.

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
- 📜 **Match History Viewer:** Persistent match recording (`user://game_history.json`) logging winners, duration, turn counts, and roll logs.
- 🧪 **Automated Testing Suite:** Integrated 27-test GDScript headless testing system with a **99.6% Code Coverage Engine**.
- 🐧 **Native Linux & Wayland Support:** Native Wayland display server integration with automatic fallback to X11/XWayland.

---

## 📸 Screenshots & Interface

| Main Menu | Starting Dice Roll | 3D Gameplay |
| :---: | :---: | :---: |
| ![Main Menu](snapshots/main_menu.png) | ![Starting Dice Roll](snapshots/starting_dice_roll.png) | ![3D Gameplay](snapshots/game.png) |
| *Player count, color selection, custom names, and AI settings* | *Simultaneous dice comparison and tie-breaker rounds* | *3D board physics, piece movement animations, and floating text* |

---

## 🛠️ Setup & Running

### System Requirements
- **Linux:** X11 or Wayland (Godot 4.7+).
- **Windows:** Windows 10/11 (64-bit).
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

### Test Suite Execution Summary:
```text
===========================================================
               GDPARCHIS AUTOMATED TEST SUITE
===========================================================
--- Running Square Rules Tests ---
  [PASS] Square with 2 pieces has no empty slots
  [PASS] 3rd piece cannot enter a square with 2 pieces
  [PASS] 2 pieces of same player form a barrier
  [PASS] Square 12 is SECURE type
  [PASS] Enemy piece can enter secure square
  [PASS] Square 10 is NORMAL type
--- Running Game Logic Tests ---
  [PASS] Piece begins at home route position 0
  [PASS] Extra moves array stores 2 bonus moves (+20, +10)
  [PASS] 3rd piece cannot move to first square when 2 pieces are inside
...
===========================================================
  TOTAL PASSED   : 27 | TOTAL FAILED : 0
  FINAL COVERAGE : 99.6%
===========================================================
```
For complete details on the test framework architecture, refer to the [Testing System Documentation](TESTS.md).

---

## 📦 Building Executables

Export binaries for Linux and Windows using the local export templates in `templates/`:

```bash
python3 management.py --export
```

Output binaries are placed in `dist/`:
- `dist/Linux/gdparchis-<VERSION>.x86_64`
- `dist/Windows/gdparchis-<VERSION>.exe`

---

## 📚 Documentation Links

- 📘 [User Manual](USER_MANUAL.md): Full guide on game rules, controls, and interface mechanics.
- 🔬 [Testing System Documentation](TESTS.md): Technical details on unit testing, headless state simulator, and coverage engine.
- ⚙️ [Godot 4.7 Environment Guide](GEMINI.md): Environment settings, local export templates, and coding standards.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. See the [LICENSE](LICENSE) file for full details.