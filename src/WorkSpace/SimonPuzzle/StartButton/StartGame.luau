-- Script for the start button of the Simon Puzzle
local part = script.Parent
local orginalPartColor = part.Color
local orginalPartMaterial = part.Material
local orginalPartPosition = part.Position

-- Get the puzzle model
local puzzle = part.Parent

-- Get the panes that light up for the player
local redPane = puzzle:WaitForChild("Red")
local greenPane = puzzle:WaitForChild("Green")
local bluePane = puzzle:WaitForChild("Blue")
local yellowPane = puzzle:WaitForChild("Yellow")

-- references to the replicated storage
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Get the file that holds the sounds for the puzzle
local soundFile = replicatedStorage:WaitForChild("SimonPuzzleSounds")

-- Get the prompt event that acitvates the puzzle
local promptEvent = soundFile:WaitForChild("PromptEvent")

-- gets the sound for the panes
local function getSound(name, parent)
	local soundTemplate = soundFile:FindFirstChild(name)
	if soundTemplate then
		local soundClone = soundTemplate:Clone()
		soundClone.Parent = parent
		return soundClone
	else
		warn("Sound not found:", name)
		return nil
	end
end

-- sounds for the panes
local redSound = getSound("Beep1", redPane)
local greenSound = getSound("Beep2", greenPane)
local blueSound = getSound("Beep3", bluePane)
local yellowSound = getSound("Beep4", yellowPane)
local tickSound = getSound("Tick", part)
local passSound = getSound("Pass", part)
local failSound = getSound("Fail", part)


local colorTable = {redPane, greenPane, bluePane, yellowPane} --table of the panes
local actualcolorTable = {redPane.Color, greenPane.Color, bluePane.Color, yellowPane.Color} --stores the original colors of the panes

local proximityDetector = part:FindFirstChild("ClickDetector") -- searches for click detector

proximityDetector.MaxActivationDistance = 8 -- max distance the player can click the part

-- creates a prompt for the player to click
local function createPrompt(color)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Click"
	prompt.ObjectText = color
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	return prompt
end

-- disables all prompts
local function disablePrompts(prompt1, prompt2, prompt3, prompt4)
	prompt1.Enabled = false
	prompt2.Enabled = false
	prompt3.Enabled = false
	prompt4.Enabled = false
end

-- enables all prompts
local function enablePrompts(prompt1, prompt2, prompt3, prompt4)
	prompt1.Enabled = true
	prompt2.Enabled = true
	prompt3.Enabled = true
	prompt4.Enabled = true
end

-- references to the buttons & prompts
local redButton = puzzle:WaitForChild("RedButton")
local greenButton = puzzle:WaitForChild("GreenButton")
local blueButton = puzzle:WaitForChild("BlueButton")
local yellowButton = puzzle:WaitForChild("YellowButton")
local prompt1 = createPrompt("Red")
local prompt2 = createPrompt("Green")
local prompt3 = createPrompt("Blue")
local prompt4 = createPrompt("Yellow")


local puzzleStarted = false
local puzzleCompleted = false

-- blinks the lights for the panes
local function displayColor(color)
	print(color)
	if color == "Red" then
		redPane.Color = Color3.new(0.92929, 0.266575, 0.162097)
		redPane.Material = Enum.Material.Neon
		redSound:Play()
		task.wait(0.5)
		redPane.Color = actualcolorTable[1]
		redPane.Material = Enum.Material.Plastic
	elseif color == "Green" then
		greenPane.Color = Color3.new(0.261769, 0.883818, 0.255085)
		greenPane.Material = Enum.Material.Neon
		greenSound:Play()
		task.wait(0.5)
		greenPane.Color = actualcolorTable[2]
		greenPane.Material = Enum.Material.Plastic
	elseif color == "Blue" then
		bluePane.Color = Color3.new(0.24213, 0.386007, 0.875898)
		bluePane.Material = Enum.Material.Neon
		blueSound:Play()
		task.wait(0.5)
		bluePane.Color = actualcolorTable[3]
		bluePane.Material = Enum.Material.Plastic
	elseif color == "Yellow" then
		yellowPane.Color = Color3.new(0.84918, 0.872923, 0.225238)
		yellowPane.Material = Enum.Material.Neon
		yellowSound:Play()
		task.wait(0.5)
		yellowPane.Color = actualcolorTable[4]
		yellowPane.Material = Enum.Material.Plastic
	end
end

-- user input list
local userInputList = {}

-- checking whether the user input and the random colour list is the same
local function tablesEqual(t1, t2)
	if #t1 ~= #t2 then
		return false
	end
	for i = 1, #t1 do
		if t1[i] ~= t2[i] then
			return false
		end
	end
	return true
end

-- prompt triggers
prompt1.Triggered:Connect(function(player)
	print("Red Pressed")
	userInputList[#userInputList+1] = "Red"
end)

prompt2.Triggered:Connect(function(player)
	print("Green Pressed")
	userInputList[#userInputList+1] = "Green"
end)

prompt3.Triggered:Connect(function(player)
	print("Blue Pressed")
	userInputList[#userInputList+1] = "Blue"
end)

prompt4.Triggered:Connect(function(player)
	print("Yellow Pressed")
	userInputList[#userInputList+1] = "Yellow"
end)

-- timer increment
local timerIncrement = 2.5

-- Event that lets the player start the puzzle
proximityDetector.Triggered:Connect(function(player)
	puzzleStarted = true
	if puzzleStarted then
		proximityDetector.Enabled = false
		
		local colorList = {} -- list of random colors
		local compareList = {} -- list to compare the user input to
		local pass -- to check if the player has passed the puzzle
		
		prompt1.Parent = redButton
		prompt2.Parent = greenButton
		prompt3.Parent = blueButton
		prompt4.Parent = yellowButton
		
		part.Material = Enum.Material.Plastic
		part.Color = Color3.new(0.396078, 0.207843, 0.215686)
		part.Position = part.Position - Vector3.new(0, 0.35, 0)
		
		-- function to enable the prompts for players to press
		local function serverEnablePrompts()
			if promptEvent then
				promptEvent:FireAllClients("Enable")
			else
				enablePrompts(prompt1, prompt2, prompt3, prompt4)
			end
		end
		
		-- function to disable the prompts for players to press
		local function serverDisablePrompts()
			if promptEvent then
				promptEvent:FireAllClients("Disable")
			else
				disablePrompts(prompt1, prompt2, prompt3, prompt4)
			end
		end
		
		-- generate random color list
		for i = 1, 5, 1 do
			local randomColor = colorTable[math.random(1, #colorTable)]
			colorList[i] = randomColor
		end
		
		-- game logic
		task.wait(0.8)
		for i = 1, 5, 1 do
			print("Round",i)
			compareList[i] = tostring(colorList[i])
	
			serverDisablePrompts()
			
			for j = 1, i, 1 do
				displayColor(tostring(colorList[j]))
				task.wait(0.5)
			end
			
			serverEnablePrompts()
			
			local roundActive = true
			local roundTime = timerIncrement * i
			
			task.spawn(function()
				for t = 1, roundTime do
					if not pass then break end 
					tickSound:Play()
					task.wait(1) -- tick sound every second
				end
			end)
			
			task.wait(roundTime)
			roundActive = false
			
			-- calls the function to check if the player's input matches the color list
			pass = tablesEqual(userInputList, compareList)
			userInputList = {}
			
			-- if player doesn't pass then break out of the loop
			if not pass then
				print("failed")
				failSound:Play()
				serverDisablePrompts()
				break
			end
			-- if player on last round and passed then break out of loop
			if i == 5 and pass then
				print("passed")
				passSound:Play()
				serverDisablePrompts()
			end
		end
		
		-- if not pass reset the puzzle
		if not pass then
			part.Color = orginalPartColor
			part.Material = orginalPartMaterial
			part.Position = orginalPartPosition
			proximityDetector.Enabled = true
		end
	end
end)