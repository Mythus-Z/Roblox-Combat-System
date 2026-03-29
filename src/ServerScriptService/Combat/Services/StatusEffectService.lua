-- Module script
-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ServerScriptService.Combat.Services.StatusEffectService
-- Purpose: Server-side service that manages status effects on characters -
--          applying, removing, ticking for DoT, and tracking active effects.
-- ─────────────────────────────────────────────────────────────────────────────

local StatusEffectService = {}

local StatusEffectDefs = require(game.ReplicatedStorage.Shared.Definitions.StatusEffectDefs)

-- { [character]: { [effectId]: { expiryTimer, tickThread } } }
local _active = {}


-- Internal state
local function getState(character:Model, effectId:string)
	return _active[character] and _active[character][effectId]
end


-- PUBLIC API
function StatusEffectService.Apply(character, effectId)
	local def = StatusEffectDefs[effectId]
	if not def then
		warn("StatusEffectService: unknown effectId:", effectId)
		return
	end

	if not _active[character] then
		_active[character] = {}
	end

	local existing = _active[character][effectId]
	if existing then
		-- reset duration on re-application regardless
		if existing.expiryTimer then task.cancel(existing.expiryTimer) end
		existing.expiryTimer = task.delay(def.duration, function()
			existing.expiryTimer = nil
			StatusEffectService.Remove(character, effectId)
		end)
		return
	end

	-- first application
	if def.applyFn then def.applyFn(character) end
	character:SetAttribute(effectId, true)

	local state = { expiryTimer = nil, tickThread = nil }
	_active[character][effectId] = state

	if def.tickRate and def.tickRate > 0 then
		state.tickThread = task.spawn(function()
			while _active[character] and _active[character][effectId] do
				task.wait(def.tickRate)
				if _active[character] and _active[character][effectId] then
					def.tickFn(character)
				end
			end
			state.tickThread = nil
		end)
	end

	state.expiryTimer = task.delay(def.duration, function()
		state.expiryTimer = nil
		StatusEffectService.Remove(character, effectId)
	end)
end


function StatusEffectService.Remove(character, effectId)
	local state = getState(character, effectId)
	if not state then return end

	if state.tickThread  then pcall(task.cancel, state.tickThread)  end
	if state.expiryTimer then pcall(task.cancel, state.expiryTimer) end

	_active[character][effectId] = nil
	if next(_active[character]) == nil then
		_active[character] = nil
	end

	local def = StatusEffectDefs[effectId]
	if def then
		if def.removeFn  then def.removeFn(character) end
		character:SetAttribute(effectId, nil)
	end
end

-- Helpers
function StatusEffectService.RemoveAll(character)
	if not _active[character] then return end
	-- iterate a copy since Remove mutates _active[character]
	local active = {}
	for effectId in _active[character] do
		active[effectId] = true
	end
	for effectId in active do
		StatusEffectService.Remove(character, effectId)
	end
end


function StatusEffectService.IsActive(character, effectId)
	return getState(character, effectId) ~= nil
end


function StatusEffectService.GetActive(character)
	local result = {}
	if _active[character] then
		for effectId in _active[character] do
			table.insert(result, effectId)
		end
	end
	return result
end

return StatusEffectService
