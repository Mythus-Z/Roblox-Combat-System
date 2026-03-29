-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ServerScriptService.Combat.Services.ValidationService
-- Purpose: Server-side service that validates combat actions - checking if
--          player has character, is alive, not stunned, and respecting cooldowns.
-- ─────────────────────────────────────────────────────────────────────────────

local ValidationService = {}
local WeaponDefs = require(game.ReplicatedStorage.Shared.Definitions.WeaponDefs)

local _lastAttack = {}

game.Players.PlayerRemoving:Connect(function(player)
	_lastAttack[player] = nil
end)


-- Called when a player attempts to use a weapon
function ValidationService.Check(player, weaponId)
	local result = {ok = false, reason = nil}
	local character = player.Character
	local weapon = WeaponDefs[weaponId]
	if not weapon then
		result.reason = "invalid weapon"
		return result
	end
	if not character then
		result.reason = "no character"
		return result
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		result.reason = "dead"
		return result
	end
	if character:GetAttribute("Stunned") then
		result.reason = "stunned"
		return result
	end
	
	local lastAttack = _lastAttack[player] or 0
	if os.clock() - lastAttack < weapon.attackCooldown then
		result.reason = "cooldown"
		return result
	else
		_lastAttack[player] = os.clock()
	end
	result.ok = true
	return result
end

return ValidationService
