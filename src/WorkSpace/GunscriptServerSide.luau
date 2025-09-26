-- GunScript_Server (Shotgun: 5 shots total, non-lethal stun for 15s)
-- comments are kept simple like student notes

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Module = require(Tool:WaitForChild("Setting"))

-- remotes (don’t rename these)
local ChangeAmmoAndClip = script:WaitForChild("ChangeAmmoAndClip")
local InflictTarget      = script:WaitForChild("InflictTarget")

-- attacker info set on equip
local attackerPlayer
local attackerChar
local attackerHum

-- dual stuff
local leftGripClone
local Handle2

-- basic tool flag
local tool = script.Parent
tool.CanBeDropped = false


-- ammo/clip values (server side)
-- only create once so they persist

local ammoVal = script:FindFirstChild("Ammo")
if not ammoVal then
	ammoVal = Instance.new("NumberValue")
	ammoVal.Name = "Ammo"
	ammoVal.Value = Module.AmmoPerClip -- default (5) on first make
	ammoVal.Parent = script
end

local clipsVal = script:FindFirstChild("Clips")
if not clipsVal then
	clipsVal = Instance.new("NumberValue")
	clipsVal.Name = "Clips"
	clipsVal.Value = Module.LimitedClipEnabled and Module.Clips or 0
	clipsVal.Parent = script
end


-- make animation objects once

if Module.IdleAnimationID ~= nil or Module.DualEnabled then
	local idleAnimObj = Tool:FindFirstChild("IdleAnim") or Instance.new("Animation", Tool)
	idleAnimObj.Name = "IdleAnim"
	idleAnimObj.AnimationId = "rbxassetid://" .. (Module.DualEnabled and 53610688 or Module.IdleAnimationID)
end

if Module.FireAnimationID ~= nil then
	local fireAnimObj = Tool:FindFirstChild("FireAnim") or Instance.new("Animation", Tool)
	fireAnimObj.Name = "FireAnim"
	fireAnimObj.AnimationId = "rbxassetid://" .. Module.FireAnimationID
end

if Module.ReloadAnimationID ~= nil then
	local reloadAnimObj = Tool:FindFirstChild("ReloadAnim") or Instance.new("Animation", Tool)
	reloadAnimObj.Name = "ReloadAnim"
	reloadAnimObj.AnimationId = "rbxassetid://" .. Module.ReloadAnimationID
end

if Module.ShotgunClipinAnimationID ~= nil then
	local clipinAnimObj = Tool:FindFirstChild("ShotgunClipinAnim") or Instance.new("Animation", Tool)
	clipinAnimObj.Name = "ShotgunClipinAnim"
	clipinAnimObj.AnimationId = "rbxassetid://" .. Module.ShotgunClipinAnimationID
end

--========================
-- simple stun (no damage)
--========================
local function stunTarget(h, seconds)
	if not h or h.Health <= 0 then return end

	-- already stunned? just refresh time
	local existing = h:FindFirstChild("Stunned")
	if existing and existing:IsA("NumberValue") then
		existing.Value = tick() + seconds
		return
	end

	-- store when stun ends
	local tag = Instance.new("NumberValue")
	tag.Name  = "Stunned"
	tag.Value = tick() + seconds
	tag.Parent = h

	-- save old movement stuff
	local useJP   = h.UseJumpPower
	local oldWalk = h.WalkSpeed
	local oldJump = useJP and h.JumpPower or h.JumpHeight
	local oldRot  = h.AutoRotate

	-- apply stun
	h.WalkSpeed = 0
	if useJP then h.JumpPower = 0 else h.JumpHeight = 0 end
	h.AutoRotate = false

	-- check each frame, restore when done
	local rs = game:GetService("RunService")
	local conn
	conn = rs.Heartbeat:Connect(function()
		if not h or not tag or tag.Parent ~= h then
			if conn then conn:Disconnect() end
			return
		end
		if tick() >= tag.Value then
			h.WalkSpeed = oldWalk
			if useJP then h.JumpPower = oldJump else h.JumpHeight = oldJump end
			h.AutoRotate = oldRot
			tag:Destroy()
			if conn then conn:Disconnect() end
		end
	end)
end

--========================
-- remote handlers
--========================
ChangeAmmoAndClip.OnServerEvent:Connect(function(plr, ammo, clips)
	-- if you want hard limits, uncomment:
	-- ammo  = math.clamp(ammo, 0, Module.AmmoPerClip)
	-- clips = math.clamp(clips, 0, Module.MaxClip)
	ammoVal.Value  = ammo
	clipsVal.Value = clips
end)

InflictTarget.OnServerEvent:Connect(function(plr, targetHum, targetTorso, dmg, dir, knockback, lifesteal, flaming)
	if plr and targetHum and targetTorso and targetHum.Health > 0 then
		-- add creator tag (kill credit style)
		while targetHum:FindFirstChild("creator") do
			targetHum.creator:Destroy()
		end
		local creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = plr
		creator.Parent = targetHum
		game.Debris:AddItem(creator, 5)

		-- non-lethal: just stun for 15s
		stunTarget(targetHum, 15)

		-- tiny knockback only if provided (usually 0)
		if (knockback or 0) > 0 then
			targetTorso.Velocity = dir * knockback
		end

		-- no TakeDamage, no lifesteal, no fire here
	end
end)

-- dual wield setup

if Module.DualEnabled then
	Handle2 = Tool:WaitForChild("Handle2", 1)
	if not Handle2 then
		error("\"Dual\" is true but \"Handle2\" is missing")
	end
e
