-- Module script
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationController = require(script.Parent.Controllers.AnimationController)
local VFXController       = require(script.Parent.Controllers.VFXController)

local Animations = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations")

local HitReaction = {}

local lastProcessedAttackId = nil

function HitReaction:Play(data, localPlayer)
	local isAttacker = (data.sourceId == localPlayer.UserId)

	local target = self:_resolveTarget(data.targetId)
	local targetPlayer = target and Players:GetPlayerFromCharacter(target)
	local isVictim = targetPlayer and (targetPlayer == localPlayer)

	if isAttacker then
		self:_tryFOVPunch(data)
	end

	VFXController.PlayHitEffects(target, data)

	self:_playHitAnimation(data, localPlayer, isVictim, isAttacker)
end

-- ─── Private ─────────────────────────────────────────────────────────────────

function HitReaction:_tryFOVPunch(data)
	if not data.attackId or data.attackId == lastProcessedAttackId then return end
	lastProcessedAttackId = data.attackId

	VFXController.FOVPunch(data.isFinisher and 10 or 6, 0.3)
end

function HitReaction:_playHitAnimation(data, localPlayer, isVictim, isAttacker)
	if not data.damage or data.damage <= 0 then return end

	local target = self:_resolveTarget(data.targetId)
	if not target then return end

	local targetPlayer = Players:GetPlayerFromCharacter(target)

	if targetPlayer then
		-- Player victim
		if isVictim then
			AnimationController.Play({ id = "Hit React", slot = "Reaction" })
		end
	else
		-- NPC victim → only the attacker should trigger the animation
		-- (prevents every client in the game from calling LoadAnimation:Play)
		if isAttacker then
			self:_playNPCHitReact(target)
		end
	end
end

function HitReaction:_playNPCHitReact(character)
	local humanoid = character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	if not animator then return end

	local hitAnim = Animations:FindFirstChild("Hit React")
	if not hitAnim then return end

	animator:LoadAnimation(hitAnim):Play()
end

function HitReaction:_resolveTarget(targetId)
	if typeof(targetId) == "number" then
		local p = Players:GetPlayerByUserId(targetId)
		return p and p.Character
	elseif typeof(targetId) == "string" then
		return workspace:FindFirstChild(targetId)
	end
end

return HitReaction
