local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local lobbyGuiFolder = workspace:WaitForChild("LobbyGuis")

-- create a highlight for yourself only
local highlight = Instance.new("Highlight")
highlight.Name = "LobbyOutline"
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = character
highlight.Enabled = false


-- collision gui table to access by number

-- function to toggle other players' transparency
local function updateOtherPlayers()
	local state = player:GetAttribute("touched")

	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			local otherChar = otherPlayer.Character

			if state == "LobbyTarget" then
				-- make them fully visible
				for _, part in pairs(otherChar:GetDescendants()) do
					if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "HumanoidRootPart" then
						part.Transparency = 0
					end
				end
			else
				-- make them fully transparent
				for _, part in pairs(otherChar:GetDescendants()) do
					if (part:IsA("BasePart") or part:IsA("Decal")) and part.Name ~= "HumanoidRootPart" then
						part.Transparency = 1
					end
				end
			end
		end
	end

	-- update your own highlight
	highlight.Enabled = (state == "LobbyTarget")
end

-- run once at start
updateOtherPlayers()

-- listen for attribute changes
player:GetAttributeChangedSignal("touched"):Connect(updateOtherPlayers)

local boxUpdate = ReplicatedStorage:WaitForChild("BoxUpdate")

-- keep track of which boxes the player is in
local playerInBoxes = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false
}

boxUpdate.OnClientEvent:Connect(function(boxId, playerIds)
	-- update box status
	playerInBoxes[boxId] = table.find(playerIds, player.UserId) ~= nil

	local inAnyBox = false
	for _, isIn in pairs(playerInBoxes) do
		if isIn then
			inAnyBox = true
			break
		end
	end

	-- if local player is in any box
	if inAnyBox then
		for _, userId in ipairs(playerIds) do
			local p = Players:GetPlayerByUserId(userId)
			if p and p.Character then
				local h = p.Character:FindFirstChild("LobbyOutline")
				if not h then
					local newHighlight = Instance.new("Highlight")
					newHighlight.Name = "LobbyOutline"
					newHighlight.FillTransparency = 1
					newHighlight.OutlineColor = Color3.fromRGB(0, 255, 0)
					newHighlight.OutlineTransparency = 0
					newHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					newHighlight.Parent = p.Character
				else
					h.OutlineColor = Color3.fromRGB(0, 255, 0)
					h.Enabled = true
				end
			end
		end
	else
		-- not in any box: remove everyone else's highlight
		for _, otherPlayer in pairs(Players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character then
				local h = otherPlayer.Character:FindFirstChild("LobbyOutline")
				if h then
					h:Destroy()
				end
			end
		end
	end

	-- update your own highlight color
	if inAnyBox then
		highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
	else
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	end
end)


Players.PlayerAdded:Connect(function(newPlayer)
	newPlayer.CharacterAdded:Connect(function()
		-- wait a moment for the character to load
		task.wait(1)
		updateOtherPlayers()
	end)
end)