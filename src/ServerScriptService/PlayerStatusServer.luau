local PlayerStatus = require(game.ServerScriptService.PlayerStatus)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatusEvent = Instance.new("RemoteEvent")
StatusEvent.Name = "StatusEvent"
StatusEvent.Parent = ReplicatedStorage

-- send the list of player status to the client
StatusEvent.OnServerEvent:Connect(function(player)
	StatusEvent:FireClient(player, PlayerStatus.GetStatus())
end)