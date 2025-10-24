-- player reference
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local playerRootPart = character:WaitForChild("HumanoidRootPart")

-- run service helps perform functions every frame
local RunService = game:GetService("RunService")

-- reference to entity
local target = game.Workspace:WaitForChild("EntityNPC")
local targetHRP = target:WaitForChild("HumanoidRootPart")

-- geiger sound reference
local geigerSound = game.ReplicatedStorage:WaitForChild("GeigerSound")
geigerSound.Parent = playerRootPart

-- distance to trigger noise
local MAX_DISTANCE = 70
-- distance player is away from enemy
local distance = 0

-- variables for checking if sound is playing
local playing = false

-- runs before every frame
RunService.RenderStepped:Connect(function()
	-- checks if player and entity root parts exists so code doesn't reference non-exsisting objects 
	if not playerRootPart or not targetHRP then return end 
	-- updating ememy player distance every second
	distance = (playerRootPart.Position - targetHRP.Position).Magnitude
	
	-- checks whether player distance is less that constand set
	if distance <= MAX_DISTANCE then
		-- if sound isnt playing when the player is close to enemy then play sound
		if not playing then
			geigerSound:Play()
			playing = true -- track the whether the sound is playing
		end
		-- chooses a minimum volume and a maximum volume based on the distance between the player and the enemy
		local dynamicVolume = math.clamp(1-(distance / MAX_DISTANCE), 0.2, 0.9)
		geigerSound.Volume = dynamicVolume -- sets new sound dynamically
	elseif distance > MAX_DISTANCE then
		if playing then
			geigerSound:Stop() -- stop sound
			playing = false -- track the whether the sound is playing
		end
	end
end)
