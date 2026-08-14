# Testing System & Code Coverage Documentation 🧪

This document describes the architecture, design, and CLI usage of the **Automated Testing System and Code Coverage Engine** in **GDParchis**.

---

## 🏛️ Test System Architecture

The testing system resides in the `tests/` directory and is built to run headlessly (without a graphical window or display server). It integrates directly with the management CLI (`management.py`) and **GitHub Actions** CI/CD.

```
tests/
├── test_runner.tscn       # Main runner scene loaded by Godot CLI
├── test_runner.gd         # Test runner orchestrator, result aggregator, and quit()
├── test_simulator.gd      # Headless state simulator (state seeding and node hierarchy)
├── test_square_rules.gd   # Suite: Square 2-piece capacity, barriers, and safe squares
├── test_game_logic.gd     # Suite: Exit on 5, bonuses (+20, +10), 3 fives rule, and barriers
├── test_ui.gd             # Suite: Scene resource integrity, Options, and GameHistory JSON
└── test_coverage.gd       # GDScript code coverage parser (% executed lines)
```

---

## 🧪 Test Suites & Components Overview

### 1. Headless State Simulator (`test_simulator.gd`)
Provides an in-memory testing environment to simulate board states without 3D rendering or physics server overhead:
- **`seed_piece_at_route_position(player_id, piece_idx, route_pos)`**: Places any piece on any target route square.
- **`cleanup()`**: Explicitly frees `Board4`, `Player`, `Piece`, and `Dice` node hierarchies to eliminate ObjectDB and RID memory leaks upon process exit.

### 2. Square Rules Test Suite (`test_square_rules.gd`)
- **2-Piece Capacity Limit:** Verifies that when 2 pieces occupy a square, `empty_position() == -1` and rejects entry of a 3rd piece.
- **Barrier Formation:** Verifies that 2 pieces of the same player form a barrier (`has_barrier() == true`).
- **Safe Squares:** Verifies coexistence of opponent pieces on `SECURE` squares (e.g. 12, 17, 29, 34, 46, 51, 63, 68).

### 3. Game Logic & Bonus Test Suite (`test_game_logic.gd`)
- **Exit Home on 5:** Verifies that home pieces (`route_position == 0`) require a 5 to exit.
- **3 Fives Full Square Rule:** Verifies that if the exit square already holds 2 pieces of the same color, rolling a 5 **does not mandate or allow a 3rd piece to exit from home**.
- **Bonus Management:** Verifies addition and consumption of extra move bonuses (+20 for captures, +10 for goals).

### 4. UI & Persistence Test Suite (`test_ui.gd`)
- **Scene Integrity:** Verifies existence and loading of `.tscn` scenes (`Main.tscn`, `PlayersSelection.tscn`, `Options.tscn`, `GameHistory.tscn`, `Game4.tscn`, `GameDiceStart.tscn`).
- **Match History & Config Persistence:** Verifies clearing, saving, and loading configuration (`user://gdparchis.cfg`) and match history (`user://game_history.json`) mapped to standard OS user data locations:
  - **Linux:** `~/.local/share/gdparchis/`
  - **Windows:** `%APPDATA%\gdparchis\` (`C:\Users\<user>\AppData\Roaming\gdparchis\`)
  - **macOS:** `~/Library/Application Support/gdparchis/`

### 5. Code Coverage Parser (`test_coverage.gd`)
Statically inspects GDScript files in `scenes/*.gd`, counting executable code lines (filtering blank lines, `#` comments, and passive `var`/`signal` declarations):
- Calculates the ratio of executed code lines during the test run.
- Prints a formatted coverage summary table with individual file percentages and **Overall Total Coverage**.

---

## 🚀 Running Tests via CLI

To run the automated test suite and generate the coverage report:

```bash
python3 management.py --test
```

### Internal Execution Sequence:
1. `management.py` runs `godot --headless --editor --quit` to populate `.godot/imported/` with binary textures, fonts, and audio assets.
2. `management.py` runs `godot --headless res://tests/test_runner.tscn`.
3. `test_runner.gd` executes each test suite, calculates coverage, and prints the summary.
4. Returns exit code `0` on success or exit code `1` on failure, releasing the console immediately.

---

## ⚙️ CI/CD Integration (GitHub Actions)

The `.github/workflows/test.yml` workflow automatically runs tests on every `push` and `pull_request` targeting `main`:

```yaml
name: Automated Tests

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  test:
    name: Run GDScript Tests & Coverage
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set up Python 3.x
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install Godot Engine 4.7.1 Headless
        run: |
          sudo apt-get update && sudo apt-get install -y wget unzip
          wget https://github.com/godotengine/godot/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip || wget https://github.com/godotengine/godot-builds/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip || wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
          unzip Godot_v*.zip
          sudo mv Godot_v*_linux.x86_64 /usr/local/bin/godot
          sudo chmod +x /usr/local/bin/godot

      - name: Run Test Suite & Generate Coverage Report
        run: |
          python3 management.py --test
```
