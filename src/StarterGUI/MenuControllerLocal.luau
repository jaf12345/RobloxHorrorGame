local player = game.Players.LocalPlayer
local gui = script.Parent
local lobbyBtn = gui.Frame.LobbyButton
local shopBtn = gui.Frame.ShopButton
local settingsBtn = gui.Frame.SettingButton


--functions for the buttons themselfs
lobbyBtn.MouseButton1Click:Connect(function()
	print('Lobby button clicked')
	
end)

shopBtn.MouseButton1Click:Connect(function()
	print('Shop button clicked')
	
	--shop GUI
end)

settingsBtn.MouseButton1Click:Connect(function()
	print('Settings button clicked')
	--settings GUI
end)
