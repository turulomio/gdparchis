# User Manual - GDParchis 🎲 🏆

Welcome to **GDParchis**, a 3D adaptation of the classic Parchís board game built in Godot Engine 4.7.

---

## 📋 Table of Contents
1. [Initial Game Setup](#1-initial-game-setup)
2. [Determining the Starting Player (Dice Roll)](#2-determining-the-starting-player-dice-roll)
3. [Game Rules & Movement Mechanics](#3-game-rules--movement-mechanics)
   - [Exiting Home](#exiting-home)
   - [Square Capacity & Barrier Rules](#square-capacity--barrier-rules)
   - [Capturing (Eating Pieces) & +20 Bonus](#capturing-eating-pieces--20-bonus)
   - [Reaching Goal & +10 Bonus](#reaching-goal--10-bonus)
   - [Rolling a 6](#rolling-a-6)
4. [Board Square Types](#4-board-square-types)
5. [Match History Viewer](#5-match-history-viewer)
6. [Controls & Accessibility](#6-controls--accessibility)

---

## 1. Initial Game Setup

![Main Menu](snapshots/main_menu.png)

Upon launching the game, you will enter the **Player Selection Menu**:

- **Player Count:** Select 2, 3, or 4 players for the match.
- **Color Assignments:**
  - Player 0: Yellow 🟡
  - Player 1: Blue 🔵
  - Player 2: Red 🔴
  - Player 3: Green 🟢
- **Player Types:** Toggle each player slot between **Human Player** or **Artificial Intelligence (AI)**.
- **Custom Player Names:** Enter custom names for each player to be displayed during in-game floating text announcements and in the post-game Match History logs.

---

## 2. Determining the Starting Player (Dice Roll)

![Starting Dice Roll](snapshots/starting_dice_roll.png)

Before moving pieces on the board:

1. The **Starting Roll** screen is presented.
2. Each player rolls their 3D die by clicking their roll button.
3. **Visual Comparison:** All rolled dice remain visible on screen simultaneously to compare values.
4. The player rolling the highest value takes the first turn.
5. **Tie-Breakers:** If two or more players tie for the highest roll, only the tied candidates roll again in subsequent rounds until a single winner is determined.

---

## 3. Game Rules & Movement Mechanics

![3D Gameplay](snapshots/game.png)

### Exiting Home
- All 4 pieces start inside their color-coded home base (route position 0).
- Moving a piece out of home onto the **Home Exit Square** (route position 1) requires rolling a **5**.
- **Capacity Limit (2 Pieces):** If the exit square already contains 2 pieces of the same player, rolling a 5 **cannot move a 3rd piece out of home**, because the square is at maximum capacity (2 pieces).

### Square Capacity & Barrier Rules
- Any square on the board can hold a **maximum of 2 pieces**.
- **Barrier / Bridge Formation:** When 2 pieces of the same player occupy the same square, they form a **Barrier**.
- **Blocking:** No piece (enemy or friendly) can leap over or pass through a barrier.
- **Opening a Barrier:** If a player owns a barrier and rolls a **6**, they are mandated to break the barrier by moving one of its 2 pieces if a legal move exists.

### Capturing (Eating Pieces) & +20 Bonus
- When a piece lands on a normal square occupied by a single opponent piece, the opponent piece is **captured** and sent back to its home base.
- **Bonus:** Capturing an opponent piece grants an immediate bonus move of **+20 squares** with any active piece of the capturing player.

### Reaching Goal & +10 Bonus
- Entering the final goal square (square 76, 84, 92, or 100 depending on color) requires an exact dice count.
- **Bonus:** Every piece that reaches the goal square grants a bonus move of **+10 squares** to another piece of the same player.

### Rolling a 6
- If all 4 pieces of a player are out of home, rolling a **6** advances a piece **7 squares**.
- Rolling three consecutive 6s penalizes the player by sending the last moved piece back to home (unless it has entered the final safe ramp).

---

## 4. Board Square Types

| Square Type | Description |
| :--- | :--- |
| **HOME (`START`)** | Home base starting area for all 4 pieces (requires rolling a 5 to exit). |
| **EXIT (`FIRST`)** | Home exit square where pieces land when exiting home (Yellow: 5, Blue: 22, Red: 39, Green: 56). |
| **SAFE (`SECURE`)** | Marked safe squares where pieces belonging to different players coexist without capturing (e.g. squares 12, 17, 29, 34, 46, 51, 63, 68). |
| **NORMAL (`NORMAL`)** | Standard board path squares where landing on an opponent piece triggers a capture. |
| **GOAL (`END`)** | Final victory square where all 4 pieces must arrive to win the match. |

---

## 5. Match History Viewer

Access the **Match History** screen (`GameHistory`) from the main menu:

- Displays the timestamp for each completed match.
- Logs the **Winner's Player Name** and player type (Human or AI).
- Displays total turn count and match duration.
- Keeps roll statistics for post-match analysis.

---

## 6. Controls & Accessibility

- **Mouse:** Click on 3D dice to roll and click highlighted pieces to move.
- **Fullscreen Mode:** Toggle fullscreen mode in the Options menu.
- **Linux Display Server:** Native **Wayland** support with automatic fallback to X11/XWayland.
