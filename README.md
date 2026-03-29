# ⚔️ Combat System

<div align="center">
  <img src="docs/images/demo.gif" width="600">
  <br>
  <em>A modular, server-authoritative combat framework for Roblox. Drop it in. Configure weapons. Start fighting.</em>
</div>

<br>

<div align="center">
  <img src="https://img.shields.io/badge/Roblox-Studio-00A2FF?style=flat-square&logo=roblox">
  <img src="https://img.shields.io/badge/Language-Luau-00A2FF?style=flat-square">
  <img src="https://img.shields.io/badge/Modular-Yes-4ecdc4?style=flat-square">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square">
</div>

---

## 📖 About

**No more hardcoded combat.** This framework gives you:

- **Any melee weapon** — swords, axes, fists — configure in one file
- **Combo systems** — 2-hit, 3-hit, or custom chains per weapon  
- **Area hit detection** — swing once, hit everything in range
- **Status effects** — stun, bleed, slow, or build your own
- **Server security** — all damage and validation happens server-side

Built to be **modular and scalable** — add new mechanics without rewriting core systems.

🔗 **Live Demo:** [Play the Game](#)

---

## 🎬 Demos

| Combo System | Hit Detection | Status Effects |
|:------------:|:-------------:|:--------------:|
| ![](docs/images/demos/combo.gif) | ![](docs/images/demos/hit-detection.gif) | ![](docs/images/demos/status.gif) |

| Visual Feedback | 
|:---------------:|
| ![](docs/images/demos/vfx.gif) |

---

## Quick Start (From Scratch)

1. Copy scripts into your project
2. Create a Tool in StarterPack named "Sword"
3. Add a Handle part to the tool
4. Add StringValue named "AttachTo" → value = "RightHand"
5. Configure weapon stats in `WeaponDefs.lua`
6. Play
