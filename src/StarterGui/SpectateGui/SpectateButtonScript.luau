local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpectateEvent = ReplicatedStorage:WaitForChild("SpectateEvent")
local RefreshSpectateList = ReplicatedStorage:WaitForChild("RefreshSpectateList")

local gui = player:WaitForChild("PlayerGui"):WaitForChild("SpectateGui")
local frame = gui:WaitForChild("spectateFrame")
local nextButton = frame:WaitForChild("NextButton")
local prevButton = frame:WaitForChild("PreviousButton")

-- Track current index
local spectatablePlayers = {}
local currentIndex = 1

-- Helper: refresh list (filter out yourself if you want)
local function refreshPlayers()
	spectatablePlayers = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
			table.insert(spectatablePlayers, plr)
		end
	end
end

-- Refresh whenever server says so
RefreshSpectateList.OnClientEvent:Connect(function()
	refreshPlayers()
	currentIndex = 1
	SpectateEvent:FireServer(spectatablePlayers[currentIndex])
end)

-- Cycle next
nextButton.MouseButton1Click:Connect(function()
	refreshPlayers()
	print("NextButton clicked")
	if #spectatablePlayers == 0 then return end

	currentIndex = currentIndex + 1
	if currentIndex > #spectatablePlayers then
		currentIndex = 1
	end

	SpectateEvent:FireServer(spectatablePlayers[currentIndex]) -- tell server who we want
end)

-- Cycle prev
prevButton.MouseButton1Click:Connect(function()
	refreshPlayers()
	print("PrevButton clicked")
	if #spectatablePlayers == 0 then return end

	currentIndex = currentIndex - 1
	if currentIndex < 1 then
		currentIndex = #spectatablePlayers
	end

	SpectateEvent:FireServer(spectatablePlayers[currentIndex]) -- tell server who we want
end)
