local shopMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild('ShopGUI')
local shopBtn = script.Parent:WaitForChild('ShopButton')

shopBtn.MouseButton1Click:Connect(function()
	
	--hide main menu again and show shop menu
	script.Parent.Parent.Enabled = false
	shopMenu.Enabled = true
end)