-- ─────────────────────────────────────────────────────────────────────────────
-- Location: ReplicatedStorage.Shared.Definitions.StatusEffectDefs
-- Purpose: Defines status effect configurations (Stun, Slow, Bleed) including
--          durations, apply/remove functions, and tick functions for DoT.
-- ─────────────────────────────────────────────────────────────────────────────

local StatusEffectDefs = {}

StatusEffectDefs["Stun"] = {
	duration = 2,
	applyFn = function(character)
		local Humanoid = character:FindFirstChild("Humanoid")
		if Humanoid and not character:GetAttribute("OriginalWalkSpeed") then
			character:SetAttribute("OriginalWalkSpeed", Humanoid.WalkSpeed)
			Humanoid.WalkSpeed = 0
		end
	end,
	removeFn = function(character)
		local Humanoid = character:FindFirstChild("Humanoid")
		local original = character:GetAttribute("OriginalWalkSpeed")
		if Humanoid and original then
			Humanoid.WalkSpeed = original
			character:SetAttribute("OriginalWalkSpeed", nil)
		end
	end,
	-- tick not required
	vfxId = "Stun" -- Lives in ReplicatedStorage/Assets/VFX
}

StatusEffectDefs["Bleed"] = {
	duration = 5,
	tickRate = .5,
	tickFn = function(character:Model)
		local Humanoid = character:FindFirstChild("Humanoid")
		if Humanoid then
			if math.random() > .5 then return end
			
			Humanoid:TakeDamage(10)

			-- 30% chance it'll spawn
			-- spawn blood
			local bloodPart = Instance.new("Part", workspace)
			bloodPart.Size = Vector3.new(3, 0.1, 3)
			bloodPart.Position = character:GetPivot().Position + Vector3.new(0, 0.25, 0)
			bloodPart.Anchored = true
			bloodPart.CanCollide = false
			bloodPart.Transparency = .3
			bloodPart.Material = Enum.Material.Neon
			bloodPart.BrickColor = BrickColor.new("Crimson")
			game.Debris:AddItem(bloodPart, 10)
		end
	end,
	-- VFX can be added. I didn't add it
}
return StatusEffectDefs
