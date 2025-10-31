-- Creates a leaderstats folder with a Cash value for each player
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	-- make a leaderstats folder
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	-- add Cash counter (used for rewards or shop)
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Value = 0
	cashValue.Parent = stats
end)
