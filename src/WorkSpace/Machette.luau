-- machete tool script
-- stuns people for 6s instead of damage
-- tool has 7 uses (durability goes down each time)

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local Sounds = {
	Hit   = Handle:WaitForChild("Hit"),
	Swing = Handle:WaitForChild("Swing"),
}

local Animations = {}

local Services = {
	Players = game:GetService("Players"),
	Debris  = game:GetService("Debris"),
	Run     = game:GetService("RunService"),
}

local connections = {}

local Player, Character, Humanoid

-- settings
local STUN_DURATION = 6
local MAX_DURABILITY = 7

-- durability value on the tool
local Durability = Tool:FindFirstChild("Durability")
if not Durability then
	Durability = Instance.new("IntValue")
	Durability.Name = "Durability"
	Durability.Value = MAX_DURABILITY
	Durability.Parent = Tool
end

-- updates the name to show current durability
local function updateToolName()
	if Tool and Tool.Parent then
		Tool.Name = string.format("Machete (%d/%d durability)", Durability.Value or 0, MAX_DURABILITY)
	end
end
updateToolName()

-- destroy tool when durability is gone
local function destroyToolSoon()
	updateToolName()
	task.defer(function()
		if Tool and Tool.Parent then
			Tool:Destroy()
		end
	end)
end

-- checks if two players are on same team
local function isTeammate(p1, p2)
	return (p1 and p2 and not p1.Neutral and not p2.Neutral and p1.TeamColor == p2.TeamColor)
end

-- tag used for kill credit
local function tagHumanoid(hum, plr)
	local tag = Instance.new("ObjectValue")
	tag.Name = "creator"
	tag.Value = plr
	Services.Debris:AddItem(tag, 2)
	tag.Parent = hum
end

-- remove old tags
local function untagHumanoid(hum)
	for _, v in pairs(hum:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

-- simple table check
local function contains(tbl, value)
	for _, v in pairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

-- apply stun, stop movement/jump
-- only eats durability if this is a new stun
local function applyStun(h, seconds)
	if not h or h.Health <= 0 then return false end

	local existing = h:FindFirstChild("Stunned")
	if existing then
		existing.Value = tick() + seconds
		return false
	end

	local stamp = Instance.new("NumberValue")
	stamp.Name = "Stunned"
	stamp.Value = tick() + seconds
	stamp.Parent = h

	local usesJumpPower = h.UseJumpPower
	local oldSpeed      = h.WalkSpeed
	local oldJump       = usesJumpPower and h.JumpPower or h.JumpHeight
	local oldRotate     = h.AutoRotate

	-- stop movement
	h.WalkSpeed = 0
	if usesJumpPower then
		h.JumpPower = 0
	else
		h.JumpHeight = 0
	end
	h.AutoRotate = false

	-- check every frame if stun ended
	local conn
	conn = Services.Run.Heartbeat:Connect(function()
		if not h or h.Health <= 0 or not stamp or not stamp.Parent then
			if conn then conn:Disconnect() end
			return
		end
		if tick() >= stamp.Value then
			pcall(function() h.WalkSpeed = oldSpeed end)
			if usesJumpPower then
				pcall(function() h.JumpPower = oldJump end)
			else
				pcall(function() h.JumpHeight = oldJump end)
			end
			pcall(function() h.AutoRotate = oldRotate end)
			stamp:Destroy()
			if conn then conn:Disconnect() end
		end
	end)

	return true
end

-- track who we already hit during swing
local recentlyHit = {}

-- when tool is used
local function onActivated()
	if not Tool.Enabled or not Humanoid or Humanoid.Health <= 0 then return end

	Tool.Enabled = false
	delay(0.8, function()
		recentlyHit = {}
		Tool.Enabled = true
	end)

	Animations.ChopAnim:Play()
	Sounds.Swing:Play()
end

-- when tool handle touches someone
local function onTouched(hitPart)
	if not hitPart or not hitPart.Parent or Tool.Enabled then return end

	local victimHum = hitPart.Parent:FindFirstChildOfClass("Humanoid")
	local shield    = hitPart.Parent:FindFirstChildOfClass("ForceField")
	if not victimHum or victimHum.Health <= 0 or shield then return end

	local victimPlr = Services.Players:GetPlayerFromCharacter(victimHum.Parent)
	if isTeammate(victimPlr, Player) or contains(recentlyHit, victimHum) then return end

	recentlyHit[#recentlyHit + 1] = victimHum

	untagHumanoid(victimHum)
	tagHumanoid(victimHum, Player)

	-- stun instead of damage
	local newStun = applyStun(victimHum, STUN_DURATION)

	Sounds.Hit:Play()

	-- keep physics tweak
	local lname = string.lower(hitPart.Name)
	if (not string.find(lname, "root") and ((string.find(lname, "torso") or string.find(lname, "head")) and Random.new():NextNumber(0, 100) <= 50))
		or (not string.find(lname, "torso") and not string.find(lname, "head") and not string.find(lname, "root")) then
		hitPart.Anchored = false
	end

	if newStun then
		Durability.Value = math.max(0, (Durability.Value or 0) - 1)
		updateToolName()
		if Durability.Value <= 0 then
			destroyToolSoon()
		end
	end
end

-- when tool is equipped
local function onEquipped()
	Character = Tool.Parent
	Player    = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid  = Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid or Humanoid.Health <= 0 then return end

	Animations = {
		ChopAnim = Humanoid:LoadAnimation(Tool:WaitForChild("Chop" .. Humanoid.RigType.Name)),
	}

	connections[#connections + 1] = Tool.Activated:Connect(onActivated)
	connections[#connections + 1] = Handle.Touched:Connect(onTouched)

	updateToolName()
end

-- when tool is unequipped
local function onUnequipped()
	for i = 1, #connections do
		if connections[i] then
			connections[i]:Disconnect()
			connections[i] = nil
		end
	end
end

Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)
