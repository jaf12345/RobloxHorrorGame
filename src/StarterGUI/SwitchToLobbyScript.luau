local lobbyMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild('LobbyGUI')
local lobbyButton = script.Parent:WaitForChild('LobbyButton')

lobbyButton.MouseButton1Click:Connect(function()
	
	--hide main menu, show lobby menu
	script.Parent.Parent.Enabled = false
	lobbyMenu.Enabled = true
end)