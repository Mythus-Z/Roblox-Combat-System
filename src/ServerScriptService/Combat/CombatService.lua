-- Server script (entry point)
-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ServerScriptService.Combat.CombatService
-- Purpose: Server-side combat system controller that handles character lifecycle,
--          weapon attachment via Motor6D, combat action validation, damage
--          application, status effects, and broadcasts combat results to clients.
-- ─────────────────────────────────────────────────────────────────────────────

local Players       = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- shortcuts
local p, r = script.Parent, game.ReplicatedStorage.Shared.Remotes

local ValidationService = require(p.Services.ValidationService)
local WeaponService = require(p.Services.WeaponService)
local StatusEffectService = require(p.Services.StatusEffectService)
local CombatState = require(p.State.CombatState)
local WeaponDefs = require(ReplicatedStorage.Shared.Definitions.WeaponDefs)

local CombatAction = r.CombatAction
local CombatResult = r.CombatResult


-- ── character lifecycle ──────────────────────────────────────────

local function onCharacterAdded(player, character)
	CombatState.Init(player)

	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		StatusEffectService.RemoveAll(character)
	end)

	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			CombatState.ResetCombo(player)
			
			local motor = character:FindFirstChild("WeaponGrip", true)
			if motor then motor:Destroy() end
		end
	end)

	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			local handle = child:FindFirstChild("Handle")
			local attachToName = child:FindFirstChild("AttachTo")

			if not handle or not attachToName then
				warn(`Tool "{child.Name}" missing Handle or AttachTo`)
				return
			end

			local attachToPart:Part = character:FindFirstChild(attachToName.Value)
			if not attachToPart then
				warn(`Part "{attachToName.Value}" not found on character`)
				return
			end

			-- Remove existing motor if any
			local existing = character:FindFirstChild("WeaponGrip", true)
			if existing then existing:Destroy() end

			local motor = Instance.new("Motor6D")
			motor.Name = "WeaponGrip"
			motor.Part0 = attachToPart
			motor.Part1 = handle
			motor.C0 = attachToPart.CFrame:Inverse() * handle.CFrame
			motor.C1 = CFrame.new(0, 0, 0) -- adjust as needed
			motor.Parent = character
			
			for _, child in attachToPart:GetChildren() do
				if child:IsA("Weld") then
					child:Destroy()
				end
			end
		end
	end)
end

local function onCharacterRemoving(player, character)
	CombatState.ResetCombo(player)
	StatusEffectService.RemoveAll(character)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	player.CharacterRemoving:Connect(function(character)
		onCharacterRemoving(player, character)
	end)

	-- handle character already in game (Studio play solo)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end
end


Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end


local attackCounter = 0
CombatAction.OnServerEvent:Connect(function(player, data)

	-- Step 1 — resolve weapon
	local weaponDef = WeaponDefs[data.weaponId]
	if not weaponDef then
		warn("CombatServer: unknown weaponId:", data.weaponId)
		return
	end

	-- Step 2 — validate
	local result = ValidationService.Check(player, data.weaponId)
	if not result.ok then
		if result.reason then warn(result.reason) end
		return
	end

	-- Step 3 — register combo hit
	local comboStep = CombatState.RegisterHit(player, weaponDef)
	
	-- Step 4 — execute weapon
	local weaponResult = WeaponService.Execute(player.Character, data.weaponId, comboStep)
	--- Step 5 — apply damage, effects, and broadcast per hit
	attackCounter += 1
	local serverAttackTime = time()   -- Authoritative timestamp for cooldown sync

	for _, hit in ipairs(weaponResult.Hits) do
		CombatState.ApplyDamage(hit.Character, hit.Damage)

		local appliedEffects = {}
		for _, fx in ipairs(weaponResult.EffectsToApply) do
			if fx.Character == hit.Character then
				StatusEffectService.Apply(fx.Character, fx.EffectId)
				table.insert(appliedEffects, fx.EffectId)
			end
		end

		local targetId = hit.Character.Name
		local targetPlayer = Players:GetPlayerFromCharacter(hit.Character)
		if targetPlayer then
			targetId = targetPlayer.UserId
		end

		CombatResult:FireAllClients({
			sourceId       = player.UserId,
			targetId       = targetId,
			damage         = hit.Damage,
			comboStep      = comboStep,
			effectsToApply = appliedEffects,
			attackId       = attackCounter,
			serverAttackTime = serverAttackTime   -- ← Added for client cooldown sync
		})
	end
end)
