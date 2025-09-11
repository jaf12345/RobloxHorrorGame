local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera
local animator = humanoid:WaitForChild("Animator")

local sprintAnim = replicatedStorage:WaitForChild("SprintAnim")
local sprintTrack = animator:LoadAnimation(sprintAnim)


local walkSpeed = 16
local runSpeed = 28
local defaultfieldofview = 70


local stamina = 500
local maxStamina = 500
local staminaDrain = 30
local staminaRegen = 50
local canSprint = true
local sprinting = false

-- retrieves references for stamina bar frame in the player's gui
local staminaBar = player:WaitForChild("PlayerGui"):WaitForChild("StaminaMeter"):WaitForChild("StaminaFrame"):WaitForChild("StaminaBar")


-- sprinting function
local function sprint()
	if stamina > 0 and canSprint then
		sprinting = true
		humanoid.WalkSpeed = runSpeed
		camera.FieldOfView = 80
		if not sprintTrack.IsPlaying then
			--sprintTrack.Priority = Enum.AnimationPriority.Action
			sprintTrack:Play()
		end
	end
end

-- regular player speed set
local function walk()
	sprinting = false
	humanoid.WalkSpeed = walkSpeed
	camera.FieldOfView = 70
	if sprintTrack.IsPlaying then
		sprintTrack:Stop()
	end
end


-- inputs for sprinting
userInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprint()
	end
end)

userInputService.InputEnded:Connect(function(input,gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		walk()
	end
end)

-- stamina bar ui change
local function staminaBarUpdate()
	staminaBar.Size = UDim2.new(stamina / maxStamina, 0, 1, 0)
end


-- stamina drain and regen using delta time, and calls stamina ui update
game:GetService("RunService").RenderStepped:Connect(function(dt)
	-- if player is sprinting and stamina is above 0 then drain stamina
	if sprinting and stamina > 0 then
		stamina = stamina - staminaDrain * dt
		-- if stamina reaches 0, stop sprinting, set player to walk, delay 1 second
		if stamina <= 0 then
			stamina = 0
			walk()
			canSprint = false
			task.delay(1, function()
				canSprint = true
			end)
		end
	else
		-- regen stamina while not sprinting and sets stamina to the min of max stamina and stamina + regen
		if stamina < maxStamina then
			stamina = math.min(maxStamina, stamina + staminaRegen * dt)
		end
	end
	-- calls for stamina bar to update
	staminaBarUpdate()
end)
