-- references
local eCard = game.Workspace:WaitForChild("ElevatorCard")
local TweenService = game:GetService("TweenService")
local cardReader = script.Parent
local prompt = cardReader:WaitForChild("Prompt")
local players = game:GetService("Players")
local elevator = game.Workspace:WaitForChild("Elevator")
local leftDoor = elevator:WaitForChild("LeftDoor")
local rightDoor = elevator:WaitForChild("RightDoor")

-- sound references
local dingSound = game.ReplicatedStorage.ElevatorDing
local openSound = game.ReplicatedStorage.ElevatorOpen
openSound.PlaybackSpeed = 1.5 -- sound tuning


local function openDoors()
	-- setting the animation goal
	local leftGoal = {Position = leftDoor.Position + Vector3.new(0,0,5.3)}
	local rightGoal = {Position = rightDoor.Position - Vector3.new(0,0,5.3)}
	
	-- gathering tween info for tween service
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	dingSound:Play()
	task.wait(0.5)
	openSound:Play()
	
	-- using tween service to animate doors
	TweenService:Create(leftDoor, tweenInfo, leftGoal):Play()
	TweenService:Create(rightDoor, tweenInfo, rightGoal):Play()
	task.wait(1)
end

-- if card reader gets triggered
prompt.Triggered:Connect(function(player)
	task.wait(0.1)
	-- checks if card is in player's hand
	local swipped = player.Character and player.Character:FindFirstChild(eCard.Name)
	-- checks if player is holding the card
	if swipped then
		-- open door
		print("player has triggered with card!")
		prompt.Enabled = false
		eCard:Destroy()
		openDoors()
	else
		--deny
		print("player has triggered without card...")
	end
end)
