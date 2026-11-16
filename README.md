# InteractMod
Interact Mod for Vanilla 1.12.1


<img width="1951" height="1313" alt="image" src="https://github.com/user-attachments/assets/82f61228-543b-460c-8987-45602248d015" />
<img width="620" height="710" alt="image" src="https://github.com/user-attachments/assets/ecca1952-ce3a-4fca-9f8a-da272e293c5a" />
<img width="623" height="717" alt="image" src="https://github.com/user-attachments/assets/ea8fb6a4-2b8f-4847-86ee-33faac55e111" />
<img width="621" height="711" alt="image" src="https://github.com/user-attachments/assets/17ac62ff-fe6f-48e4-96d1-d9ad9670ffa2" />
<img width="622" height="714" alt="image" src="https://github.com/user-attachments/assets/03ca0809-d42a-43d4-b9e9-bca1e6ea659f" />


## Features

### 1. Smart Interaction & Target Selection (C++)
- **Cone & Proximity Scoring:** Evaluates candidates within configurable cone half-angle (`15+-РђЊ180+-`), close-proximity bypass radius (`0РђЊ8 yd`), and vertical Z-axis difference (`0РђЊ20 yd`, prevents targeting across floors/ceilings).
- **Camera-Relative Cone (`cameraCone`):** Optional toggle to aim the selection cone along the camera forward vector instead of character facing.
- **Line-of-Sight Check (`losCheck`):** Uses `CWorld::Intersect` (`0x672170`) to skip enemies, corpses, and gatherables (`goType == 3`) blocked by walls or terrain, while allowing interaction with mailboxes and town NPCs across counters.
- **Priority Tiers & Target Cycling:** Ranks lootable corpses, combat enemies, questgivers, gatherables, and NPCs; applies a configurable `cycleTime` penalty (`0РђЊ10000 ms`) to recently interacted GUIDs while exempting newly-killed lootable corpses so you can loot immediately.
- **Hard Target Handling:** Honors your valid current hard target, with `skipLootedTarget` to fall back to scanning when a dead target has no loot/skin.
- **Raid Mark Priority & CC Protection:** Boosts `Skull`/`Cross` targets (`raidMarkPriority`) and skips `Moon`/`Square`/`Star`/`Diamond` CC'd targets (`protectCCMarks`).
- **Questgiver OOC Priority (`prioritizeQuestOOC`):** Ranks Questgiver NPCs and GameObjects above enemies while out of combat.
- **Prioritize Low-HP Enemies (`prioritizeLowHP`):** In combat, adds a `+1500.0` score boost to living enemies below 25% HP for faster execute/finish targeting.
- **Prioritize Casting Enemies (`prioritizeCasting`):** In combat, adds a `+1200.0` score boost to living enemies currently casting or channeling a spell.
- **Skip Tapped Enemies (`ignoreTapped`):** Skips living enemies out of combat that are tagged by another player (`UNIT_DYNFLAG_OTHER_TAGGER`).
- **Restore Previous Target (`restoreTarget`):** Re-targets your previous target after interacting.

### 2. Creature & World Object Filtering
- **Creatures & Combat:** `interactEnemies`, `lootInCombat`, `prioritizeLoot`, `interactPlayers`, `ignorePassiveNPC`, `enemyPlayersOOC`, `ignoreCritters` (`CREATURE_TYPE_CRITTER = 8`).
- **Gatherables:** Separate toggles for `ignoreHerbs`, `ignoreOre`, `ignoreChests`, and `ownBobberOnly` (ignore other players' fishing bobbers).
- **World Objects:** Individual filters for `ignoreChairs`, `ignoreSpellFocus` (campfires/forges/anvils), `ignoreMailboxes`, `ignoreDoors`, `ignoreRituals` (summoning portals), `ignoreGoobers`, and `ignoreOtherGOs`.
- **Named Blacklist Manager:** Persistent entry ID blacklist (supports both GameObjects and NPCs) with a 5-row paged UI, one-click removal, and `BL Prompt/Last` (`/interact bltarget`).

### 3. Soft-Target On-Screen Prompt & Multi-Target Stack
- Polls `CMD_QUERY_NEAREST` (`300`) or `CMD_QUERY_STACK` (`301`) every `0.1s` and displays `[Keybind] <Action> <Name> (<dist> yd)`.
- **Multi-Target Prompt Stack (`showPromptStack`):** Shows up to 2 extra nearby candidates below the main prompt; clicking row 2 or 3 triggers `CMD_INTERACT_INDEX` (`302`) (and auto-dismounts if `autoDismount` is enabled) to interact directly with that target.
- **Action-Colored:** Color-codes text and border by verb (`Attack`, `Loot`, `Gather`, `Skin`, `Talk`, `Reel`, `Mailbox`).
- **Customizable:** Draggable on screen (with `lockPrompt` toggle), live preview when `/interact` is open on **Tab 3 (`Prompt & Blacklist`)**, and sliders for `promptX`, `promptY`, `promptScale` (`0.7xРђЊ1.5x`), and `promptAlpha` (`0.2РђЊ1.0`).

### 4. 3D-Projected World Sparkles (`showSparkles`)
- Projects nearby `GameObject` positions from 3D world space onto `WorldFrame` using `Game::WorldToScreen` (`CGCamera` at `CUR_WORLD_FRAME + 0x65B8`) via `CMD_QUERY_SPARKLES` (`303`).
- **Color-Coded Categories (with per-category checkboxes in Tab 3):**
  - **Herbs (`sparkleHerbs`):** Emerald green
  - **Mines (`sparkleMines`):** Icy cyan
  - **Chests (`sparkleChests`):** Gold
  - **Quest Objects (`sparkleQuests`):** Bright amber Рђћ automatically matched against your active Quest Log objectives (`QUEST_LOG_UPDATE`) so books, crates, and quest props sparkle when needed.
- **Projection Calibration (`sparkleFov`):** Adjustable `Sparkle Projection` slider (`40РђЊ150`, default `90`) on Tab 3 to fine-tune vertical projection for custom aspect ratios or FoV mods.

### 5. Classic Blizzard-Style Focus Target Grid (Up to 9 Slots, 3+Ќ3) & Leader Sync
- **C++ GUID Tracking (`400`РђЊ`409`):** Stores `s_focusGuids[9]` in memory and polls live unit data for slots `1..9` without changing your current target.
- **3+Ќ3 Column-Major Grid Layout:**
  - **Column 1:** Focus 1 (`InteractFocusFrame`, master anchor) Рєњ Focus 2 Рєњ Focus 3 stacked vertically.
  - **Column 2:** Focus 4 Рєњ Focus 5 Рєњ Focus 6 placed immediately to the right of Column 1.
  - **Column 3:** Focus 7 Рєњ Focus 8 Рєњ Focus 9 placed immediately to the right of Column 2.
  - **Live 9-Frame Grid Preview & Scaling (`0.40xРђЊ1.50x`):** While `/interact` is open on **Tab 4 (`Focus`)**, all 9 Focus frames are displayed as interactive previews so you can visualize the full 3+Ќ3 footprint and drag **any** of the 9 frames to reposition the entire grid.
- **Compact Mini-Bar Mode (`compactFocus`):** Dynamically switches all 9 Focus frames between the full `232+Ќ100` Blizzard `TargetFrame` and a sleek `148+Ќ42` gold-bordered raid-style bar (Raid Icon + Name + Distance on top, HP% + Combat Icon in the middle, Power bar at the bottom, plus compact auras and castbar underneath).
- **Auto-Populate from Raid Target Marks (`autoFocusMarks` / `/focusmarks`):**
  - `CMD_FOCUS_POPULATE_MARKS` (`409`) reads `Offsets::RAID_TARGET_ICONS` (`0xB71368`) and maps `Skull` (8) Рєњ Focus 1, `Cross` (7) Рєњ Focus 2, `Square` (6) Рєњ Focus 3, `Moon` (5) Рєњ Focus 4, `Triangle` (4) Рєњ Focus 5, `Diamond` (3) Рєњ Focus 6, `Circle` (2) Рєњ Focus 7, and `Star` (1) Рєњ Focus 8.
  - Can run automatically every `0.5s` (`autoFocusMarks`) or on demand via `/focusmarks`, the **Marks** button in Tab 4, or the Minimap right-click menu.
- **Modifier Click-Casting with Spellbook Picker (`focusShiftSpell`, `focusCtrlSpell`, `focusAltSpell`):**
  - Pick any spell directly from your character's Spellbook in `/interact` Рєњ **Focus** for **Shift+Left-Click**, **Ctrl+Left-Click**, and **Alt+Left-Click** (shows live spell icons; Right-Click a picker button to clear).
  - Modifier-clicking any Focus frame (`1..9`) casts that spell directly on that Focus unit via `CMD_FOCUS_SWAP` / `CMD_FOCUS_RESTORE` without losing your current target.
- **Focus Cast / Interrupt Alerts (`focusCastAlert`, `focusCastSound`):**
  - **Flash Frame on Cast (`focusCastAlert`):** Glows and blinks the specific Focus frame (`1..9`) red (border, portrait, and bars in full mode; frame border and background in compact mode) while that unit is casting or channeling a spell.
  - **Sound Alert on Cast Start (`focusCastSound`):** Plays a `RaidWarning` alert when any Focus unit begins casting.
- **Auto-Clear Dead Focus (`autoClearDeadFocus`) & Range/LoS Dimming (`dimOutOfRangeFocus`):**
  - **Auto-Clear Dead Focus:** Automatically clears Focus slots when a non-player target dies (`hp <= 0`), keeping slots free for `/autofocus`.
  - **Dim Out-of-Range / No-LoS:** Dims Focus frames to 45% opacity when the unit is `>40 yd` away or out of Line of Sight.
- **Performance & Hardening:**
  - Unassigned Focus slots skip `CMD_FOCUS_QUERY` polling; LoS raycasts and aura icon formatting are cached for `250ms` per slot in C++.
  - Sparkles scan at `15 Hz` with `30 Hz` animation and early-out when disabled; prompt text/color/keybind lookups are cached in Lua.
  - Synced Focus GUIDs are range-checked, type-validated (`UNIT`/`PLAYER`), rate-limited per leader, and name-sanitized.
- **Party / Raid Leader Addon Sync (`syncFocusGroup`):**
  - When the **Party Leader** (`IsPartyLeader`) or **Raid Leader** (`IsRaidLeader`, rank 2) sets or clears any Focus slot (`1..9`), the exact 64-bit unit GUID (`low32` + `high32` via `CMD_FOCUS_GET_GUID = 408`) and unit name are broadcast over `SendAddonMessage("IM_FOCUS", ...)` on `PARTY` / `RAID`.
  - Group members verify leader authority (`UnitIsPartyLeader` / `GetRaidRosterInfo` rank 2) and call `CMD_FOCUS_SET_GUID` (`407`), overriding local slot assignments with the exact unit GUID (even when multiple mobs share the same name).
  - Leaders can also broadcast all 9 slots at once via `/fsync`, the **Broadcast** button in Tab 4, or the Minimap right-click context menu.
- **`InteractFocusFrame`:** Built with classic Blizzard `TargetFrame` textures (including Elite, Rare, Rare-Elite, and Boss dragon borders), class/creature-type portrait icons, reaction-colored name bar, HP/Power bars, level/combat icon, raid mark icon, distance + `(No LoS)` warning, and `Out of Range` / `Dead` states.
- **Focus Buffs & Debuffs (`showFocusAuras`):** Reads active unit aura slots (`CGUnit_C` descriptors + `SpellIcon.dbc` at `0x00C0D7EC`) and displays up to 8 buffs (row 1) and 8 debuffs (row 2, red border) with stack counts below the Focus frame (configurable in Tab 4).
- **Friendly Party/Raid UnitId Fallback:** When the focused unit is a friendly player in your party or raid (`party1`РђЊ`party4`, `raid1`РђЊ`raid40`), `InteractFocusFrame` also resolves their live UnitId for native Blizzard portrait/cast/aura/range integration.
- **Target-of-Focus (`InteractFocusToTFrame`):** Classic clickable `TargetofTargetFrame` showing who your focus is targeting and their HP% (Left-Click targets your focus's target).
- **Focus Castbar (`InteractFocusCastBar`):** Reads `CGUnit_C` cast/channel spell ID (`0xC8C` / `UNIT_CHANNEL_SPELL`) and `Spell.dbc` (`0x00C0D788`) to display the spell icon, spell name, elapsed time, and cast (gold) vs channel (blue) progress bar.
- **Interactions:** Left-Click to target focus, Shift/Ctrl/Alt+Left-Click to cast bound spell, Right-Click to clear focus, Drag any Focus frame (`1..9`) to move the entire grid when unlocked or when `/interact` is open.

### 6. Profiles, Automation & QoL
- **Quick Profiles:** Built-in `Questing`, `Dungeon / Raid`, `Gathering`, and `City / Safe` presets (with active profile highlighted in green in the top bar).
  - **Left-Click:** Apply profile
  - **Shift+Left-Click:** Save current settings to that profile (`InteractDB.profiles`)
  - **Right-Click:** Reset profile to built-in defaults
- **Safe Reset Confirmation:** Clicking **Reset Defaults** prompts a confirmation dialog (`INTERACT_RESET_CONFIRM`) before clearing custom profiles, settings, and blacklist entries.
- **Per-Character Active Profile:** Stored in `InteractCharDB` (`SavedVariablesPerCharacter`) so each character remembers its own active profile on login.
- **Custom Profiles & Export/Import:** Create, load, and delete custom named profiles, or share settings via `IM1:...` strings.
- **Zone Auto-Switching (`autoProfile`):** Automatically applies `raid` in instances, `city` in capitals, and `questing` elsewhere.
- **Auto-Dismount (`autoDismount`):** Cancels mount buff before interacting with a nearby target.
- **Interact-to-Fish (`interactToFish`) & Interact-to-Mount (`interactToMount`):** Casts `Fishing` with a Fishing Pole equipped, or mounts up out of combat, when pressing Interact with no target in range.
- **Merchant QoL (`autoSellGrey`, `autoRepair`):** Automatically sells poor-quality (grey) items and repairs equipment when opening a vendor.
- **Minimap Button (`showMinimap`):** Draggable button around `Minimap` (Left-Click opens `/interact`, Right-Click opens a context menu with **Broadcast Focus 1..9**, **Clear All Focus (1..9)**, and quick profile switching).
- **Version Reporting (`v2.0.0`):** `INTERACTMOD_VERSION` (`CMD_GET_VERSION = 202`) and `ADDON_VERSION` are displayed in the `/interact` title and printed to chat on `PLAYER_LOGIN`.

---

## Slash Commands & Keybindings

### General (`/interact` or `/im`)
| Command | Description |
| :--- | :--- |
| `/interact` / `/interact ui` | Toggle the 4-tab settings window |
| `/interact status` | Print current configuration |
| `/interact cone <15-180>` | Set cone half-angle (degrees) |
| `/interact range <0-8>` | Set close-proximity radius (yards) |
| `/interact zdiff <0-20>` | Set max vertical Z difference (`0` = off) |
| `/interact cycle <0-10000>` | Set cycle penalty window (ms) |
| `/interact promptpos <x> <y>` | Set prompt frame offset from center |
| `/interact profile <name>` | Apply built-in or custom profile |
| `/interact profilesave <name>` | Save current settings to a profile |
| `/interact profilereset <name\|all>` | Reset built-in profile(s) to defaults |
| `/interact profiledelete <name>` | Delete a custom profile |
| `/interact profilelist` | List built-in and custom profiles |
| `/interact profileexport` / `profileimport <str>` | Export or import `IM1:` profile strings |
| `/interact bl <add\|remove\|last\|list\|clear>` | Manage entry ID blacklist |
| `/interact bltarget` | Blacklist current soft-target (or last GO) |
| `/interact reset` | Reset all settings and blacklist to defaults |

Toggle commands (`[on|off]` optional): `enemies`, `combatloot`, `prioloot`, `players`, `passivenpcs`, `skiplooted`, `pvpooc`, `ownbobber`, `restoretarget`, `raidmarks`, `protectcc`, `prompt`, `lockprompt`, `promptstack`, `critters`, `los`, `cameracone`, `tapped`, `prioquest`, `priolowhp`, `priocasting`, `autoprofile`, `autodismount`, `fish`, `mount`, `sellgrey`, `autorepair`, `minimap`.

Sparkle command: `/interact sparkles [on|off|herbs|mines|chests|quests]` (optionally followed by `on|off`).

### Focus Commands (Slots `1`РђЊ`9`)
| Command | Description |
| :--- | :--- |
| `/focus` / `/focus1`..`/focus9` | Focus current target (or mouseover) into slot 1РђЊ9; `clear` or no target clears (`clearall` clears all 9) |
| `/autofocus` | Assign current target (or mouseover) to the next free/unassigned Focus slot (`1`РђЊ`9`) |
| `/clearfocus` / `/clearfocus1`..`/clearfocus9` | Clear focus slot 1РђЊ9 (`/clearfocus all` clears all 9) |
| `/targetfocus` / `/targetfocus1`..`/targetfocus9` | Target focus unit in slot 1РђЊ9 |
| `/fcast` / `/fcast1`..`/fcast9 <Spell Name>` | Cast spell on focus slot 1РђЊ9 and restore previous target |
| `/focusmarks` / `/fmarks` | Populate Focus 1РђЊ8 from active Raid Target Marks (`Skull` Рєњ 1 .. `Star` Рєњ 8) |
| `/fsync` / `/focussync` | Broadcast all 9 Focus GUID assignments to Party/Raid (Leader only) |

### Keybindings (`Bindings.xml`)
- **Interact** (`Interact_Trigger(0)`)
- **Interact (auto-loot)** (`Interact_Trigger(1)`)
- **Blacklist Current Prompt / Target** (`Interact_BlacklistCurrent()`)
- **Set Focus (Current Target)** (`Interact_SetFocus()`)
- **Clear Focus** (`Interact_ClearFocus()`)
- **Target Focus** (`Interact_TargetFocus()`)

---

## Build & Installation

1. Inject/load `InteractMod.dll` into your WoW 1.12.1 client using your preferred launcher.
2. Copy the contents of `Interact/` (`Interact.toc`, `Interact.lua`, `Focus.lua`, `Sparkles.lua`, `Bindings.xml`) into `<WoW>\Interface\AddOns\Interact\`.
4. Launch WoW and configure bindings under **Key Bindings Рєњ Interact**, or open settings with `/interact` (or the minimap button).
