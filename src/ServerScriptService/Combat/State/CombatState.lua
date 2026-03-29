-- Module script
-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ServerScriptService.Combat.State.CombatState
-- Purpose: Server-side state management for combat - tracking player combo steps,
--          registering hits, resetting combos, and applying damage to characters.
-- ─────────────────────────────────────────────────────────────────────────────

local _combos = {} -- [Player]: { step: number, timer: thread | nil }

local CombatState = {}


function CombatState.Init(player:Player)
	if not player then return end

	if _combos[player] then 
		_combos[player].step = 0
		_combos[player].lastHitTime = 0
		return 
	end
	
	local character = player.Character or player.CharacterAdded:Wait()
	local Humanoid = character:FindFirstChild("Humanoid")
	if not Humanoid then return end
	
	local state = {
		step = 0,
		lastHitTime = 0,
	}
	
	_combos[player] = state
	
	-- Connections
	Humanoid.Died:Connect(function()
		CombatState.ResetCombo(player)
	end)
end

game.Players.PlayerRemoving:Connect(function(player)
	_combos[player] = nil
end)

function CombatState.RegisterHit(player: Player, weaponDef: any)
	local state = _combos[player]
	if not state then return end

	local now = os.clock()

	-- if the combo is expired, or we've reached the last step, reset combo
	local resetTimer = weaponDef.resetTimer or weaponDef.attackCooldown or 1 -- safety in case resetTimer isn't defined
	if now - state.lastHitTime > resetTimer
		or state.step == #weaponDef.comboSteps then
		state.step = 0
	end

	state.step += 1
	state.lastHitTime = now

	return state.step
end


function CombatState.ResetCombo(player:Player)
	local state = _combos[player]
	if not state then return end
	
	state.step = 0
	state.lastHitTime = 0
end


function CombatState.ApplyDamage(character: Model, damage: number)
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	humanoid:TakeDamage(damage)
	return humanoid.Health
end

return CombatState
