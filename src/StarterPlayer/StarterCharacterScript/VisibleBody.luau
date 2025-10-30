local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

-- hide head in the first person view
local function hideHead()
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name == "Head" then
			part.LocalTransparencyModifier = 1
		end
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

-- update based on camera position
game:GetService("RunService").RenderStepped:Connect(function()
	local distance = (camera.CFrame.Position - character.Head.Position).Magnitude

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
