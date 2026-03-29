-- Module script
-- ─────────────────────────────────────────────────────────────────────────────
-- Location: StarterPlayer.StarterPlayerScripts.Combat.Controllers.AnimationController
-- Purpose: Client-side controller for animation management - handling movement
--          animations (idle, run, jump, fall, land), weapon-specific animations.
-- ─────────────────────────────────────────────────────────────────────────────

local AnimationController = {}

local Animations = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Animations")

local _char, _hum, _animator
local _cache = {}
local _weapon

local _active = {} -- slot → track
local _conns = {}


-- ── helpers ─────────────────────────────────────────────────────

local function track(id)
	if not id then return end
	local t = _cache[id]
	if t then return t end

	local anim = Animations:FindFirstChild(id)
	if not anim then
		warn("Missing anim:", id)
		return
	end

	t = _animator:LoadAnimation(anim)
	_cache[id] = t
	return t
end

local function play(id, slot, loop)
	local t = track(id)
	if not t then return end

	-- stop previous in same slot
	local prev = _active[slot]
	if prev and prev.IsPlaying then
		prev:Stop(0.15)
	end

	_active[slot] = t
	--while prev.IsPlaying do task.wait() end
	if loop ~= nil then t.Looped = loop end
	t:Play()

	return t
end


-- ── movement handling ────────────────────────────────────────────

local function setupMovement()
	local anims = _weapon and _weapon.animations
	if not anims then return end

	-- Running
	_conns[#_conns+1] = _hum.Running:Connect(function(speed)
		if not anims.Run then return end
		if speed > 0.1 then
			play(anims.Run, "Movement", true)
		else
			if anims.Idle then
				play(anims.Idle, "Movement", true)
			end
		end
	end)

	-- Jump / Fall / Land
	_conns[#_conns+1] = _hum.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Jumping and anims.Jump then
			play(anims.Jump, "Movement")
		elseif new == Enum.HumanoidStateType.Freefall and anims.Fall then
			play(anims.Fall, "Movement", true)
		elseif new == Enum.HumanoidStateType.Landed and anims.Land then
			play(anims.Land, "Movement")
		end
	end)
end

local function clearMovement()
	for _, c in ipairs(_conns) do c:Disconnect() end
	table.clear(_conns)
end

local function stopAllAnimatorTracks()
	if not _animator then return end
	for _, track in ipairs(_animator:GetPlayingAnimationTracks()) do
		track:Stop(0.1)
	end
end

-- ── lifecycle ───────────────────────────────────────────────────

function AnimationController.Init(char)
	_char = char
	_hum = char:WaitForChild("Humanoid")
	_animator = _hum:WaitForChild("Animator")

	_active = {}
	clearMovement()
end



-- ── activate / deactivate ────────────────────────────────────────

function AnimationController.Activate(def)
	-- skip if same weapon re-equipped rapidly
	if _weapon == def then return end

	stopAllAnimatorTracks()

	clearMovement()

	_weapon = def
	_active = {}
	
	local animate = _char:FindFirstChild("Animate")
	if animate then animate.Enabled = false end

	setupMovement()
	
	if def.animations then
		for _, animId in pairs(def.animations) do
			if typeof(animId) == "string" then
				track(animId)  -- this calls LoadAnimation and caches the track
			end
		end
	end
	
	if def.comboSteps then
		for stepNumber, data in pairs(def.comboSteps) do
			if data.animation then
				track(data.animation)
			end
		end
	end

	-- default idle
	if def.animations and def.animations.Idle then
		play(def.animations.Idle, "Movement", true)
	end
end

function AnimationController.Deactivate()
	clearMovement()

	for _, t in pairs(_cache) do
		if t.IsPlaying then t:Stop(0.2) end
	end

	_active = {}
	_weapon = nil

	local animate = _char and _char:FindFirstChild("Animate")
	if animate then animate.Enabled = true end
end


-- ── public API ───────────────────────────────────────────────────

function AnimationController.Play(cfg)
	-- default slot = Action
	return play(cfg.id, cfg.slot or "Action", cfg.loop)
end


return AnimationController
