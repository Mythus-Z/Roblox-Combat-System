-- Local Script
-- Location: StarterPlayer.StarterPlayerScripts.Combat.CombatController
-- Purpose: Handles client-prediction and the whole client-side pipeline. 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AnimationController = require(script.Parent.Controllers.AnimationController)
local ComboState = require(script.Parent.State.CombatState)
local HitReaction = require(script.Parent.HitReaction)

local WeaponDefs = require(ReplicatedStorage.Shared.Definitions.WeaponDefs)

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local CombatAction = Remotes:WaitForChild("CombatAction")
local CombatResult = Remotes:WaitForChild("CombatResult")

local combo = ComboState.new()
local currentWeapon, currentWeaponDef
local lastAttackTime = 0
local lastServerAttackTime = 0   -- Authoritative cooldown from server

local connections = {}

local function playAnimation(step)
	local attack = WeaponDefs.resolveAttack(currentWeaponDef, step)
	if attack and attack.animation then
		AnimationController.Play({ id = attack.animation })
	end
end

local function equip(tool)
	local def = WeaponDefs[tool.Name]
	if not (def and def.key) then return end

	currentWeapon = tool
	currentWeaponDef = def
	lastAttackTime = 0
	lastServerAttackTime = 0

	combo:SetWeapon(def)
	AnimationController.Activate(def)
end

local function unequip(tool)
	if tool ~= currentWeapon then return end

	AnimationController.Deactivate()
	currentWeapon, currentWeaponDef = nil, nil
	lastAttackTime = 0
	lastServerAttackTime = 0
	combo:Reset()
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not currentWeaponDef then return end
	if input.UserInputType ~= currentWeaponDef.key then return end

	local now = time()
	local attackCooldown = currentWeaponDef.attackCooldown or 0
	local resetTimer = currentWeaponDef.resetTimer or attackCooldown

	-- Use the stricter (more recent) of client prediction and server confirmation
	local effectiveLastAttack = math.max(lastAttackTime, lastServerAttackTime)

	if now - effectiveLastAttack < attackCooldown then return end
	if now - effectiveLastAttack > resetTimer then combo:Reset() end

	local step = combo:Next()
	playAnimation(step)

	lastAttackTime = now   -- optimistic client prediction

	CombatAction:FireServer({ weaponId = currentWeapon.Name })
end)

local function bind(character)
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}

	AnimationController.Deactivate()
	AnimationController.Init(character)

	currentWeapon, currentWeaponDef = nil, nil
	lastAttackTime = 0
	lastServerAttackTime = 0
	combo:Reset()

	connections[1] = character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then equip(child) end
	end)

	connections[2] = character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then unequip(child) end
	end)

	-- check for already equipped tool
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			equip(child)
			break
		end
	end
end

-- initialize
local character = player.Character or player.CharacterAdded:Wait()
bind(character)
player.CharacterAdded:Connect(bind)

CombatResult.OnClientEvent:Connect(function(data)
	local isAttacker = (data.sourceId == player.UserId)

	if isAttacker then
		-- Server confirmed this attack happened → sync authoritative cooldown
		if data.serverAttackTime then
			lastServerAttackTime = data.serverAttackTime
		end

		if data.comboStep ~= combo.step then
			combo:Sync(data.comboStep)
		end
		data.isFinisher = combo.step == combo.max
	end
	
	task.wait(.2)
	HitReaction:Play(data, player)
end)
