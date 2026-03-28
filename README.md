# ⚔️ Combat System

<div align="center">
  <img src="docs/images/demo.gif" width="600">
  <br>
  <em>A modular, server-authoritative combat framework for Roblox</em>
</div>

<br>

<div align="center">
  <img src="https://img.shields.io/badge/Roblox-Studio-00A2FF?style=flat-square&logo=roblox">
  <img src="https://img.shields.io/badge/Language-Luau-00A2FF?style=flat-square">
  <img src="https://img.shields.io/badge/Modular-Yes-4ecdc4?style=flat-square">
</div>

---

## 🎮 What Is This?

A complete, **modular combat framework** for Roblox. Drop it into your game and get:

- **Any melee weapon** — swords, axes, fists — configure in one file
- **Combo systems** — 2-hit, 3-hit, or custom chains per weapon
- **Area hit detection** — swing once, hit everything in range
- **Status effects** — stun, bleed, slow, or build your own
- **Server security** — all damage and validation happens server-side

Built to be **modular and scalable** — easy to extend when you're ready for new mechanics.

---

## 🎬 See It In Action

| Melee Combat | Hit Detection | Status Effects |
|:------------:|:-------------:|:--------------:|
| [🎥 Watch]() | [🎥 Watch]() | [🎥 Watch]() |
| *Any weapon, any combo* | *Area swing hits all* | *Stun, bleed, + custom* |

| Visual Feedback | Modular Design |
|:---------------:|:--------------:|
| [🎥 Watch]() | |
| *Screen punch + particles* | *Easy to extend* |

---

## 🚀 Quick Start

1. **Copy the scripts** into your Roblox Studio project
2. **Configure your weapon** in `WeaponDefs.lua` (damage, cooldown, hitbox, animations)
3. **Tag NPCs** with `Dummy` for hit detection
4. **Play test** — combat works out of the box

⏱️ Setup time: **5 minutes**

---

## ✨ What's Included

| Feature | What It Does |
|---------|--------------|
| **Any Melee Weapon** | Define damage, cooldown, hitbox, animations per weapon |
| **Combo System** | Multi-step chains per weapon — finishers can have bonus damage/effects |
| **Area Hit Detection** | Box-based detection — hits everyone in range, no single-target limits |
| **Status Effects** | Stun (movement lock), Bleed (DoT), plus extensible framework |
| **Hit VFX** | Particles + light flash on impact, per-weapon configurable |
| **FOV Punch** | Camera shake on attack, configurable strength |
| **Animations** | Weapon-specific movement sets + attack animations per combo step |
| **NPC Support** | Works with any model tagged `Dummy` |
| **Modular Core** | Clean separation between systems — add new mechanics without touching existing code |

---

## 🛠️ Customization

### Add A New Melee Weapon
```lua
-- In WeaponDefs.lua
Axe = {
    key = Enum.UserInputType.MouseButton1,
    attackCooldown = 1.2,
    damage = 8,
    hitboxSize = Vector3.new(7, 6, 5),
    hitboxOffset = Vector3.new(0, 0, -3),
    animations = {
        Idle = "Axe Idle",
        Run = "Axe Run",
        Jump = "Axe Jump"
    },
    comboSteps = {
        [1] = { animation = "Axe Swing 1" },
        [2] = { 
            animation = "Axe Swing 2",
            damage = 12,
            hitboxSize = Vector3.new(8, 6, 6)
        },
        [3] = { 
            animation = "Axe Finisher",
            damage = 20,
            effects = { "Stun" },
            hitboxSize = Vector3.new(9, 7, 7),
            hitboxOffset = Vector3.new(0, 0, -5),
            attackCooldown = 1.5
        }
    }
}
```

> 📝 **Note:** Combo steps inherit all base weapon properties. Override only what you need — damage, hitbox size/offset, effects, attackCooldown, and animation per step.

### Create A New Status Effect
```lua
-- In StatusEffectDefs.lua
["Slow"] = {
    duration = 3,
    applyFn = function(char)
        char.Humanoid.WalkSpeed = 8
    end,
    removeFn = function(char)
        char.Humanoid.WalkSpeed = 16
    end
}
```

### Extend The System
The framework is split into independent modules:
- `ValidationService` — add new validation rules
- `HitDetection` — swap or extend detection logic
- `StatusEffectService` — add effect types
- `WeaponService` — add ranged attacks, projectiles, etc.

Each piece can be extended or replaced without touching the rest.

---

## 📊 How It Works

```
[Player Attacks] → [Client Shows Animation] → [Server Validates]
                                                     ↓
[Screen Punch]  ← [Client Shows Hit]        ← [Server Applies Damage]
```

**Why this matters:**
- Server decides who gets hit — no cheating
- Client feels responsive — instant feedback
- Clean separation means you can extend safely

---

## 📁 What You Get

```
📁 Combat System/
├── 📁 Client Scripts    (animations, VFX, input — replaceable)
├── 📁 Server Scripts    (damage, hit detection, validation — stable core)
├── 📁 Shared Configs    (weapon stats, effect definitions — your playground)
└── 📁 Assets            (animation templates, VFX templates)
```

---

## 🔗 For Developers

Want to understand the internals or extend the system?

- **[Technical Architecture](docs/technical/architecture.md)** — how modules connect
- **[API Reference](docs/technical/api-reference.md)** — all functions and parameters
- **[Adding Weapons](docs/technical/adding-weapons.md)** — melee, ranged, custom
- **[Adding Status Effects](docs/technical/adding-effects.md)** — create new effects
- **[Security Model](docs/technical/security-model.md)** — how cheating is prevented
- **[Full Source Code](src/)** — commented scripts

---

## 📝 License

MIT — free to use in your games

---

## 🔗 Links

[Portfolio](your-link) • [Live Demo](your-link) • [Report Bug](your-link)

---
