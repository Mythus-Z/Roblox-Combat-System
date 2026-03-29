# Usage Guides: Combat System

## Table of Contents

- [Adding A New Weapon](#adding-a-new-weapon)
- [Adding A Status Effect](#adding-a-status-effect)
- [Tool Requirements](#tool-requirements)
- [Animation Setup](#animation-setup)
- [VFX Setup](#vfx-setup)
- [NPC Setup](#npc-setup)
- [Configuration Reference](#configuration-reference)
- [Common Issues & Troubleshooting](#common-issues--troubleshooting)
- [API Reference](#api-reference)

---

## Adding A New Weapon

### Step 1: Add to WeaponDefs.lua

Open `ReplicatedStorage.Shared.Definitions.WeaponDefs.lua` and add your weapon:

```lua
MySword = {
    -- Input
    key = Enum.UserInputType.MouseButton1,
    
    -- Timing
    attackCooldown = 1,
    resetTimer = 2,
    
    -- Damage & Hitbox
    damage = 10,
    hitboxSize = Vector3.new(6, 5, 4),
    hitboxOffset = Vector3.new(0, 0, -3),
    
    -- Animations (movement)
    animations = {
        Idle = "MySword Idle",
        Run = "MySword Run",
        Jump = "MySword Jump"
    },
    
    -- Combo Steps
    comboSteps = {
        [1] = { 
            animation = "MySword Hit 1" 
        },
        [2] = { 
            animation = "MySword Hit 2",
            damage = 12,                    -- Override base
            hitboxSize = Vector3.new(7, 5, 5)
        },
        [3] = { 
            animation = "MySword Finisher",
            damage = 25,
            effects = { "Stun" },
            hitboxSize = Vector3.new(8, 6, 6),
            hitboxOffset = Vector3.new(0, 0, -5),
            attackCooldown = 1.5
        }
    }
}
```

### Step 2: Create The Tool

In `StarterPack` or `ReplicatedStorage`:

1. Create a **Tool** named `MySword` (exactly matches weapon ID)
2. Add a **Handle** part (the visible weapon model)
3. Add a **StringValue** named `AttachTo` → value = `"RightHand"`

### Step 3: Add Animations

Place animation assets in `ReplicatedStorage.Assets.Animations` with the exact names from your config.

### Step 4: Test

Equip the tool. Click to attack. Combo works automatically.

---

## Adding A Status Effect

Open `ReplicatedStorage.Shared.Definitions.StatusEffectDefs.lua` and add your effect:

### Example: Slow Effect

```lua
["Slow"] = {
    duration = 3,
    applyFn = function(character)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 8
        end
    end,
    removeFn = function(character)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end,
    vfxId = "SlowVFX"  -- Optional: reference to VFX attachment
}
```

### Example: Poison (Damage Over Time)

```lua
["Poison"] = {
    duration = 5,
    tickRate = 1,
    tickFn = function(character)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:TakeDamage(2)
        end
    end,
    vfxId = "PoisonVFX"
}
```

### Effect Properties Reference

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `duration` | number | Yes | Seconds effect lasts |
| `applyFn` | function | No | Called when effect is first applied |
| `removeFn` | function | No | Called when effect expires or is removed |
| `tickRate` | number | No | Seconds between tickFn calls |
| `tickFn` | function | No | Called every tickRate (for DoT) |
| `vfxId` | string | No | Reference to VFX attachment in `Assets.VFX` |

---

## Tool Requirements

| Requirement | Why | Example |
|-------------|-----|---------|
| `Tool.Name` matches weapon ID | System looks up weapon by name | `"Sword"` matches `WeaponDefs["Sword"]` |
| `Handle` part | Motor6D connects weapon to character | Any BasePart inside the Tool |
| `AttachTo` StringValue | Tells system which body part to attach to | `"RightHand"`, `"LeftHand"`, `"Back"`, `"Hip"` |

### Example Tool Structure

```
Tool (Name = "Sword")
├── Handle (MeshPart)
├── AttachTo (StringValue, Value = "RightHand")
└── (other parts as needed)
```

### Common AttachTo Values

| Value | Body Part |
|-------|-----------|
| `"RightHand"` | Right hand grip (swords, axes) |
| `"LeftHand"` | Left hand grip (shields) |
| `"Back"` | Back holster (sheathed weapons) |
| `"Hip"` | Hip holster (daggers, pistols) |

---

## Animation Setup

### AnimationController Overview

The `AnimationController` manages all character animations on the client using a **slot-based** system. This prevents animation conflicts between movement, attacks, and hit reactions while ensuring smooth transitions.

**Key Features:**
- Pre-caches all weapon-related animations on equip to avoid runtime `LoadAnimation` calls during combat.
- Uses named **slots** (`Movement`, `Action`, `Reaction`) to allow independent playback and blending.
- Automatically disables Roblox's default `Animate` script when a weapon is equipped.
- Restores the default `Animate` script on weapon unequip.

### Animation Definition Structure

Animations are defined inside `WeaponDefs` under two main tables:

```lua
Sword = {
    key = Enum.UserInputType.MouseButton1,
    
    animations = {                    -- Movement animations
        Idle  = "Sword Idle",
        Run   = "Sword Run",
        Jump  = "Sword Jump",
        -- Fall and Land are optional
    },

    comboSteps = {
        [1] = { animation = "Sword Hit 1" },
        [2] = { animation = "Sword Hit 2" },
        [3] = { 
            animation = "Sword Finisher",
            damage = 15,
            effects = { "Stun" },
            hitboxSize = Vector3.new(7, 5, 7),
            hitboxOffset = Vector3.new(0, 0, -5)
        },
    }
}
```

ReplicatedStorage.Assets.Animations/
├── Sword Idle
├── Sword Run
├── Sword Jump
├── Sword Hit 1
├── Sword Hit 2
├── Sword Finisher
└── Hit React


---

## VFX Setup

### Location
Place VFX attachments in `ReplicatedStorage.Assets.VFX`

### Hit VFX Template Required

The system expects a `Sword Hit` attachment with:

| Component | Purpose |
|-----------|---------|
| ParticleEmitters (multiple) | Dots, flames, lines, stars |
| PointLight | Flash on impact |

### Status Effect VFX

Create attachments with the same name as `vfxId` in your effect definition.

Example for Stun effect (`vfxId = "Stun"`):

```
ReplicatedStorage.Assets.VFX/
└── Stun (Attachment)
    └── ParticleEmitter (Swish effect)
```

---

## NPC Setup

Tag NPC models with `Dummy` using CollectionService:

```lua
-- In a server script
local CollectionService = game:GetService("CollectionService")

-- Tag a single NPC
CollectionService:AddTag(npcModel, "Dummy")

-- Tag all NPCs in a folder
for _, npc in ipairs(workspace.NPCs:GetChildren()) do
    CollectionService:AddTag(npc, "Dummy")
end
```

NPCs with the `Dummy` tag are automatically included in hit detection.

---

## Configuration Reference

### WeaponDefs Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `key` | Enum | Required | Input key (`MouseButton1`, etc.) |
| `attackCooldown` | number | Required | Seconds between attacks |
| `resetTimer` | number | `attackCooldown` | Seconds before combo resets |
| `damage` | number | Required | Base damage |
| `hitboxSize` | Vector3 | Required | Attack area size |
| `hitboxOffset` | Vector3 | `(0,0,-3)` | Position relative to character |
| `effects` | table | `{}` | Status effects applied on every hit |
| `animations` | table | Required | Movement animations (Idle, Run, Jump) |
| `comboSteps` | table | Required | Attack sequence definitions |

### Combo Step Overrides

Each step can override:

| Property | Effect |
|----------|--------|
| `damage` | Different damage per hit |
| `hitboxSize` | Wider arc on later hits |
| `hitboxOffset` | Longer reach on finisher |
| `effects` | Stun only on finisher |
| `attackCooldown` | Slower recovery after finisher |
| `animation` | Different swing animation |

---

## Common Issues & Troubleshooting

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| **Weapon doesn't attach** | `AttachTo` value doesn't match any character part | Check character has a part named exactly what you put in AttachTo |
| **No hit detection on NPCs** | NPC missing `Dummy` tag | Add `CollectionService:AddTag(npc, "Dummy")` |
| **Animations don't play** | Animation name mismatch | Verify animation names match exactly with config |
| **Combo doesn't reset** | `resetTimer` missing or too high | Add `resetTimer` to weapon config or lower value |
| **Stun doesn't lock movement** | Character has no Humanoid | Verify character has a Humanoid |
| **Server ignores attacks** | Cooldown still active | Wait for `attackCooldown` seconds |
| **Effects don't apply** | EffectId doesn't exist in StatusEffectDefs | Check spelling matches exactly |

---

## API Reference

### WeaponDefs

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `resolveAttack` | `weapon, comboStep` | `{damage, animation, hitboxSize, hitboxOffset, effects}` | Merges base weapon with combo step overrides |

### StatusEffectService (Server)

| Function | Parameters | Description |
|----------|------------|-------------|
| `Apply` | `character, effectId` | Applies effect. Refreshes duration if already active |
| `Remove` | `character, effectId` | Removes effect immediately |
| `RemoveAll` | `character` | Removes all effects from character |
| `IsActive` | `character, effectId` | Returns boolean |
| `GetActive` | `character` | Returns array of effectIds |

### CombatState (Server)

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `RegisterHit` | `player, weaponDef` | `step (number)` | Registers hit, updates combo, returns current step |
| `ResetCombo` | `player` | None | Resets combo state |
| `ApplyDamage` | `character, damage` | `remainingHealth` | Applies damage to character |

### CombatState (Client)

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Next` | None | `step` | Increments and returns next combo step |
| `Reset` | None | None | Resets step to 0 |
| `Sync` | `step` | None | Sets step to server value |
| `SetWeapon` | `weaponDef` | None | Sets max steps from weapon |

### HitDetection (Server)

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `GetMeleeHits` | `attackerCharacter, resolvedWeaponDef` | `{Character}` | Returns array of characters hit |

### VFXController (Client)

| Function | Parameters | Description |
|----------|------------|-------------|
| `PlayHit` | `target` | Plays hit VFX on target |
| `FOVPunch` | `amount, duration` | Triggers camera FOV punch |
| `PlayStatusEffectVFX` | `character, effectDef` | Plays effect VFX on character |

### AnimationController (Client)

| Function | Parameters | Description |
|----------|------------|-------------|
| `Init` | `character` | Initializes controller for character |
| `Activate` | `weaponDef` | Switches to weapon animations |
| `Deactivate` | None | Reverts to default animations |
| `Play` | `{id, slot, loop}` | Plays animation in specified slot |

---

## Need More Help?

- Check **[DEEP_DIVE.md](DEEP_DIVE.md)** for architecture and design decisions
- Open an issue on GitHub for bugs or feature requests
- Contact via [Discord](https://discord.com/channels/@me/1068128621190971435)
