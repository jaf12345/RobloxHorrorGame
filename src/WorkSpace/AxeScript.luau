-- axe tool script (reordered)
-- stuns on hit (6s), 10 total uses

local tool    = script.Parent
local handle  = tool:WaitForChild("Handle")
local creator = tool:WaitForChild("Creator")

-- swing state
local canSwing       = true     -- small cooldown between swings
local canDealDamage  = false    -- true only during hit window

-- forward declare so functions can use it before we build the IntValue
local durability

-- ============ small helpers ============

-- put/refresh the creator tag on a humanoid (for credit)
local function setCreatorTag(hum, attackerChar)
	if not hum then return end
	local plr = game.Players:WaitForChild(attackerChar.Name)

	local tag = hum:FindFirstChild("creator")
	if not tag then
		tag = Instance.new("ObjectValue")
		tag.Name = "creator"
		tag.Parent = hum
	end
	tag.Value = plr
end

-- short stun (freeze move + jump, restore after)
local function applyStun(hum, secs)
	if not hum or hum.Health <= 0 then return end
	local oldWalk = hum.WalkSpeed
	local oldJump = hum.JumpPower

	hum.WalkSpeed = 0
	hum.JumpPower = 0

	handle.Swing:Stop()
	handle.Hit:Play()

	delay(secs, function()
		if hum and hum.Parent and hum.Health > 0 then
			hum.WalkSpeed = oldWalk
			hum.JumpPower = oldJump
		end
	end)
end

-- show durability in the name
local function updateToolName()
	if tool and tool.Parent then
		local n = durability and durability.Value or 0
		tool.Name = string.format("Axe (%d/10 durability)", n)
	end
end

-- delete when used up
local function destroyTool()
	if tool then tool:Destroy() end
end

-- ============ hitbox first (moved up) ============

-- runs when the handle touches something
local function onTouched(hitPart)
	local hum = hitPart.Parent and hitPart.Parent:FindFirstChildOfClass("Humanoid")
	if not hum or not canDealDamage then return end

	-- close the hit window so we don't double-hit on the same swing
	canDealDamage = false

	local attackerChar = creator.Value
	if hum.Health > 0 then
		setCreatorTag(hum, attackerChar)   -- credit
		applyStun(hum, 6)                  -- stun instead of damage

		-- durability goes down only on a valid hit
		if durability then
			durability.Value = math.max(0, durability.Value - 1)
			updateToolName()
			if durability.Value <= 0 then
				destroyTool()
			end
		end
	end
end

-- ============ swing next (moved below hitbox) ============

-- play a random animation and open a short hit window
local function doSlash()
	local char = creator.Value
	local animFolder = tool:WaitForChild("Animations")
	local all = animFolder:GetChildren()
	if #all == 0 then return end

	local pick = all[math.random(1, #all)]
	local track = char:WaitForChild("Humanoid"):LoadAnimation(pick)

	if not canSwing then return end
	canSwing = false

	track:Play()
	task.wait(0.15)                 -- start hit window
	canDealDamage = true
	handle.Swing:Play()
	handle.SlashTrail.Enabled = true

	task.wait(0.25)                 -- end hit window
	canDealDamage = false
	handle.SlashTrail.Enabled = false

	task.wait(0.06)                 -- tiny buffer
	canSwing = true
end

-- ============ durability build (moved down) ============

-- make sure the IntValue exists (10 uses)
durability = tool:FindFirstChild("Durability")
if not durability then
	durability = Instance.new("IntValue")
	durability.Name = "Durability"
	durability.Value = 10
	durability.Parent = tool
end
updateToolName()

-- ============ wiring / events (last) ============

tool.Equipped:Connect(function()
	handle.Equip:Play()
	-- set creator once
	if creator.Value == nil then
		creator.Value = tool.Parent
	end
	updateToolName()
end)

tool.Unequipped:Connect(function()
	handle.UnEquip:Play()
end)

-- make sure creator exists before use
repeat task.wait() until creator.Value ~= nil

tool.Activated:Connect(function()
	if handle.Transparency == 1 then return end
	doSlash()
end)

handle.Touched:Connect(onTouched)
