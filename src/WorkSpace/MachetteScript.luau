-- machete (stun 6s, 7 total uses)
-- no damage; durability -1 only on a NEW stun

-- ===== refs =====
local tool   = script.Parent
local handle = tool:WaitForChild("Handle")

local sfx = {
	hit   = handle:WaitForChild("Hit"),
	swing = handle:WaitForChild("Swing"),
}

local Players    = game:GetService("Players")
local Debris     = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- ===== config =====
local STUN_SEC   = 6
local MAX_USES   = 7
local SWING_TIME = 0.8      -- time window where hits count

-- ===== runtime state =====
local state = {
	player   = nil,
	char     = nil,
	hum      = nil,
	hitOnce  = {},           -- who we already hit this swing (set)
	conns    = {},           -- event connections
}

-- ===== durability value on tool =====
local usesVal = tool:FindFirstChild("Durability")
if not usesVal then
	usesVal = Instance.new("IntValue")
	usesVal.Name = "Durability"
	usesVal.Value = MAX_USES
	usesVal.Parent = tool
end

-- quick label update
local function relabel()
	if tool and tool.Parent then
		tool.Name = string.format("Machete (%d/%d durability)", usesVal.Value or 0, MAX_USES)
	end
end
relabel()

-- ===== small helpers =====

-- simple team check
local function sameTeam(p1, p2)
	return p1 and p2 and not p1.Neutral and not p2.Neutral and p1.TeamColor == p2.TeamColor
end

-- creator tag (for credit)
local function credit(hum, plr)
	for _, v in ipairs(hum:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
	local tag = Instance.new("ObjectValue")
	tag.Name = "creator"
	tag.Value = plr
	tag.Parent = hum
	Debris:AddItem(tag, 2)
end

-- fresh-set utility for set table
local function markHitOnce(h)
	state.hitOnce[h] = true
end
local function seenThisSwing(h)
	return state.hitOnce[h] == true
end
local function clearSwingSet()
	for k in pairs(state.hitOnce) do
		state.hitOnce[k] = nil
	end
end

-- play-safe disconnect
local function zapAll()
	for i = 1, #state.conns do
		local c = state.conns[i]
		if c then c:Disconnect() end
		state.conns[i] = nil
	end
end

-- stun and restore when time passes
-- returns true if this created a NEW stun tag (not just refreshing)
local function stun(hum, secs)
	if not hum or hum.Health <= 0 then return false end

	-- refresh existing
	local tag = hum:FindFirstChild("Stunned")
	if tag and tag:IsA("NumberValue") then
		tag.Value = tick() + secs
		return false
	end

	-- make timer
	tag = Instance.new("NumberValue")
	tag.Name = "Stunned"
	tag.Value = tick() + secs
	tag.Parent = hum

	-- save old move stuff
	local useJP = hum.UseJumpPower
	local oldSpeed = hum.WalkSpeed
	local oldJump  = useJP and hum.JumpPower or hum.JumpHeight
	local oldRot   = hum.AutoRotate

	-- freeze
	hum.WalkSpeed = 0
	if useJP then hum.JumpPower = 0 else hum.JumpHeight = 0 end
	hum.AutoRotate = false

	-- watcher (different style: loop in a task)
	task.spawn(function()
		while tag.Parent == hum do
			if tick() >= tag.Value or hum.Health <= 0 then break end
			RunService.Heartbeat:Wait()
		end
		pcall(function() hum.WalkSpeed = oldSpeed end)
		if useJP then
			pcall(function() hum.JumpPower = oldJump end)
		else
			pcall(function() hum.JumpHeight = oldJump end)
		end
		pcall(function() hum.AutoRotate = oldRot end)
		tag:Destroy()
	end)

	return true
end

-- durability -1; destroy if 0
local function spendUseIf(newStun)
	if not newStun then return end
	usesVal.Value = math.max(0, (usesVal.Value or 0) - 1)
	relabel()
	if usesVal.Value <= 0 then
		-- tiny defer to avoid label flicker
		task.defer(function()
			if tool and tool.Parent then tool:Destroy() end
		end)
	end
end

-- ===== swing / hit =====

-- click → play swing, open hit window
local function onActivate()
	-- block if dead or already swinging
	if not tool.Enabled then return end
	if not state.hum or state.hum.Health <= 0 then return end

	tool.Enabled = false
	-- clear hit table and reopen after SWING_TIME
	task.delay(SWING_TIME, function()
		clearSwingSet()
		tool.Enabled = true
	end)

	-- anim + sound
	local chop = state.hum and state.hum:FindFirstChildOfClass("Animator") and nil -- keep animator cache style different
	if state.anim and state.anim.Play then
		-- (guard if anim object exists)
		state.anim:Play()
	end
	sfx.swing:Play()
end

-- handle touch while swing window is open
local function onTouch(part)
	-- only count when tool is "locked" (disabled) → that’s our swing window
	if tool.Enabled then return end
	if not part or not part.Parent then return end

	local hum = part.Parent:FindFirstChildOfClass("Humanoid")
	local shield = part.Parent:FindFirstChildOfClass("ForceField")
	if not hum or hum.Health <= 0 or shield then return end

	-- teammate / already hit this swing? skip
	local victimPlr = Players:GetPlayerFromCharacter(hum.Parent)
	if sameTeam(victimPlr, state.player) or seenThisSwing(hum) then return end

	-- mark as processed for this swing
	markHitOnce(hum)

	-- tag for credit and stun
	credit(hum, state.player)
	local isNew = stun(hum, STUN_SEC)

	-- hit sound
	sfx.hit:Play()

	-- keep original anchoring tweak
	local n = string.lower(part.Name)
	if (not string.find(n, "root") and ((string.find(n, "torso") or string.find(n, "head")) and Random.new():NextNumber(0, 100) <= 50))
		or (not string.find(n, "torso") and not string.find(n, "head") and not string.find(n, "root")) then
		part.Anchored = false
	end

	-- spend durability only on NEW stun
	spendUseIf(isNew)
end

-- ===== equip / unequip =====

local function onEquip()
	state.char   = tool.Parent
	state.player = Players:GetPlayerFromCharacter(state.char)
	state.hum    = state.char and state.char:FindFirstChildOfClass("Humanoid") or nil
	if not state.hum or state.hum.Health <= 0 then return end

	-- load rig-specific animation (ChopR6 / ChopR15, etc.)
	local animObj = tool:WaitForChild("Chop" .. state.hum.RigType.Name)
	state.anim = state.hum:LoadAnimation(animObj)

	state.conns[#state.conns + 1] = tool.Activated:Connect(onActivate)
	state.conns[#state.conns + 1] = handle.Touched:Connect(onTouch)

	relabel()
end

local function onUnequip()
	zapAll()
end

-- ===== wire it =====
tool.Enabled = true
tool.Equipped:Connect(onEquip)
tool.Unequipped:Connect(onUnequip)
