local Players = game:GetService("Players") -- get player number
local RunService = game:GetService("RunService") -- get run service, helps check updates before every frame

local player = Players.LocalPlayer -- player reference
local character = player.Character or player.CharacterAdded:Wait() -- player character reference
local playerRootPart = character:WaitForChild("HumanoidRootPart") -- player root part reference
local camera = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera") -- player camera reference
local playerGui = player:WaitForChild("PlayerGui") -- player gui reference


-- camera instance tuning
local cameraOverlay = Instance.new("Part")
cameraOverlay.Size = Vector3.new(6, 4, 0.1) -- smaller overlay
cameraOverlay.Anchored = true -- so object doesn't move
cameraOverlay.CanCollide = false -- no collision
cameraOverlay.CastShadow = false
cameraOverlay.Transparency = 0.9 -- slightly see-through
cameraOverlay.Color = Color3.new(1, 1, 1) 
cameraOverlay.Material = Enum.Material.SmoothPlastic
cameraOverlay.Name = "CameraOverlay"
cameraOverlay.Parent = workspace -- set location of the overlay

-- sound referneces
local replicatedStorage = game:GetService("ReplicatedStorage")
local staticEffect1 = replicatedStorage:WaitForChild("Static1")
local staticEffect2 = replicatedStorage:WaitForChild("Static2")
local staticEffect3 = replicatedStorage:WaitForChild("Static3")
local staticEffect4 = replicatedStorage:WaitForChild("Static4")
local staticEffect5 = replicatedStorage:WaitForChild("Static5")

-- table of static effects
local effectTable = {staticEffect1,staticEffect2,staticEffect3,staticEffect4,staticEffect4}

-- Entity references
local target = game.Workspace:WaitForChild("EntityNPC")
local targetHRP = target:WaitForChild("HumanoidRootPart")

-- Distance from which effects start
local MAX_DISTANCE = 100

local glitchCooldown = false -- cooldown for glitch effect
local currentTexture = nil -- tracking the current texture

-- Glitch effect function
local function glitchEffect()
	-- if on cooldown return 
	if glitchCooldown then return end
	-- start cooldown
	glitchCooldown = true
	
	-- remove the current texture that plays on player screen
	if currentTexture then
		currentTexture:Destroy()
	end
	
	-- Pick a random static effect from the effect table
	local chosenTexture = effectTable[math.random(1, #effectTable)]:Clone()
	-- tune the properties to make make it appropriate
	chosenTexture.Face = Enum.NormalId.Back 
	chosenTexture.Color3 = Color3.new(1, 1, 1)
	chosenTexture.Transparency = 0
	chosenTexture.Parent = cameraOverlay
	currentTexture = chosenTexture

	-- Flicker effect 
	task.spawn(function()
		for i = 1, 5 do
			if currentTexture then
				-- set transparency between 70% and 95%
				currentTexture.Transparency = math.random(70, 95) / 100
			end
			-- wait for 0.1 seconds
			task.wait(0.1)
		end
		
		-- removes current texture once played
		if currentTexture then
			currentTexture:Destroy()
			currentTexture = nil
		end
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
	
	-- sets the camera overlay position to the camera's position with a little indent
	cameraOverlay.CFrame = camera.CFrame * CFrame.new(0, 0, -2)
	
	-- helps check whats on screen
	local _, inScreen = camera:WorldToViewportPoint(targetHRP.Position)
	-- checks if entity is next to player
	local targetDistance = (playerRootPart.Position - targetHRP.Position).Magnitude
	-- returns if none are true
	if not inScreen or targetDistance > MAX_DISTANCE then return end

	-- raycast to check if a wall is infront of player 
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {cameraOverlay, player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude


	local direction = (targetHRP.Position - camera.CFrame.Position).Unit * MAX_DISTANCE
	-- performs raycast to help check whether there is a wall infront of player
	local raycastResult = workspace:Raycast(camera.CFrame.Position, direction, rayParams)
	
	-- if there is no wall or the wall is the entity then play glitch effect
	if not raycastResult or raycastResult.Instance == targetHRP then
		glitchEffect()
	end
end)
