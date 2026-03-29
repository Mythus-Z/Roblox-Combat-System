# Deep Dive: Combat System Architecture

## Overview

This is a server-authoritative melee combat framework with optimistic client prediction for responsiveness. The server maintains full control over all critical game state, including damage, hit detection, cooldowns, combo registration, and status effects. The client predicts animations and combo steps locally but cannot influence authoritative outcomes.

**Core principle:** The server decides what happens. The client is responsible for presentation.

---

## System Architecture

The combat system uses a **server-authoritative** model with **optimistic client prediction**. The server owns all critical game state. The client predicts animations and combo steps locally but receives authoritative confirmation via `CombatResult`.

### High-Level Attack Pipeline

```
Player Input
     ↓
CombatController (Client)
   • Check effective cooldown (local + last server time)
   • Advance combo (optimistic)
   • Play attack animation
   • Fire CombatAction → Server
     ↓
ValidationService (Server)
   • Weapon exists?
   • Character alive and not stunned?
   • Cooldown respected?
     ↓ (on failure: silent ignore)
CombatState.RegisterHit (Server)
   • Advance or reset combo step
     ↓
WeaponService.Execute (Server)
   • resolveAttack() → get step-specific stats
   • HitDetection.GetMeleeHits() → box overlap query on cached parts
     ↓
For each hit:
   • CombatState.ApplyDamage()
   • StatusEffectService.Apply() → stun, bleed, etc.
     ↓
CombatResult:FireAllClients (Server)
   • Includes: sourceId, targetId, damage, comboStep, effects, attackId, serverAttackTime
     ↓
All Clients
   • VFXController: Play hit particles + damage/status popups
Attacker Client Only
   • Sync lastServerAttackTime + combo step
   • HitReaction: FOV punch (attacker feedback)
Victim Client Only
   • HitReaction: Play "Hit React" animation
```

### Core Components

**Server**
- `CombatService` — Main controller, handles remotes and orchestration
- `CombatState` — Authoritative combo tracking and damage application
- `ValidationService` — All permission and cooldown checks
- `WeaponService` — Attack execution and data resolution
- `HitDetection` — Spatial queries using cached character parts
- `StatusEffectService` — Applies and manages timed effects (stun, bleed, etc.)

**Client**
- `CombatController` — Input handling, prediction, and remote dispatching
- `CombatState` — Local combo prediction (synced from server results)
- `AnimationController` — Slot-based animation management
- `VFXController` — Particles, FOV punch, damage popups, status visuals
- `HitReaction` — Target resolution and victim/attacker feedback

**Shared**
- `WeaponDefs` — Weapon data and per-step overrides
- `StatusEffectDefs` — Effect definitions and behaviors

**Communication**
- `CombatAction` (Client → Server): Attack request
- `CombatResult` (Server → All Clients): Successful attack broadcast

---

## Module Responsibilities

| Module                | Location | Responsibility                                      | Key Dependencies                  |
|-----------------------|----------|-----------------------------------------------------|-----------------------------------|
| `CombatService`       | Server   | Orchestrates validation, execution, and broadcasting| All other server modules          |
| `ValidationService`   | Server   | Determines whether an action is permitted           | `WeaponDefs`                      |
| `WeaponService`       | Server   | Executes the attack logic                           | `WeaponDefs`, `HitDetection`      |
| `HitDetection`        | Server   | Performs spatial queries to find valid hits         | None                              |
| `StatusEffectService` | Server   | Applies and manages status effects                  | `StatusEffectDefs`                |
| `CombatState`         | Server   | Tracks per-player combo state and applies damage    | None                              |
| `CombatController`    | Client   | Handles input, prediction, and request dispatching  | `WeaponDefs`                      |
| `AnimationController` | Client   | Manages slot-based animation playback               | None                              |
| `VFXController`       | Client   | Handles hit particles, FOV punch, and visual effects| None                              |
| `HitReaction`         | Client   | Resolves targets and triggers victim-side feedback  | `StatusEffectDefs`                |

---

## Security Model

### Server Validation
Every attack request passes through `ValidationService`. On failure the request is silently ignored.

| Check                        | Performed In         | Result on Failure     |
|------------------------------|----------------------|-----------------------|
| Weapon definition exists     | `ValidationService` | Request ignored      |
| Character and Humanoid valid | `ValidationService` | Request ignored      |
| Humanoid is alive            | `ValidationService` | Request ignored      |
| Not currently stunned        | `ValidationService` | Request ignored      |
| Cooldown respected           | `ValidationService` | Request ignored      |

### Client Limitations
The client **cannot**:
- Modify damage values
- Bypass server cooldowns
- Apply status effects or change health
- Override hit detection results

### Client Permissions
The client **can**:
- Detect player input
- Play predictive animations and VFX
- Predict combo steps (non-authoritative)
- Send attack requests

---

## Data Flow – Attack Sequence

1. Player input detected  
2. Client predicts combo step, plays animation, and fires `CombatAction`  
3. Server validates the request (cooldown, state, etc.)  
4. Server registers the combo hit via `CombatState.RegisterHit`  
5. Server executes the weapon via `WeaponService.Execute`  
6. Server performs hit detection  
7. Server applies damage and status effects  
8. Server broadcasts `CombatResult` to all clients (includes `attackId` and `serverAttackTime`)  
9. Attacker client syncs combo state and last server attack time  
10. All clients trigger appropriate hit reactions and VFX on victims

### State Ownership

| State            | Owner   | Client Has Copy?                          |
|------------------|---------|-------------------------------------------|
| Health           | Server  | No (receives only damage numbers)         |
| Combo step       | Server  | Yes (local prediction, synced on result)  |
| Cooldown         | Server  | Yes (local enforcement + server sync)     |
| Status effects   | Server  | Yes (via attributes for VFX)              |
| Position         | Server  | Yes (used locally for prediction)         |

---

## Key Design Decisions

### Hit Detection
`GetPartBoundsInBox` is used instead of `Touched` events.  
- `Touched` fires unpredictably and creates performance overhead.  
- `GetPartBoundsInBox` provides a single, deterministic query using a cached flat list of `HumanoidRootPart`s (players + NPCs tagged "Dummy").

### Weapon Attachment
Weapons use `Motor6D` (named "WeaponGrip") rather than `Weld`.  
The attachment point is determined by an `AttachTo` StringValue inside the Tool. `Motor6D` respects existing character animations and allows the weapon to move naturally with the hand.

### Combo Configuration
The `resolveAttack` pattern allows each combo step to override damage, hitbox size/offset, effects, cooldown, and animation.  
This keeps combo logic data-driven and avoids hardcoded conditional chains.

### Attack ID Deduplication
A single attack can hit multiple targets, generating multiple `CombatResult` events.  
The server uses a simple `attackCounter` and the client debounces effects (such as FOV punch) using `attackId`.

---

## Performance Considerations

**Optimizations in use:**
- Hit detection maintains a cached array of `HumanoidRootPart`s, updated on `CharacterAdded`/`CharacterRemoving`/`Died`
- Animation tracks are cached by ID to avoid repeated `LoadAnimation` calls
- Lightweight `task.spawn` for effect tick threads (e.g., bleed DoT)
- Direct character references in active state tables

**Memory management:**
- Effects are cleaned via expiry timers
- Character part caches are updated on death or removal
- Player state is cleared on `PlayerRemoving`
- VFX instances are managed through Roblox's Debris service

---

## Design Patterns

| Pattern                  | Usage                                      |
|--------------------------|--------------------------------------------|
| Server Authority         | All state mutations and validation         |
| Module Caching           | Animation tracks, character parts, effects |
| Event-Driven             | Remote events and lifecycle connections    |
| Data-Driven Configuration| Weapons and effects defined in tables      |
| Resolver Pattern         | `resolveAttack` merges defaults + overrides|
| Slot-Based Animation     | Separate slots for movement, action, reaction |

---

## Extensibility

The system is designed for replacement or extension of individual modules with minimal impact on others.

| Module                | Extension Examples                                      |
|-----------------------|---------------------------------------------------------|
| `ValidationService`   | Add mana cost, equipment requirements, team checks      |
| `HitDetection`        | Replace with raycasts, sphere casts, or custom shapes   |
| `StatusEffectService` | Implement new effects (silence, root, knockback, etc.)  |
| `WeaponService`       | Add ranged attacks, projectiles, or charge mechanics    |
| `VFXController`       | Swap particle systems or add custom visual layers       |
| `AnimationController` | Introduce new animation slots or blending rules         |

Each module exposes a minimal public API.

---

## Limitations & Future Work

**Current limitations:**
- Melee-focused (no built-in projectile support)
- Box-based hit detection only
- NPCs require the `Dummy` tag for proper handling

**What I'd add next:**
- Projectile system via a new service that reuses existing validation and effect logic
- Alternative hit detection by swapping the `HitDetection` module
- A complete movement system. It improves combat experience massively.
---

## Next Steps

For weapon configuration, API reference, and step-by-step setup instructions, see **[GUIDES.md](GUIDES.md)**.
