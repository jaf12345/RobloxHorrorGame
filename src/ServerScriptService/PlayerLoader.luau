local Players = game:GetService("Players")

Players.CharacterAutoLoads = false

Players.PlayerAdded:Connect(function(player)
	-- load character manually on join
	player:LoadCharacter()
	
	player.CharacterAdded:Connect(function(character)
	end)
end)