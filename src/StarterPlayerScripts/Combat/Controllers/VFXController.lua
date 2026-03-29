-- Module script
-- Location: StarterPlayer.StarterPlayerScripts.Combat.Controllers.VFXController
-- Owns all visual effects: hit popups, status effect VFX, and FOV punch.
-- No game-state logic lives here — only how things look.

local Debris        = game:GetService("Debris")
local TweenService  = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatusEffectDefs = require(ReplicatedStorage.Shared.Definitions.StatusEffectDefs)

local camera   = workspace.CurrentCamera
local BASE_FOV = camera.FieldOfView

local VFX       = {}
local VFXFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("VFX")

local EFFECT_COLORS = {
	damage  = Color3.fromRGB(255, 68, 21),
	crit    = Color3.fromRGB(141, 0, 0),
	heal    = Color3.fromRGB(80,  220, 120),
	poison  = Color3.fromRGB(160, 80,  220),
	burn    = Color3.fromRGB(255, 140,  30),
	stun    = Color3.fromRGB(255, 240,  80),
	default = Color3.fromRGB(220, 220, 220),
}

local slotTrackers = {}
local activeTween  = nil

-- ─── Public ──────────────────────────────────────────────────────────────────

function VFX.PlayHitEffects(targetChar, data)
	if not targetChar then return end

	VFX._playHitVFX(targetChar)

	if data.damage then
		VFX._spawnPopup(targetChar, tostring(data.damage), data.isFinisher and "crit" or "damage")
	end

	for i, effectId in ipairs(data.effectsToApply or {}) do
		local def = StatusEffectDefs[effectId]
		if not def then continue end

		task.delay(i * 0.08, function()
			VFX._spawnPopup(targetChar, effectId, effectId)
		end)

		if def.vfxId then
			VFX._playStatusVFX(targetChar, def)
			print("There")
		end
		
		
	end
end

function VFX.FOVPunch(amount, duration)
	amount   = amount   or 10
	duration = duration or 0.2

	if activeTween then activeTween:Cancel() end
	camera.FieldOfView = BASE_FOV

	local expand = TweenService:Create(
		camera,
		TweenInfo.new(duration * 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FieldOfView = BASE_FOV + amount }
	)
	local contract = TweenService:Create(
		camera,
		TweenInfo.new(duration * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ FieldOfView = BASE_FOV }
	)

	activeTween = expand
	expand:Play()
	expand.Completed:Once(function()
		if activeTween == expand then
			activeTween = contract
			contract:Play()
		end
	end)
end

-- ─── Private ─────────────────────────────────────────────────────────────────


function VFX._playHitVFX(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local vfx = VFXFolder:WaitForChild("Sword Hit"):Clone()
	if vfx:IsA("Attachment") then
		vfx.Parent = root
		for _, obj in ipairs(vfx:GetDescendants()) do
			if obj:IsA("ParticleEmitter") then obj:Emit(math.random(10, 20)) end
		end
	end
	Debris:AddItem(vfx, 0.5)
end

function VFX._spawnPopup(character, text, kind)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local template = VFXFolder:FindFirstChild("Damage")
	local label    = template and template:FindFirstChild("TextLabel")
	if not label then return end

	local SLOTS, X_SPREAD, Y_DRIFT = 5, 0.12, 0.18
	local isStatus = kind ~= "damage" and kind ~= "crit"
	local Y_START  = isStatus and 0.15 or 0.8

	if not slotTrackers[character] then
		slotTrackers[character] = 1
		character.AncestryChanged:Connect(function()
			if not character:IsDescendantOf(game) then
				slotTrackers[character] = nil
			end
		end)
	end

	local slot = slotTrackers[character]
	slotTrackers[character] = (slot % SLOTS) + 1

	local xPos = 0.5 + ((slot - 1) / (SLOTS - 1) - 0.5) * 2 * X_SPREAD

	local gui = template:Clone()
	local lbl = gui:FindFirstChild("TextLabel")
	lbl.Text             = text
	lbl.TextColor3       = EFFECT_COLORS[kind] or EFFECT_COLORS.default
	lbl.Position         = UDim2.new(xPos, 0, Y_START, 0)
	lbl.AnchorPoint      = Vector2.new(0.5, 0.5)
	lbl.TextTransparency = 0
	lbl.TextSize         = 0
	gui.Parent           = root

	local baseSize = label.TextSize
	TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Back,  Enum.EasingDirection.Out), { TextSize = baseSize }):Play()
	TweenService:Create(lbl, TweenInfo.new(0.9,  Enum.EasingStyle.Quad,  Enum.EasingDirection.Out), { Position = UDim2.new(xPos, 0, Y_START - Y_DRIFT, 0) }):Play()

	task.delay(0.5, function()
		TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
	end)
	Debris:AddItem(gui, 1.2)
end

function VFX._playStatusVFX(character, effectDef)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local template = VFXFolder:FindFirstChild(effectDef.vfxId)
	if not template then return end

	local vfx = template:Clone()
	vfx.Parent = root

	for _, obj in ipairs(vfx:GetDescendants()) do
		if obj:IsA("ParticleEmitter") then
			obj.Enabled = true
		end
	end

	print("success")

	Debris:AddItem(vfx, effectDef.duration or 1)
end

return VFX
