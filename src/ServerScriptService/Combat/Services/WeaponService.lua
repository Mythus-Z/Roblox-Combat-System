-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ServerScriptService.Combat.Services.WeaponService
-- Purpose: Server-side service that executes weapon attacks - resolving weapon
--          definitions, performing hit detection, and returning hit results.
-- ─────────────────────────────────────────────────────────────────────────────

local WeaponDefs = require(game.ReplicatedStorage.Shared.Definitions.WeaponDefs)
local HitDetection = require(script.Parent.Parent.Systems.HitDetection)

local WeaponService = {}

function WeaponService.Execute(attackerCharacter, weaponId, comboStep)
	local weapon = WeaponDefs[weaponId]
	if not weapon then
		warn("WeaponService: unknown weaponId:", weaponId)
		return { Hits = {}, EffectsToApply = {} }
	end

	local resolved = WeaponDefs.resolveAttack(weapon, comboStep)
	local hitResults = HitDetection.GetMeleeHits(attackerCharacter, resolved)

	local hits = {}
	local effectsToApply = {}

	for _, hitCharacter in ipairs(hitResults) do
		table.insert(hits, {
			Character = hitCharacter,
			Damage    = resolved.damage,
		})
		for _, effectId in ipairs(resolved.effects) do
			table.insert(effectsToApply, {
				Character = hitCharacter,
				EffectId  = effectId,
			})
		end
	end

	return { Hits = hits, EffectsToApply = effectsToApply }
end

return WeaponService
