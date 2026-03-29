# ⚔️ Combat System

<div align="center">
  <img src="assets/demo-combo.gif" width="600">
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
- ✅ Any melee weapon — swords, axes, fists (configure in one file)
- ✅ Combo system — 2-hit, 3-hit, or custom chains
- ✅ Area hit detection — swing once, hit everything in range
- ✅ Status effects — stun, bleed, or build your own
- ✅ Server security — players can't cheat

**Setup time:** ~15 minutes for first weapon, ~5 minutes for each additional

---


## 🎬 See It In Action

| Combo System | Visual Feedback | Custom Animations Supported |
|:------------:|:-------------:|:--------------:|
| ![Combo system](https://github.com/user-attachments/assets/6d705211-ddff-4c1f-95bb-78a8616a945f) |  ![VFX](https://github.com/user-attachments/assets/343642fb-578e-4f35-b1d4-6df3338fc2b3) | ![Custom weapon animations](https://github.com/user-attachments/assets/5e354cd1-c93e-474c-80e6-48d9b6f82c95) |

 | Hit Detection | Status Effects (Example1) | Status Effect (Example2) | 
|:------------:|:-------------:|:--------------:|
| ![Hit Detection](https://github.com/user-attachments/assets/c95ab856-5660-43b0-b8bc-f89f23bc78f4) | ![Status Effects (Example)](https://github.com/user-attachments/assets/c7707459-2ffe-474d-b5ec-52c1c75fbc66) | ![Bleed status effect](https://github.com/user-attachments/assets/835bfa47-9471-47c2-9012-6779a3c12b54)

| Server-Authoritative Cooldown | Note
|:---------------:|:--------------:|
| ![Server authoritative Cooldown](https://github.com/user-attachments/assets/1344c7aa-3ae7-4b0b-9f1c-9cae9b164c6b) | Design insight: Two guards are there for validation. First is Client-prediction guard in local context, which is there for avoiding unnecessary operations and responsiveness. Second, and the real guard/validator running on server, immune to exploits. |

---

## ✨ Features

| Feature | What It Does |
|---------|--------------|
| **Any Melee Weapon** | Damage, cooldown, hitbox, animations — all configurable per weapon |
| **Combo System** | Multi-step chains — finishers hit harder |
| **Area Hit Detection** | Hits everyone in range using box detection |
| **Status Effects** | Stun (locks movement), Bleed (damage over time) |
| **Hit VFX** | Particles + light flash on impact |
| **FOV Punch** | Camera shake on attack — stronger on finishers |
| **NPC Support** | Tag with `Dummy` for automatic hit detection |
| **Server Authority** | All damage and validation on server — no cheating |

---

## 🧩 Built to Reuse

- **New weapon?** Add one table entry to `WeaponDefs.lua`. No code changes.
- **New effect?** Write `applyFn` and `removeFn`. Core untouched.
- **Different weapon grip?** Change `AttachTo` value and use appropriate Motor6D joints with the weapon to create custom animations.
- **Want projectiles?** Swap `HitDetection` module. Everything else works.

**The system is designed to be adaptable to most kinds of combat systems. Originally it's inspired by medieval-style combat**

---

## 🚀 Quick Start

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

---

## 📁 What's Inside

```
ReplicatedStorage/
├── Shared/Definitions/     # Weapon + effect configs (your playground)
└── Assets/                 # Animations + VFX (your assets)

StarterPlayerScripts/Combat/
├── CombatController.lua    # Input handling
├── HitReaction.lua         # Victim feedback
├── Controllers/            # Animation + VFX
└── State/                  # Client combo tracking

ServerScriptService/Combat/
├── CombatService.lua       # Main orchestrator
├── Services/               # Validation, weapons, effects
├── State/                  # Server combo tracking
└── Systems/                # Hit detection
```

---

## 📚 More Documentation

- **[DEEP_DIVE.md](DEEP_DIVE.md)** — Architecture, security model, design decisions
- **[GUIDES.md](GUIDES.md)** — Weapon config, status effects, setup, API reference

---

## 📝 License

MIT — free to use in your games

---

## 🔗 Links

[Discord](https://discord.com/channels/@me/1068128621190971435)


---

Ready for **Layer 2: DEEP_DIVE.md**?
