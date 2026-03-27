# ⚔️ Combat System

[DEMO GIF HERE]

A responsive combat system for Roblox with 3-hit combos, hit detection, and status effects.

---

## 🎮 What It Looks Like

[GIF of combat in action]

**Core features:**
- 3-hit sword combo — finisher deals heavy damage + stun
- Hit VFX and screen punch on attack
- Enemies react with hit animations
- Status effects (stun, bleed)

---

## 🏗️ How It Works

**Server handles:** Damage, cooldowns, hit detection, status effects
**Client handles:** Input, animations, visual feedback

[Simple architecture diagram here]

---

## 📁 Files

| File | What It Does |
|------|--------------|
| `CombatController` | Detects clicks, sends attacks to server |
| `HitDetection` | Finds enemies in weapon hitbox |
| `StatusEffectService` | Applies stun, bleed over time |
| `WeaponDefs` | Damage, cooldown, combo settings |

---

## 🚀 Quick Start

1. Copy scripts to:
   - `ServerScriptService/Combat/`
   - `StarterPlayerScripts/Combat/`
   - `ReplicatedStorage/Shared/Definitions/`
2. Add animations to `ReplicatedStorage/Assets/Animations`
3. Add VFX to `ReplicatedStorage/Assets/VFX`

---

## 🔧 Customization

**Edit weapon stats in `WeaponDefs.lua`:**
```lua
damage = 10,
attackCooldown = 1,
comboSteps = { ... }
