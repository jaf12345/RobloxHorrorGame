local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- store haze references
local atmosphere, sky

-- function to create haze
local function enableHaze()
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
		atmosphere.Density = 0.9
		atmosphere.Color = Color3.new(0, 0, 0)
		atmosphere.Decay = Color3.fromRGB(106, 112, 125)
		atmosphere.Haze = 10
	end

	if not sky then
		sky = Instance.new("Sky")
		sky.Parent = Lighting
		sky.SunAngularSize = 0
		sky.MoonAngularSize = 0
	end
end

-- function to remove haze
local function disableHaze()
	if atmosphere then
		atmosphere:Destroy()
		atmosphere = nil
	end
	if sky then
		sky:Destroy()
		sky = nil
	end
end

-- handles character setup
local function setupCharacter(char)
	enableHaze() -- add haze when alive

	local humanoid = char:WaitForChild("Humanoid")

	-- check whenever health changes
	humanoid.HealthChanged:Connect(function(health)
		if health <= 0 then
			disableHaze()
		end
	end)
end

-- connect for respawns
player.CharacterAdded:Connect(setupCharacter)
if player.Character then
	setupCharacter(player.Character)
end
