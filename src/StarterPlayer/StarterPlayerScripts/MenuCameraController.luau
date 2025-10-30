-- get the current camera, target part, and player
local camera = workspace.CurrentCamera
local menuTarget = workspace:WaitForChild("MenuTarget")
local creditTarget = workspace:WaitForChild("CreditTarget")
local lobbyTarget = workspace:WaitForChild("LobbyTarget")
local player = game.Players.LocalPlayer
local character = player.Character

local StarterGUI = game:GetService("StarterGui")

-- set camera to scriptable mode for control
camera.CameraType = Enum.CameraType.Scriptable

-- set the reset button to false
wait(0.1)
StarterGUI:SetCore("ResetButtonCallback", false) 

-- find lighting depth of feild
local lighting = game:GetService("Lighting")
local dof = lighting:WaitForChild("DepthOfField")

-- depth of field settings
dof.Enabled = true
dof.FarIntensity = 1
dof.NearIntensity = 1
local focusDistance = 25
local playerPos

local lerpSpeed = 4


-- update camera position and dof focus every frame
game:GetService("RunService").RenderStepped:Connect(function(dt)
	-- camera shake
	local shakeIntensity = 0.5
	local time = tick()

	-- pitch and roll shake
	local pitchShake = math.sin(time * 4) * shakeIntensity
	local rollShake = math.cos(time * 5) * shakeIntensity

	-- apply shake rotation
	local shakeCFrame = CFrame.Angles(math.rad(pitchShake), 0, math.rad(rollShake))
	
	local target 
	if player:GetAttribute("touched") == "CreditTarget" then
		target = creditTarget
	elseif player:GetAttribute("touched") == "LobbyTarget" then
		target = lobbyTarget
	else
		target = menuTarget
	end
	
	-- move camera to the same position as the part
	if character and character:WaitForChild("HumanoidRootPart") then
		playerPos = character.HumanoidRootPart.Position

		
		dof.InFocusRadius = 5
		local targetCFrame = creditTarget.CFrame * shakeCFrame
		
		if player:GetAttribute("touched") == "MenuTarget" or player:GetAttribute("touched") == "LobbyTarget" then
			targetCFrame = CFrame.lookAt(target.Position, playerPos) * shakeCFrame
			if player:GetAttribute("touched") == "MenuTarget" then
				dof.InFocusRadius = 1
			end
		end
		
		-- apply shake rotation on top of base orientation
		camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpSpeed * dt)
	end
	
	local distanceToPlayer = (target.Position - playerPos).Magnitude
	-- set focus distance 
	dof.FocusDistance = distanceToPlayer
	
	local transparency = 0
	if player:GetAttribute("touched") == "CreditTarget" then
		transparency = 0.55
	end
	if distanceToPlayer <= 4 then
		transparency = (10 - distanceToPlayer) / 10
	end
	
	
	
	-- apply transparency to all character parts
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			part.LocalTransparencyModifier = transparency * 1.5
		end
	end
end)