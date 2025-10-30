local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local noteGUI = player:WaitForChild("PlayerGui"):WaitForChild("NoteGUI")
local frame = noteGUI:WaitForChild("Frame")
local textLabel = frame:WaitForChild("TextLabel")
local blackFade = noteGUI:WaitForChild("BlackFade")

local openSound = script:FindFirstChild("NoteOpenSound") or script.Parent:FindFirstChild("NoteOpenSound")
if not openSound then
	warn("⚠️ Missing NoteOpenSound! Add a Sound named 'NoteOpenSound' inside StarterPlayerScripts.")
end

local lookingAtNote = nil
local reading = false
local fadeSpeed = 0.15
local zoomAmount = 15
local zoomTween, unzoomTween

local humanoid
local function lockMovement()
	if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end
end

local function unlockMovement()
	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
end

local prompt = Instance.new("BillboardGui")
prompt.Size = UDim2.new(0, 200, 0, 50)
prompt.AlwaysOnTop = true
local promptLabel = Instance.new("TextLabel")
promptLabel.Size = UDim2.new(1, 0, 1, 0)
promptLabel.BackgroundTransparency = 1
promptLabel.TextColor3 = Color3.new(1, 1, 1)
promptLabel.TextScaled = true
promptLabel.Text = "Press R to Read"
promptLabel.Font = Enum.Font.GothamBold
promptLabel.Parent = prompt

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function tweenTransparency(obj, property, target, duration)
	tweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[property] = target}):Play()
end

local function fadeInGUI()
	frame.Visible = true
	frame.BackgroundTransparency = 1
	textLabel.TextTransparency = 1
	tweenTransparency(blackFade, "BackgroundTransparency", 0.35, 0.5)
	tweenTransparency(frame, "BackgroundTransparency", 0.3, 0.5)
	tweenTransparency(textLabel, "TextTransparency", 0, 0.5)
end

local function fadeOutGUI()
	tweenTransparency(blackFade, "BackgroundTransparency", 1, 0.5)
	tweenTransparency(frame, "BackgroundTransparency", 1, 0.4)
	tweenTransparency(textLabel, "TextTransparency", 1, 0.4)
	task.wait(0.5)
	frame.Visible = false
end

local function zoomIn()
	local startFOV = camera.FieldOfView
	zoomTween = tweenService:Create(camera, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = startFOV - zoomAmount})
	zoomTween:Play()
end

local function zoomOut()
	if zoomTween then zoomTween:Cancel() end
	local startFOV = camera.FieldOfView
	unzoomTween = tweenService:Create(camera, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = 70})
	unzoomTween:Play()
end

runService.RenderStepped:Connect(function()
	if reading then return end
	rayParams.FilterDescendantsInstances = {player.Character}

	local origin = camera.CFrame.Position
	local direction = camera.CFrame.LookVector * 10
	local result = workspace:Raycast(origin, direction, rayParams)

	if result and result.Instance and result.Instance.Parent and result.Instance.Parent.Name == "Note" then
		local note = result.Instance.Parent
		if lookingAtNote ~= note then
			lookingAtNote = note
			prompt.Parent = note:FindFirstChild("NotePart")
		end
	else
		if lookingAtNote then
			prompt.Parent = nil
			lookingAtNote = nil
		end
	end
end)

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.R then
		if lookingAtNote and not reading then
			local textVal = lookingAtNote:FindFirstChild("NoteText")
			if textVal then
				textLabel.Text = textVal.Value
				reading = true
				lockMovement()
				if openSound then openSound:Play() end
				prompt.Parent = nil
				fadeInGUI()
				zoomIn()
			end
		elseif reading then
			fadeOutGUI()
			unlockMovement()
			zoomOut()
			reading = false
		end
	end
end)
