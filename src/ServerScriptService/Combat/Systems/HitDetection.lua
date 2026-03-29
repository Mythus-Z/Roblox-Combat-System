-- Module script
-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ServerScriptService.Combat.Systems.HitDetection
-- Purpose: Server-side hit detection system using spatial queries (GetPartBoundsInBox)
--          to find characters within weapon hitboxes, caching character parts.
-- ─────────────────────────────────────────────────────────────────────────────

local HitDetection = {}

local DEBUG = false

local Players = game:GetService("Players")

-- cached flat table of HumanoidRootParts, updated only on character events
local characterParts = {}

for _, model in game.CollectionService:GetTagged("Dummy") do
	if not model:IsA("Model") then continue end
	if not model:FindFirstChildOfClass("Humanoid") then continue end
	if not model:FindFirstChild("HumanoidRootPart") then continue end
	table.insert(characterParts, model.HumanoidRootPart)
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = characterParts


local function addCharacter(character)
	local root = character:WaitForChild("HumanoidRootPart")
	if not root then return end
	table.insert(characterParts, root)
	overlapParams.FilterDescendantsInstances = characterParts
end

local function removeCharacter(character)
	for i, part in ipairs(characterParts) do
		if part.Parent == character then
			table.remove(characterParts, i)
			overlapParams.FilterDescendantsInstances = characterParts
			return
		end
	end
end



local function onPlayerAdded(player)
	-- handle character spawns and respawns
	player.CharacterAdded:Connect(function(character)
		addCharacter(character)

		-- remove on death so dead characters can't be hit
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			removeCharacter(character)
		end)
	end)

	-- handle character already in game when this connection fires
	if player.Character then
		addCharacter(player.Character)
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				removeCharacter(player.Character)
			end)
		end
	end
end

local function onPlayerRemoving(player)
	if player.Character then
		removeCharacter(player.Character)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

local function spawnHitBox(hitboxSize, boxCFrame)
	local part = Instance.new("Part", workspace)
	part.Size = hitboxSize
	part.CFrame = boxCFrame
	part.BrickColor = BrickColor.new("Really red")
	part.Anchored = true
	part.Material = Enum.Material.ForceField
	part.CanCollide = false
	game.Debris:AddItem(part, .3)

end
-- Main function
function HitDetection.GetMeleeHits(attackerCharacter, resolvedWeaponDef)
	local root = attackerCharacter:FindFirstChild("HumanoidRootPart")
	if not root then return {} end

	local boxCFrame = root.CFrame
		+ root.CFrame:VectorToWorldSpace(resolvedWeaponDef.hitboxOffset)

	local parts = workspace:GetPartBoundsInBox(
		boxCFrame,
		resolvedWeaponDef.hitboxSize,
		overlapParams
	)
	
	if DEBUG then
		spawnHitBox(resolvedWeaponDef.hitboxSize, boxCFrame)

	end
	
	local seen = {}
	local characters = {}

	for _, part in ipairs(parts) do
		local character = part:FindFirstAncestorOfClass("Model")
		if not character then continue end
		if character == attackerCharacter then continue end
		if seen[character] then continue end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then continue end
		seen[character] = true
		table.insert(characters, character)
	end

	return characters
end

return HitDetection
