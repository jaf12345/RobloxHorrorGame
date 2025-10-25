-- references
local replicatedStorage = game:GetService("ReplicatedStorage")
local file = replicatedStorage:WaitForChild("SimonPuzzleSounds")
local promptEvent = file:WaitForChild("PromptEvent")

-- more references. wait for the Puzzle model and the buttons
local puzzleModel = workspace:WaitForChild("SimonPuzzle")
local redButton = puzzleModel:WaitForChild("RedButton")
local greenButton = puzzleModel:WaitForChild("GreenButton")
local blueButton = puzzleModel:WaitForChild("BlueButton")
local yellowButton = puzzleModel:WaitForChild("YellowButton")

-- Wait for the ProximityPrompts inside each button
local prompts

-- Helper function to enable/disable prompts
local function setPromptsEnabled(state)
	for _, prompt in ipairs(prompts) do
		prompt.Enabled = state
	end
end

-- Listen to the RemoteEvent
promptEvent.OnClientEvent:Connect(function(action)
	prompts = {
		redButton:WaitForChild("ProximityPrompt"),
		greenButton:WaitForChild("ProximityPrompt"),
		blueButton:WaitForChild("ProximityPrompt"),
		yellowButton:WaitForChild("ProximityPrompt")
	}

	if action == "Enable" then
		setPromptsEnabled(true)
	elseif action == "Disable" then
		setPromptsEnabled(false)
	end
end)
