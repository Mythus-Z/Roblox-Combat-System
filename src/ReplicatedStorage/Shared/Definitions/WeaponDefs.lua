-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ReplicatedStorage.Shared.Definitions.WeaponDefs
-- Purpose: Defines weapon configurations including attack cooldowns, damage,
--          hitbox sizes, combo steps, animations, and resolveAttack function.
-- ─────────────────────────────────────────────────────────────────────────────

local WeaponDefs = {

	Sword = {
		key = Enum.UserInputType.MouseButton1,
		attackCooldown  = 1,
		resetTimer      = 2, -- Starts with attackCooldown
		damage          = 2,
		hitboxSize      = Vector3.new(6, 5, 4),
		hitboxOffset    = Vector3.new(0, 0, -6), -- additional offset in look direction
		effects         = {},
		
		animations = { -- Stores movement related animations
			Idle = "Sword Idle",
			Run = "Sword Run",
			Jump = "Sword Jump"
		},

		comboSteps = {
			[1] = {
				animation     = "Sword Hit 1",

			},
			[2] = {
				animation  = "Sword Hit 2",
			},
			[3] = {
				animation  = "Sword Finisher",
				effects      = { "Stun" },
				damage       = 15,
				hitboxSize   = Vector3.new(7, 5, 7),
				hitboxOffset = Vector3.new(0, 0, -5),
			},
		},
	},

}


function WeaponDefs.resolveAttack(weapon, comboStep)
	local step = weapon.comboSteps and comboStep and weapon.comboSteps[comboStep]

	local hitboxSize   = (step and step.hitboxSize)   or weapon.hitboxSize
	local hitboxOffset = (step and step.hitboxOffset) or weapon.hitboxOffset
	
	if not hitboxOffset then
		hitboxOffset = Vector3.new(0, 0, -3)  -- default offset
	end

	return {
		damage      = (step and step.damage)      or weapon.damage,
		animation = (step and step.animation) or weapon.animation,
		hitboxSize  = hitboxSize,
		hitboxOffset = hitboxOffset,
		effects     = (step and step.effects)     or weapon.effects or {},
	}
end

table.freeze(WeaponDefs)
return WeaponDefs
