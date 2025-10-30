local ReplicatedStorage = game:GetService('ReplicatedStorage')
local player = game.Players.LocalPlayer
local gui = script.Parent.Parent
local frame = script.Parent

local joinBtn = frame:WaitForChild("JoinLobbyBtn")
local leaveBtn = frame:WaitForChild("LeaveLobbyBtn")
local startBtn = frame:WaitForChild("StartGameBtn")
local statusLabel = frame:WaitForChild("LobbyStatusLbl")
local backBtn = frame:WaitForChild("BackBtn")

local joinEvent = ReplicatedStorage.MainMenuRemoteEvents:WaitForChild("JoinLobby")
local updateEvent = ReplicatedStorage.MainMenuRemoteEvents:WaitForChild("UpdateLobbyUI")

--join button 
joinBtn.MouseButton1Click:Connect(function()
	joinEvent:FireServer('Join')
end)


-- Leave button
leaveBtn.MouseButton1Click:Connect(function()
	joinEvent:FireServer("Leave")
end)

-- Back button returns to main menu
backBtn.MouseButton1Click:Connect(function()
	gui.Enabled = false
	game.Players.LocalPlayer.PlayerGui.MainMenu.Enabled = true
end)

-- server communication for lobby updates
updateEvent.OnClientEvent:Connect(function(count, minPlayers, maxPlayers)
	statusLabel.Text = 'Players in lobby'.. count .. '/' .. maxPlayers
	
	if count >= minPlayers then
		startBtn.Visible = true
	else
		startBtn.Visible = false
	end
end)

-- Start button (for now just prints)
startBtn.MouseButton1Click:Connect(function()
	print("Start Game pressed!")
end)
