-- get the local player and their character
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- get all the start and end parts
local creditPartStart = workspace:WaitForChild("CreditPartStart")
local creditPartEnd = workspace:WaitForChild("CreditPartEnd")
local playPartStart = workspace:WaitForChild("PlayPartStart")
local playPartEnd = workspace:WaitForChild("PlayPartEnd")

-- initialize player attribute
player:SetAttribute("touched", "MenuTarget")

-- function when entering credit zone
local function onCreditStartTouch(otherPart)
	if otherPart:IsDescendantOf(character) then
		if player:GetAttribute("touched") ~= "CreditTarget" then
			player:SetAttribute("touched", "CreditTarget")
			print("Show Credits")
		end
	end
end

-- function when leaving credit zone
local function onCreditEndTouch(otherPart)
	if otherPart:IsDescendantOf(character) then
		if player:GetAttribute("touched") ~= "MenuTarget" then
			player:SetAttribute("touched", "MenuTarget")
			print("End Credits")
		end
	end
end

-- function when entering play zone
local function onPlayStartTouch(otherPart)
	if otherPart:IsDescendantOf(character) then
		if player:GetAttribute("touched") ~= "LobbyTarget" then
			player:SetAttribute("touched", "LobbyTarget")
			print("Enter Lobby")
		end
	end
end

-- function when leaving play zone
local function onPlayEndTouch(otherPart)
	if otherPart:IsDescendantOf(character) then
		if player:GetAttribute("touched") ~= "MenuTarget" then
			player:SetAttribute("touched", "MenuTarget")
			print("Return to Menu")
		end
	end
end

-- connect all events
creditPartStart.Touched:Connect(onCreditStartTouch)
creditPartEnd.Touched:Connect(onCreditEndTouch)
playPartStart.Touched:Connect(onPlayStartTouch)
playPartEnd.Touched:Connect(onPlayEndTouch)
