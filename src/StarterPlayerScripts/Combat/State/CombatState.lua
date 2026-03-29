-- ─────────────────────────────────────────────────────────────────────────────
-- Location: StarterPlayer.StarterPlayerScripts.Combat.State.CombatState
-- Purpose: Client-side state management for combo tracking - managing combo steps,
--          weapon definitions, and syncing combo state with the server.
-- ─────────────────────────────────────────────────────────────────────────────

local ComboState = {}
ComboState.__index = ComboState

function ComboState.new()
	return setmetatable({
		step = 0,
		max  = 1,
	}, ComboState)
end

function ComboState:SetWeapon(weaponDef)
	self.step = 0
	self.max  = weaponDef and #weaponDef.comboSteps or 1
end

function ComboState:Next()
	self.step += 1
	if self.step > self.max then
		self.step = 1
	end
	return self.step
end

function ComboState:Reset()
	self.step = 0
end

function ComboState:Sync(step)
	self.step = step or 0
end

return ComboState
