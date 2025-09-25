-- Inside Medkit tool
local tool = script.Parent
local cooldown = 40
local isCooldown = false
local healSound = tool:FindFirstChild("heal")
local pickSound = tool:FindFirstChild("pick")

local MAX_USES = 2

local function setUsesName(usesLeft)
	if usesLeft > 0 then
		tool.Name = ("Medkit (%d use%s left)"):format(usesLeft, usesLeft == 1 and "" or "s")
	else
		tool.Name = "Medkit"
	end
end

local function getPlayerFromTool()
	return game.Players:GetPlayerFromCharacter(tool.Parent)
end

local function getUsesLeft()
	local v = tool:GetAttribute("UsesLeft")
	if v == nil then
		v = MAX_USES
		tool:SetAttribute("UsesLeft", v)
	end
	return v
end

-- When this tool enters a player's Backpack, set their attribute
tool.AncestryChanged:Connect(function(_, parent)
	local player = game.Players:GetPlayerFromCharacter(tool.Parent)
	if player then
		local uses = getUsesLeft()
		if (player:GetAttribute("MedkitUsesLeft") or 0) <= 0 then
			player:SetAttribute("MedkitUsesLeft", uses)
		end
	end
end)

tool.Equipped:Connect(function()
	if pickSound then pickSound:Play() end
	setUsesName(getUsesLeft())
end)

local function healPlayer(player)
	if isCooldown then return end
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- heal
	humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 75)

	-- decrement uses & persist
	local usesLeft = getUsesLeft() - 1
	tool:SetAttribute("UsesLeft", usesLeft)
	player:SetAttribute("MedkitUsesLeft", usesLeft)

	-- vanish when empty
	if usesLeft <= 0 then
		if healSound and healSound.Playing then healSound.Playing = false end
		tool:Destroy()
		return
	end

	-- cooldown
	isCooldown = true
	if healSound then healSound.Playing = true end
	for i = cooldown, 0, -1 do
		tool.Name = "Cooldown: " .. i .. "s"
		task.wait(1)
	end
	if healSound then healSound.Playing = false end
	isCooldown = false
	setUsesName(usesLeft)
end

tool.Activated:Connect(function()
	local player = getPlayerFromTool()
	if player then
		healPlayer(player)
	end
end)
