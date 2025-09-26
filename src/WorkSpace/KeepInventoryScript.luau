-- keep player tools after death 

local Players = game:GetService("Players")

-- per-player stash (tools cloned here)
local stashMap = {}

-- kill a tool with same name in backpack (avoid dupes)
local function nukeDuplicate(backpack, name)
	local t = backpack:FindFirstChild(name)
	if t and t:IsA("Tool") then t:Destroy() end
end

-- grab tools from a container (Backpack or Character), clone -> stash, delete originals
local function scoopTools(player, container)
	local list = container:GetChildren()
	for i = #list, 1, -1 do -- reverse so deletes don't shift indices
		local obj = list[i]
		if obj:IsA("Tool") then
			stashMap[player] = stashMap[player] or {}
			table.insert(stashMap[player], obj:Clone())
			obj:Destroy()
		end
	end
end

-- give all stashed tools back to the player
local function giveBack(player)
	local backpack = player:FindFirstChild("Backpack")
	local stash = stashMap[player]
	if not backpack or not stash or #stash == 0 then return end

	for i = 1, #stash do
		local toolClone = stash[i]
		-- make sure we don't end up with two of the same by Name
		nukeDuplicate(backpack, toolClone.Name)
		toolClone.Parent = backpack
	end

	-- clear after restore
	stashMap[player] = {}
end

-- character spawn handler
local function onCharSpawn(char)
	local plr = Players:GetPlayerFromCharacter(char)
	if not plr then return end

	-- make sure stash exists
	stashMap[plr] = stashMap[plr] or {}

	-- 1) immediately restore whatever we saved before
	giveBack(plr)

	-- 2) when they die, scoop tools from both Character + Backpack
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then
		hum.Died:Connect(function()
			local backpack = plr:FindFirstChild("Backpack")
			if backpack then scoopTools(plr, backpack) end
			scoopTools(plr, char)
		end)
	end
end

-- player join
Players.PlayerAdded:Connect(function(plr)
	-- init empty stash
	stashMap[plr] = {}

	-- current or next character
	local char = plr.Character or plr.CharacterAdded:Wait()
	onCharSpawn(char)

	-- future spawns
	plr.CharacterAdded:Connect(onCharSpawn)
end)
