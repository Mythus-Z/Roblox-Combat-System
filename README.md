# Roblox Combat System

Authoritative server-side combat system with combos, hit detection, and status effects.

## Features
- 3-hit sword combo with finisher
- Box-based hit detection
- Stun and bleed effects
- Client-side visual feedback (FOV punch, hit VFX)

## Architecture
Server handles validation, damage, and effects. Client handles input and visuals.

## Setup
1. Copy scripts to appropriate locations
2. Ensure animations/VFX are in ReplicatedStorage/Assets

## Scripts

### Server
- `CombatService` — Orchestrates combat
- `ValidationService` — Cooldown/stun checks
- `WeaponService` — Hit execution
- `StatusEffectService` — Effect management
- `HitDetection` — Spatial queries

### Client
- `CombatController` — Input handling
- `AnimationController` — Animation playback
- `VFXController` — Visual effects
- `HitReaction` — Victim feedback
