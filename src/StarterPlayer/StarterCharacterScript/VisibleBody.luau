local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

-- function to get the current head safely
local function getHead()
	return character:FindFirstChild("Head")
end

-- hide head in first person
local function hideHead()
	local head = getHead()
	if head and head:IsA("BasePart") then
		head.LocalTransparencyModifier = 1
	end
end

-- show other body parts
local function showBody()
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "Head" then
			part.LocalTransparencyModifier = 0
		end
	end
end

-- listen for character respawn
player.CharacterAdded:Connect(function(newChar)
	character = newChar
end)

-- main loop
runService.RenderStepped:Connect(function()
	local head = getHead()
	if not head then
		return -- wait until head exists
	end

	local distance = (camera.CFrame.Position - head.Position).Magnitude

	if distance <= 2 then
		hideHead()
		showBody()
	else
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end
end)
