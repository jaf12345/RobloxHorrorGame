local Players = game:GetService("Players") -- get player number
local RunService = game:GetService("RunService") -- get run service, helps check updates before every frame

local player = Players.LocalPlayer -- player reference
local character = player.Character or player.CharacterAdded:Wait() -- player character reference
local playerRootPart = character:WaitForChild("HumanoidRootPart") -- player root part reference
local camera = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera") -- player camera reference
local playerGui = player:WaitForChild("PlayerGui") -- player gui reference


-- sound referneces
local replicatedStorage = game:GetService("ReplicatedStorage")
local staticEffect1 = replicatedStorage:WaitForChild("Static1")
local staticEffect2 = replicatedStorage:WaitForChild("Static2")
local staticEffect3 = replicatedStorage:WaitForChild("Static3")
local staticEffect4 = replicatedStorage:WaitForChild("Static4")
local staticEffect5 = replicatedStorage:WaitForChild("Static5")

-- table of static effects
local effectTable = {staticEffect1,staticEffect2,staticEffect3,staticEffect4,staticEffect4}

local gui = Instance.new("ScreenGui")
gui.Name = "EffectOverlay"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local image = Instance.new("ImageLabel")
image.Size = UDim2.new(1, 0, 1, 0)
image.BackgroundTransparency = 1
--image.ImageTransparency = 1
image.ZIndex = 10
image.Parent = gui

-- Entity references
local target = game.Workspace:WaitForChild("EntityNPC")
local targetHRP = target:WaitForChild("HumanoidRootPart")

-- Distance from which effects start
local MAX_DISTANCE = 100

local glitchCooldown = false -- cooldown for glitch effect

-- Glitch effect function
local function glitchEffect()
	-- if on cooldown return 
	if glitchCooldown then return end
	-- start cooldown
	glitchCooldown = true

	-- Pick a random static effect from the effect table
	local chosenImage = effectTable[math.random(1, #effectTable)]
	image.Image = chosenImage.Image -- seeting image to the chosen texture
	image.ImageTransparency = math.random(90, 95) / 100 -- set transparency between the bounds


	-- Flicker effect 
	task.spawn(function()
		for i = 1, 5 do
			-- set transparency between the bounds
			image.ImageTransparency = math.random(90, 95) / 100
			-- wait for 0.05 seconds
			task.wait(0.05)
		end
		image.ImageTransparency = 1
	end)

	-- small delay to reset cooldown
	task.delay(0.3, function()
		glitchCooldown = false
	end)
end

-- updates before every frame
RunService.RenderStepped:Connect(function()
	-- checks if player and entity root parts exists so code doesn't reference non-exsisting objects 
	if not (playerRootPart and targetHRP) then return end

	-- helps check whats on screen
	local _, inScreen = camera:WorldToViewportPoint(targetHRP.Position)
	-- checks if entity is next to player
	local targetDistance = (playerRootPart.Position - targetHRP.Position).Magnitude
	-- returns if none are true
	if not inScreen or targetDistance > MAX_DISTANCE then return end

	-- raycast to check if a wall is infront of player 
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude


	local direction = (targetHRP.Position - camera.CFrame.Position).Unit * MAX_DISTANCE
	-- performs raycast to help check whether there is a wall infront of player
	local raycastResult = workspace:Raycast(camera.CFrame.Position, direction, rayParams)

	-- if there is no wall or the wall is the entity then play glitch effect
	if not raycastResult or raycastResult.Instance == targetHRP then
		glitchEffect()
	end
end)
