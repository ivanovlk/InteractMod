# InteractMod — User Guide (WoW 1.12.1)

> ### ⚠️ USE AT YOUR OWN RISK — BAN WARNING
>
> **Interact** modifies client-side interaction behavior, which may violate the Terms of Service of online servers or official game services.
>
> - **No Anti-Cheat Bypass:** This mod does not hide or spoof its activity from anti-cheat systems or server-side behavioral checks.
> - **Account Liability:** Using this mod in online or multiplayer environments can result in temporary suspensions or permanent account bans.
>
> By downloading, installing, or using **Interact**, you acknowledge these risks and accept full responsibility for any actions taken against your account. The developer is not liable for lost accounts, characters, or progress.

<img width="1951" height="1313" alt="image" src="https://github.com/user-attachments/assets/82f61228-543b-460c-8987-45602248d015" />
<img width="620" height="710" alt="image" src="https://github.com/user-attachments/assets/ecca1952-ce3a-4fca-9f8a-da272e293c5a" />
<img width="623" height="717" alt="image" src="https://github.com/user-attachments/assets/ea8fb6a4-2b8f-4847-86ee-33faac55e111" />
<img width="621" height="711" alt="image" src="https://github.com/user-attachments/assets/17ac62ff-fe6f-48e4-96d1-d9ad9670ffa2" />
<img width="622" height="714" alt="image" src="https://github.com/user-attachments/assets/03ca0809-d42a-43d4-b9e9-bca1e6ea659f" />

---

**InteractMod** brings modern **Interact Key** targeting, an **On-Screen Soft-Target Prompt**, **3D World Sparkles** for gathering and quest objects, and a **9-Slot Focus Target Grid** (with Castbars, Buffs/Debuffs, Crowd-Control Tracking, Click-Casting, and Party/Raid Leader Sync) to World of Warcraft 1.12.1.

---

## Quick Start & Installation

1. **Load the Mod DLL:** Place or load `InteractMod.dll` with your WoW 1.12.1 client / launcher (e.g., add `InteractMod.dll` to your DLL loader or `dlls.txt`).
2. **Install the Addon:** Copy the addon files (`Interact.toc`, `Interact.lua`, `Focus.lua`, `Sparkles.lua`, `Bindings.xml`) into:
   `<WoW Folder>\Interface\AddOns\Interact\`
3. **Bind Your Keys:** In-game, open **Main Menu (Esc) → Key Bindings → Interact** and bind:
   - **Interact** or **Interact (auto-loot)** (e.g. `E` or `F`)
   - **Set Focus (Current Target)**, **Target Focus**, and **Clear Focus** (optional)
4. **Open Settings:** Type `/interact` (or `/im`) in chat, or **Left-Click the Minimap Button** to open the 4-tab configuration window.

---

## Core Features

### 1. Smart Interact Key
Press a single key to automatically interact with the best nearby target in front of you:
- **Loot & Gather:** Loot corpses, gather herbs, mine ore veins, chop trees/lumber nodes, open chests, and skin beasts.
- **Quest & Town NPCs:** Talk to quest givers, flight masters, vendors, trainers, bankers, and innkeepers (prioritizes active quest NPCs out of combat).
- **Combat Targeting:** Target and engage nearby enemies in combat, with optional priority for **Casting Enemies** (for quick interrupts), **Low-HP Enemies** (for execute/cleanup), and **Raid-Marked Targets** (`Skull` → `Cross`).
- **Crowd-Control Protection:** Automatically avoids breaking sheep/trap/shackle targets marked with `Moon`, `Square`, or `Diamond` during combat.
- **Fishing & Bobbers:** Reels in your own fishing bobber when splashed (ignoring other players' bobbers), and can optionally start **Fishing** automatically when pressing Interact with a Fishing Pole equipped and nothing nearby.
- **Target Cycling & Restore:** Pressing Interact repeatedly cycles through nearby targets instead of getting stuck on the same one, and can optionally restore your previous combat target after looting or gathering.

---

### 2. On-Screen Soft-Target Prompt & Multi-Target List
Shows a live on-screen indicator of what your Interact key will do before you press it:
- **Main Prompt:** Displays `[Key] <Action> <Target Name> (<Distance> yd)`, color-coded by action (`Loot`, `Gather`, `Skin`, `Talk`, `Attack`, `Reel`, `Mailbox`).
- **Multi-Target Stack (Rows 2 & 3):** Displays up to 2 additional nearby interactable targets below the main prompt — **Left-Click** row `2.` or `3.` to interact directly with that target (automatically dismounts if Auto-Dismount is enabled).
- **Fully Customizable (Tab 3 — `Prompt & BL`):**
  - Drag the prompt anywhere on screen (or adjust X/Y sliders).
  - Adjust **Prompt Scale** (`0.7x`–`1.5x`) and **Prompt Frame Opacity** (`0.0`–`1.0`) — set opacity to `0.0` if you want floating text with a completely transparent frame and border.

---

### 3. 3D World Sparkles for Gathering & Quests
Highlights important objects directly in the 3D game world so you can spot them from up to 55 yards away:
- **5 Color-Coded Categories (individually toggleable in Tab 3):**
  - **Herbs:** Emerald Green
  - **Mines (Ore Veins):** Icy Cyan
  - **Trees (Lumber / Woodcutting):** Leaf Lime-Green
  - **Chests & Footlockers:** Gold
  - **Active Quest Objects:** Bright Amber — automatically reads your Quest Log and highlights crates, books, and objects needed for your current quests.
- **3D Distance Scaling & Smooth Motion:** Sparkles stay locked smoothly onto 3D objects while moving, scale larger as you get closer, and fade gently at long range.
- **Node Nameplates (`<Name> (< yd>)`):** Hover your mouse over any sparkle, look directly toward the primary node near the center of your screen, or hold **`Alt`** to display the object's name and distance below the sparkle.

---

### 4. Focus Target Grid (Up to 9 Targets, 3×3)
Track up to 9 units simultaneously without changing your current target:
- **Classic or Compact Mini-Bar Layout (Tab 4 — `Focus`):**
  - **Full Mode:** Classic Blizzard target frame (`Name`, `HP`, `Mana/Rage/Energy`, `Level / Combat Icon`, `Class / Creature Portrait`, `Elite / Rare Dragon Border`, `Raid Mark`, `Distance & Line-of-Sight Warning`, and clickable **Target-of-Focus**).
  - **Compact Mini-Bar Mode:** Sleek raid-style bars (`148×42`) ideal for tracking 3 to 9 targets at once.
  - **Live 3×3 Grid Preview:** Open `/interact` and switch to **Tab 4 (`Focus`)** to preview all 9 frames and drag any frame to reposition the entire grid.
- **Full-Duration Focus Castbars & Cast Alerts:**
  - Displays the spell icon, spell name, `elapsed / total` cast time, and a smooth progress bar (gold filling for casts, blue draining for channels).
  - **Whole-Frame Red Cast Glow:** When a focused enemy begins casting or channeling, that specific Focus frame glows and pulses bright red (with an optional warning sound) so you never miss an interrupt.
- **Crowd-Control (CC) Countdown Badge & Break Alert:**
  - Automatically detects active CC on any Focus target (`Polymorph`, `Sap`, `Hibernate`, `Shackle Undead`, `Banish`, `Freezing Trap`, `Wyvern Sting`, `Blind`, `Gouge`, `Seduction`, `Fear`, `Psychic Scream`, `Howl of Terror`, `Turn Undead`, `Repentance`, `Hammer of Justice`, `Entangling Roots`, `Sleep`, `Mind Control`, `Enslave Demon`).
  - Shows a large **CC Icon + Live Countdown Timer** on the Focus frame (turning red when `<= 6s` remain).
  - Alerts you immediately with a flashing **`! <CC> BROKE !`** banner, sound, and chat message if a CC breaks early on a living Focus target.
- **Focus Buffs & Debuffs with Hover Tooltips:**
  - Shows up to 8 buffs and 8 debuffs below each Focus frame.
  - **Hover any buff/debuff** to view its spell name, rank, dispel type (`Magic`, `Curse`, `Disease`, `Poison`), and stack count.
  - Spells from **your own class/Spellbook** are highlighted with a bright green border (buffs) or orange-gold border (debuffs).
- **Modifier Click-Casting & Range/Cooldown Badges:**
  - In **Tab 4 (`Focus`)**, pick any spell directly from your character's Spellbook for **Shift+Left-Click**, **Ctrl+Left-Click**, and **Alt+Left-Click** (Right-Click a picker button to clear).
  - Modifier-clicking any Focus frame (`1..9`) casts that spell on that Focus target and automatically restores your previous target.
  - Mini **`S` / `C` / `A` Spell Badges** at the top-right of each Focus frame show live readiness: **Green border** when ready & in range, **Red tint** when out of range, or **Cooldown seconds** when on cooldown.
- **Auto-Populate from Raid Marks & Party/Raid Leader Sync:**
  - **Raid Marks → Focus (`1..8`):** Automatically (or with one click on **Marks** / `/focusmarks`) assigns `Skull` → Focus 1, `Cross` → Focus 2, `Square` → Focus 3, `Moon` → Focus 4, `Triangle` → Focus 5, `Diamond` → Focus 6, `Circle` → Focus 7, and `Star` → Focus 8.
  - **Leader Sync:** When the Party or Raid Leader assigns or broadcasts Focus targets (`Broadcast` button or `/fsync`), all group members with InteractMod automatically receive the exact Focus 1–9 targets.

---

### 5. Profiles & Quality-of-Life Automation
- **One-Click Profiles (Top Bar & Minimap Right-Click Menu):**
  - Built-in **Questing**, **Dungeon / Raid**, **Gathering**, and **City / Safe** profiles (highlighted in green when active).
  - **Left-Click:** Load profile | **Shift+Left-Click:** Save current settings to that profile | **Right-Click:** Reset profile to defaults.
  - **Custom / Export / Import:** Save custom named profiles or share profile strings (`IM1:...`) with friends.
  - **Auto-Switch Profile by Zone:** Automatically switches between `Dungeon / Raid`, `City / Safe`, and `Questing` as you travel.
- **Quality of Life (Tab 2 — `Filters & QoL`):**
  - **Auto-Dismount:** Automatically dismounts when you press Interact on an NPC, node, or corpse.
  - **Interact-to-Mount:** Mounts up when pressing Interact out of combat with no target in range.
  - **Auto-Sell Grey Items & Auto-Repair:** Automatically sells poor-quality (grey) junk and repairs all gear when visiting a merchant.
- **Target Blacklist (Tab 3 — `Prompt & BL`):**
  - Permanently ignore specific annoying NPCs or world objects by clicking **Blacklist Current Prompt** (or pressing its keybind).

---

## Slash Commands Reference

### Main Commands (`/interact` or `/im`)
| Command | What It Does |
| :--- | :--- |
| `/interact` | Open or close the 4-tab settings window |
| `/interact status` | Show current settings summary in chat |
| `/interact profile <name>` | Switch to a profile (`questing`, `raid`, `gathering`, `city`, or custom) |
| `/interact bltarget` | Add the current prompt target to your blacklist |
| `/interact sparkles [on\|off]` | Toggle 3D world sparkles on or off |
| `/interact reset` | Reset all settings and blacklist to defaults |

### Focus Commands (Slots `1`–`9`)
| Command | What It Does |
| :--- | :--- |
| `/focus` (or `/focus1` .. `/focus9`) | Set current target (or mouseover) as Focus 1–9; use with no target or `clear` to clear (`/focus clearall` clears all 9) |
| `/autofocus` | Assign current target (or mouseover) to the next empty Focus slot (`1`–`9`) |
| `/clearfocus [1..9\|all]` | Clear a specific Focus slot (or `all` to clear all 9) |
| `/targetfocus` (or `/targetfocus1` .. `/targetfocus9`) | Target the unit in Focus slot 1–9 |
| `/fcast <Spell Name>` (or `/fcast1` .. `/fcast9 <Spell>`) | Cast a spell directly on Focus 1–9 without losing your current target |
| `/focusmarks` (or `/fmarks`) | Populate Focus 1–8 from active Raid Target Marks (`Skull` → 1 .. `Star` → 8) |
| `/fsync` (or `/focussync`) | Broadcast all 9 Focus targets to your Party or Raid (Leader only) |

---

## Legal, Trademark & Third-Party Licenses

### Non-Affiliation & Non-Commercial Notice
- *World of Warcraft®* and *Blizzard Entertainment®* are trademarks or registered trademarks of Blizzard Entertainment, Inc. in the U.S. and/or other countries.
- **InteractMod** is an independent, free, non-commercial community project created for educational and accessibility purposes. It is not affiliated with, endorsed, sponsored, or approved by Blizzard Entertainment, Inc.
- No proprietary game binaries, assets, or copyrighted data files from *World of Warcraft* are included in or distributed with this project.

### Third-Party Software Attribution (MinHook)
This project uses **MinHook — The Minimalistic x86/x64 API Hooking Library** by Tsuda Kageyu:

> Copyright © 2009–2017 Tsuda Kageyu. All rights reserved.
>
> Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
> 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
> 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
>
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

