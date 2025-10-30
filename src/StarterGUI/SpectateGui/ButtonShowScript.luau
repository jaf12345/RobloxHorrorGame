-- script to show camera options upon player death

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local cameraFrame = script.Parent:WaitForChild("controlFrame")
local currentPlayerLabel = cameraFrame:WaitForChild("CurrentPlayer")

cameraFrame.Visible = false -- hide at the start

-- start with self name
currentPlayerLabel.Text = "Spectating: " .. player.Name

-- wait for the character to load
local function setupCharacter(char)
	local humanoid = char:WaitForChild("Humanoid")
	
	-- wait for death
	humanoid.Died:Connect(function()
		cameraFrame.Visible = true
	end)
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
	setupCharacter(player.Character)
end