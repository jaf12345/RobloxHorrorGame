local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- GUI and elements
local spectateGui = playerGui:WaitForChild("SpectateControllerGui")
local controlFrame = spectateGui:WaitForChild("controlFrame")
local nextButton = controlFrame:WaitForChild("NextButton")
local prevButton = controlFrame:WaitForChild("PrevButton")
local currentPlayerLabel = controlFrame:WaitForChild("CurrentPlayer")

-- RemoteEvent for status
local StatusEvent = ReplicatedStorage:WaitForChild("StatusEvent")

local playerList = {}
local currentIndex = 1

local spectateTarget = Instance.new("Part")
spectateTarget.Anchored = true
spectateTarget.CanCollide = false
spectateTarget.Transparency = 1
spectateTarget.Size = Vector3.new(1,1,1)
spectateTarget.Name = "SpectateTarget"
spectateTarget.Parent = workspace

local currentTargetPlayer = nil
local LERP_SPEED = 5

local turn = 0
local bobTime = 0
local lastPositon = nil

local function Lerp(a, b, t)
	return a + (b - a) * t
end

-- update the GUI label and camera subject
local function updateSpectateTarget()
	if #playerList == 0 then return end
	
	local targetName = playerList[currentIndex]
	currentPlayerLabel.Text = "Spectating: " .. targetName
	
	print("switched to spectate: " .. targetName)
	
	local targetPlayer = Players:FindFirstChild(targetName)
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
		currentTargetPlayer = targetPlayer
		
		-- camera follow spectateTarget
		camera.CameraSubject = spectateTarget
	end
end

-- fetch player status from server
local function refreshStatus()
	StatusEvent:FireServer()
end

StatusEvent.OnClientEvent:Connect(function(statusTable)
	playerList = {}
	for name, alive in pairs(statusTable) do
		if alive == 1 then
			table.insert(playerList, name)
		end
	end
	table.sort(playerList)
	if #playerList > 0 then
		currentIndex = math.clamp(currentIndex, 1, #playerList)
	else
		currentIndex = 0
	end
	
	updateSpectateTarget()
end)

-- button connections
nextButton.MouseButton1Click:Connect(function()
	print("Next button clicked")
	refreshStatus()
	if #playerList == 0 then return end
	currentIndex = currentIndex % #playerList + 1
	
	updateSpectateTarget()
end)

prevButton.MouseButton1Click:Connect(function()
	print("Prev button clicked")
	refreshStatus()
	if #playerList == 0 then return end
	currentIndex = (currentIndex - 2) % #playerList + 1
	
	updateSpectateTarget()
end)
-- first person setup and spectate toggle on death
local FIRST_PERSON = 0
local DEATH_ZOOM = 15
local ZOOM_SPEED = 2

local zoomTarget = FIRST_PERSON -- current target zoom

-- lock first-person
local function lockFirstPerson()
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	player.CameraMinZoomDistance = FIRST_PERSON
	player.CameraMaxZoomDistance = FIRST_PERSON
	camera.CameraType = Enum.CameraType.Custom
	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
	zoomTarget = FIRST_PERSON
end

local function setupCharacter(char)
	lockFirstPerson()

	local humanoid = char:WaitForChild("Humanoid")
	local rootPart = char:WaitForChild("Head")

	humanoid.CameraOffset = Vector3.new(0, 0, -1) -- change offset in first person
	humanoid.Died:Connect(function()
		-- on death, allow zoom-out
		player.CameraMode = Enum.CameraMode.Classic
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = rootPart
		zoomTarget = DEATH_ZOOM
		
		
	end)
end

-- smoothly lerp zoom each frame
RunService.RenderStepped:Connect(function(deltaTime)
	if player.CameraMinZoomDistance ~= zoomTarget or player.CameraMaxZoomDistance ~= zoomTarget then
		local newZoom = player.CameraMinZoomDistance + (zoomTarget - player.CameraMinZoomDistance) * math.clamp(deltaTime * ZOOM_SPEED, 0, 1)
		player.CameraMinZoomDistance = newZoom
		player.CameraMaxZoomDistance = newZoom
	end
	
	
	-- lerp to the target player for added smoothness
	if currentTargetPlayer and currentTargetPlayer.Character and currentTargetPlayer.Character:FindFirstChild("Head") then
		local targetPos = currentTargetPlayer.Character.Head.Position
		spectateTarget.CFrame = spectateTarget.CFrame:Lerp(CFrame.new(targetPos), math.clamp(deltaTime * LERP_SPEED, 0, 1))
	end
	
	if player.Character and camera.CameraSubject == player.Character:FindFirstChild("Humanoid") then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if humanoid and root then
			-- sideways mouse tilt
			local MouseDelta = UserInputService:GetMouseDelta()
			

			-- detect movement speed using position difference
			local currentPos = root.Position
			local moveDist = 0 
			if lastPositon then
				 moveDist = (currentPos - lastPositon).Magnitude
			end
			lastPositon = currentPos

			turn = Lerp(turn, math.clamp(MouseDelta.X, -7.5, 7.5), (7 * deltaTime))
			
			bobTime += moveDist + deltaTime * 2
			bobTime = math.fmod(bobTime, math.pi * 2)
			
			-- get the cameras forward direction
			local forward = camera.CFrame.LookVector

			-- calculate pitch
			local pitch = math.asin(forward.Y)  

			-- convert pitch to degrees and get the absolute value
			local pitchDegrees = math.abs(math.deg(pitch))

			-- calculate bob amplitude based on pitch
			local bobAmplitude = (90 - pitchDegrees) / 90

			-- calculate vertical bob offset
			local bobHeight = math.sin(bobTime) * (0.10 * bobAmplitude) -- amplitude and frequency
			local bobOffset = Vector3.new(0, bobHeight, 0)
			
			
			-- apply final camera transform
			camera.CFrame = camera.CFrame
				* CFrame.Angles(0, 0, math.rad(turn))
				* CFrame.new(bobOffset)
			
		end
	end
end)

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
	setupCharacter(player.Character)
end