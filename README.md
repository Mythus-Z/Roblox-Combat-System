# ⚔️ Combat System

<div align="center">
  <img src="demo-combo.gif" width="600">
  <br>
  <em>A modular, server-authoritative melee combat framework for Roblox</em>
</div>

<br>

<div align="center">
  <img src="https://img.shields.io/badge/Roblox-Studio-00A2FF?style=flat-square&logo=roblox">
  <img src="https://img.shields.io/badge/Language-Luau-00A2FF?style=flat-square">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square">
</div>

---

## 📖 What Is This?

A complete combat system you can drop into any Roblox game.

**You get:**
- Any melee weapon (swords, axes, fists — configure in one file)
- Combo system (2-hit, 3-hit, or custom chains)
- Area hit detection (swing once, hit everything in range)
- Status effects (stun, bleed, or build your own)
- Server security (players can't cheat)

---

## 🎬 See It In Action

| Combo System | Hit Detection | Status Effects |
|:------------:|:-------------:|:--------------:|
| ![Combo](demo-combo.gif) | ![Hit Detection](demo-hitdetection.gif) | ![Status Effects](demo-effects.gif) |

| Visual Feedback |
|:---------------:|
| ![VFX](demo-vfx.gif) |

---

## 🚀 Quick Start (From Scratch)

### 1. Install Scripts
Copy these folders into your Roblox Studio project:
- `ServerScriptService/Combat/`
- `StarterPlayerScripts/Combat/`
- `ReplicatedStorage/Shared/Definitions/`

### 2. Create A Tool
In `StarterPack`, create a Tool named **exactly** what you'll put in WeaponDefs (e.g., "Sword")

The Tool needs:
- A **Handle** part (the visible weapon model)
- A **StringValue** named `AttachTo` — value = which character part to attach to (e.g., "RightHand")

### 3. Configure The Weapon
Open `WeaponDefs.lua` and add your weapon:

```lua
Sword = {
    key = Enum.UserInputType.MouseButton1,
    attackCooldown = 1,
    damage = 10,
    hitboxSize = Vector3.new(6, 5, 4),
    animations = {
        Idle = "Sword Idle",
        Run = "Sword Run"
    },
    comboSteps = {
        [1] = { animation = "Sword Hit 1" },
        [2] = { animation = "Sword Hit 2" },
        [3] = { 
            animation = "Sword Finisher", 
            damage = 25,
            effects = { "Stun" }
        }
    }
}
```

### 4. Add Animations
Place animations in `ReplicatedStorage.Assets.Animations` with the names you used above.

### 5. Tag NPCs (Optional)
Add the `Dummy` tag via CollectionService to any NPCs that should be hittable.

### 6. Play
Equip the tool. Click to attack. Combo works automatically.

> **First time setup:** ~15 minutes. Adding a new weapon: ~5 minutes.

---

## ✨ Features

| Feature | What It Does |
|---------|--------------|
| **Any Melee Weapon** | Configure damage, cooldown, hitbox, animations per weapon |
| **Combo System** | Multi-step chains — finishers hit harder |
| **Area Hit Detection** | Hits everyone in range using box detection |
| **Status Effects** | Stun (locks movement), Bleed (damage over time) |
| **Hit VFX** | Particles + light flash on impact |
| **FOV Punch** | Camera shake on attack — stronger on finishers |
| **NPC Support** | Tag with `Dummy` for automatic hit detection |
| **Server Authority** | All damage and validation on server — no cheating |
| **Modular Design** | Add new mechanics without rewriting core systems |

---

## ⚙️ Configuration Reference

### Weapon Properties (`WeaponDefs.lua`)

| Property | Type | Description |
|----------|------|-------------|
| `key` | Enum | Input key (MouseButton1, etc.) |
| `attackCooldown` | number | Seconds between attacks |
| `resetTimer` | number | Seconds before combo resets |
| `damage` | number | Base damage |
| `hitboxSize` | Vector3 | Attack area size |
| `hitboxOffset` | Vector3 | Position relative to character |
| `animations` | table | Movement animations (Idle, Run, Jump, Fall, Land) |
| `comboSteps` | table | Attack sequence — each step can override damage, hitbox, effects, cooldown, animation |

### Status Effect Properties (`StatusEffectDefs.lua`)

| Property | Type | Description |
|----------|------|-------------|
| `duration` | number | Seconds effect lasts |
| `applyFn` | function | Called when effect is first applied |
| `removeFn` | function | Called when effect expires |
| `tickRate` | number | Seconds between tickFn calls |
| `tickFn` | function | Called every tickRate (for DoT) |
| `vfxId` | string | Reference to VFX attachment |

### Tool Requirements

| Requirement | Why |
|-------------|-----|
| `Tool.Name` matches weapon ID | System looks up weapon by name |
| `Handle` part | Motor6D connects to this |
| `AttachTo` StringValue | Tells system which character part to attach to (e.g., "RightHand", "Back") |

---

## 📁 Project Structure

```
ReplicatedStorage/
├── Shared/
│   ├── Remotes/              # Client-server communication
│   └── Definitions/          # WeaponDefs.lua, StatusEffectDefs.lua
└── Assets/
    ├── Animations/           # Your animation assets
    └── VFX/                  # Particle attachments

StarterPlayerScripts/Combat/
├── CombatController.lua      # Input handling
├── HitReaction.lua           # Victim feedback
├── Controllers/              # AnimationController, VFXController
└── State/                    # Client combo tracking

ServerScriptService/Combat/
├── CombatService.lua         # Main orchestrator
├── Services/                 # Validation, weapons, effects
├── State/                    # Server combo tracking
└── Systems/                  # Hit detection
```

---

## 🧩 Built to Reuse

| Design Choice | Why It Matters |
|---------------|----------------|
| **Data-driven weapons** | New weapon = 5 lines of config |
| **No hardcoded assets** | Change animations without touching code |
| **Clean module boundaries** | Add features without breaking combat |
| **Server owns state** | Client visuals are replaceable — logic stays secure |

---

## 📝 License

MIT — free to use in your games

---

## 🔗 Links

[Portfolio](your-link) • [Live Demo](your-link) • [Report Bug](your-link)

---

---

Ready to copy this into your repo?
