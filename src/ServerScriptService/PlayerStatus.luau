local PlayerStatus = {}
local Players = game:GetService("Players")

-- table tracking alive and dead players: 1 = alive, 0 = dead
local status = {}

-- utility function
local function updateStatus(player, isAlive)
	status[player.Name] = isAlive and 1 or 0
end

-- return status for players
function PlayerStatus.GetStatus()
	return status
end

-- mark player as alive
function PlayerStatus.MarkAlive(player)
	print(player.Name .. " marked as alive")
	updateStatus(player, true)
end

-- mark player as dead
function PlayerStatus.MarkDead(player)
	print(player.Name .. " marked as dead")
	updateStatus(player, false)
end

-- track players who join
Players.PlayerAdded:Connect(function(player)
	
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		-- update when player dies
		humanoid.Died:Connect(function()
			PlayerStatus.MarkDead(player)
		end)
		-- update when player is alive
		PlayerStatus.MarkAlive(player)
	end)
end)

-- remove players from list when they leave
Players.PlayerRemoving:Connect(function(player)
	status[player.Name] = nil
end)

return PlayerStatus