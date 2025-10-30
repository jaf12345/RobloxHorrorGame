local settingsMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild('SettingGUI')
local settingsBtn = script.Parent:WaitForChild('SettingButton')

settingsBtn.MouseButton1Click:Connect(function()
	
	--hide main menu again and show settings menu
	script.Parent.Parent.Enabled = false
	settingsMenu.Enabled = true
end)